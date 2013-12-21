//
//  TestSemaphor.h
//  BillsApp
//
//  Created by Marin Todorov on 17/01/2012.
//  Copyright (c) 2012 Marin Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestSemaphor : NSObject

@property (strong, atomic) NSMutableDictionary* flags;

+ (TestSemaphor *)sharedInstance;

- (BOOL)isLifted:(NSString*)key;
- (void)lift:(NSString*)key;
- (BOOL)waitForKey:(NSString*)key;

- (BOOL)waitForKey:(NSString *)key timeout:(NSTimeInterval)timeout;

@end