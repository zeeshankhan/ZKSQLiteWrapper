//
//  ZKSQLiteManager.m
//  ZKSQLite
//
//  Created by Zeeshan Khan on 15/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKSQLiteManager.h"
#import "sqlite3.h"

#define kDBName                     @"ZKDatabase"

#define kDBExtensionSQLite      @"sqlite"
#define kDBExtensionDB           @"db"

@interface ZKSQLiteManager ()
@property (atomic) sqlite3              *db;
@property (nonatomic) BOOL          isExecutingStatement;
@property (strong, nonatomic) NSString *databasePath;
@end

@implementation ZKSQLiteManager

+ (instancetype)sharedInstance {
    static ZKSQLiteManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        assert(sqlite3_threadsafe()); // whoa there big boy- gotta make sure sqlite it happy with what we're going to do.
        [self createDataBase];
    }
    return self;
}


#pragma mark - SQLite information

+ (NSString*)sqliteLibVersion {
    return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

+ (BOOL)isSQLiteThreadSafe {
    // make sure to read the sqlite headers on this guy!
    return sqlite3_threadsafe() != 0;
}

#pragma mark - Database

- (void)createDataBase {
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths firstObject];

    // Build the path to the database file
    NSString *dbName = [NSString stringWithFormat:@"%@.%@", kDBName, kDBExtensionSQLite];
    self.databasePath = [docsDir stringByAppendingPathComponent:dbName];
}

#pragma mark - Open / Close

- (BOOL)openDatabase {
    
    if (!_db) {
        
        NSFileManager *manager = [NSFileManager defaultManager]; //[[NSFileManager alloc] init];
        if ([manager fileExistsAtPath:self.databasePath])
        {
            int err = sqlite3_open([self.databasePath UTF8String], &_db );
            if(err != SQLITE_OK) {
                NSLog(@"[ZKSQLite] error opening!: %d", err);
                return NO;
            }
        }
        else {
            NSLog(@"[ZKSQLite] Cannot Open DB, File does not exist.");
            return NO;
        }
    }
    return YES;
}

- (BOOL)closeDatabase {
    
    if (_db) {
        
        int  rc;
        BOOL retry;
        BOOL triedFinalizingOpenStatements = NO;
        
        do {
            retry   = NO;
            rc      = sqlite3_close(_db);
            if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
                if (!triedFinalizingOpenStatements) {
                    triedFinalizingOpenStatements = YES;
                    sqlite3_stmt *pStmt;
                    while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0) {
                        NSLog(@"[ZKSQLite] Closing leaked statement");
                        sqlite3_finalize(pStmt);
                        retry = YES;
                    }
                }
            }
            else if (SQLITE_OK != rc) {
                NSLog(@"[ZKSQLite] error closing!: %d", rc);
            }
        }
        while (retry);
        
        _db = nil;
    }

    return YES;
}

#pragma mark - Error routines

- (NSString*)lastErrorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(_db)];
//    return [NSString stringWithCString:sqlite3_errmsg(_db) encoding:NSUTF8StringEncoding];
}

- (int)lastErrorCode {
    return sqlite3_errcode(_db);
}

- (BOOL)hadError {
    int lastErrCode = [self lastErrorCode];
    return (lastErrCode > SQLITE_OK && lastErrCode < SQLITE_ROW);
}

- (NSError*)errorWithMessage:(NSString*)message {
    if (message == nil)
        message = [self lastErrorMessage];
    return [NSError errorWithDomain:@"ZKSQLite" code:[self lastErrorCode] userInfo:@{NSLocalizedDescriptionKey: message}];
}

- (NSError*)lastError {
    return [self errorWithMessage:[self lastErrorMessage]];
}

#pragma mark -

- (id)plistDataWithPath:(NSString*)path {
    
    id data = nil;
    if (path) {
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        if (fileData) {
            
            NSError *error = nil;
            NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
            data = [NSPropertyListSerialization propertyListWithData:fileData options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
            if (error != nil) {
                NSLog(@"Plist error while loading: %@",[error localizedDescription]);
            }
        }
        else {
            NSLog(@"Plist File data is nil");
        }
    }
    return data;
}

- (void)createTableWithPlist:(NSString*)plistPath {
    id plistData = [self plistDataWithPath:plistPath];
    if (plistData == nil) {
        return;
    }

    if ([plistPath isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray*)plistData;
        NSDictionary *dic = [arr firstObject];
        
    }
}

- (void)createTableWithColumns:(NSArray*)arrColumns {
    
    
    
/*
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK) {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)";
        
        if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            status.text = @"Failed to create table";
        }
        sqlite3_close(contactDB);
    }
    else {
        status.text = @"Failed to open/create database";
    }

*/    
    // CREATE  TABLE "main"."Employee" ("name" TEXT, "age" INTEGER, "gender" TEXT, "address" TEXT, "email" TEXT, "phone" NUMERIC, "twitter" TEXT, "employeeId" TEXT, "city" TEXT, "state" TEXT, "country" TEXT, "pincode" NUMERIC, "nationality" TEXT, "maritialStatus" TEXT, "designation" TEXT, "dateOfBirth" DATETIME)
    
    // CREATE  TABLE "main"."AllTypes" ("ColumnInteger" INTEGER, "ColumnBool" BOOL, "ColumnDouble" DOUBLE, "ColumnFloat" FLOAT, "ColumnChar" CHAR, "ColumnText" TEXT, "ColumnVarchar" VARCHAR, "ColumnNumeric" NUMERIC, "ColumnDateTime" DATETIME)
}

- (id)exeuteStatement:(NSString*)sqlQuery {

    if (![self openDatabase]) {
        return 0x00;
    }

    if (_isExecutingStatement) {
        return 0x00;
    }
    
    _isExecutingStatement = YES;
    
    sqlite3_stmt *dbStatement = 0x00;
    int result = sqlite3_prepare_v2(_db, [sqlQuery UTF8String], -1, &dbStatement, NULL);
    if (result == SQLITE_OK) {

        // FIXME add checks same as FBDB next
        while (sqlite3_step(dbStatement) == SQLITE_ROW) {

            int columnCount = sqlite3_column_count(dbStatement);
            for(int columnIdx=0; columnIdx < columnCount; columnIdx++) {

                NSString *strKey = [NSString stringWithUTF8String:(const char *)sqlite3_column_name(dbStatement, columnIdx)];
                
                int columnType = sqlite3_column_type(dbStatement, columnIdx);
                NSLog(@"%@ = %d", strKey, columnType);
                
//                NSString *strValue = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(dbStatement, j)];

            }
        }

        
    }
    else {
        NSLog(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
        NSLog(@"DB Query: %d, %@", result, sqlQuery);
        NSLog(@"DB Path: %@", _databasePath);
    }
    
    sqlite3_finalize(dbStatement);
    
    [self closeDatabase];

    _isExecutingStatement = NO;

    return 0x00;
}

@end

@implementation NSString (Helper)

- (BOOL)isValid {
    if (self == nil || ![self isKindOfClass:[NSString class]] || [self isEqualToString:@"<null>"] || [self isEqualToString:@"(null)"] || [self isEqualToString:@"null"] || [self isEqualToString:@"nil"]) {
        return NO;
    }
    return YES;
}

@end
