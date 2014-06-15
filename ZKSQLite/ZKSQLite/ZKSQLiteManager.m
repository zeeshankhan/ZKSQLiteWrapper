//
//  ZKSQLiteManager.m
//  ZKSQLite
//
//  Created by Zeeshan Khan on 15/06/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKSQLiteManager.h"

@implementation ZKSQLiteManager

+ (instancetype)sharedInstance {
    static ZKSQLiteManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)createDataBase {

    
}

@end
