//
//  CTKeySet.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface CTKeySet : NSObject


#pragma mark - Properties

@property (nonatomic, readonly, copy) NSString *publishKey;
@property (nonatomic, readonly, copy) NSString *subscribeKey;
@property (nonatomic, readonly, copy) NSString *secretKey;
@property (nonatomic, readonly, copy) NSString *keyDescription;

#pragma mark -


@end
