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

- (void)createDataBase;

@end
