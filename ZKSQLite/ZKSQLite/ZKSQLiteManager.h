//
//  ZKSQLiteManager.h
//  ZKSQLite
//
//  Created by Zeeshan Khan on 15/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKSQLiteManager : NSObject

+ (instancetype)sharedInstance;

- (id)exeuteStatement:(NSString*)sqlQuery;

/*
 
 Create Table with Array of keys
 Create Table with Dictionary of key values
 
 Drop Table
 Drop Table Content only
 
 Get All Key values as Dictionary
 
 Execute any SQL query
 
 */

@end

@interface NSString (Helper)
- (BOOL)isValid;
@end