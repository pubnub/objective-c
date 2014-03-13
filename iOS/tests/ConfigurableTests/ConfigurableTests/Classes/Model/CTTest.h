//
//  CTTest.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma Class forward

@class CTKeySet;


#pragma mark - Structures

/**
 Enum represent field which can be used to described test state and used for layout in UI.
 */
typedef enum _CTTestState {
    CTTestPassedState,
    CTTestFailedState,
    CTTestNotPassedState
} CTTestState;


#pragma mark - Public interface declaration

@interface CTTest : NSObject


#pragma mark - Properties

/**
 Common description for whole test case.
 */
@property (nonatomic, readonly, copy) NSString *caseDescription;

/**
 Stores reference on key set which should be used during test case intiialziation.
 */
@property (nonatomic, readonly, strong) CTKeySet *keySet;

/**
 Stores whether secure connection should be used during test or not.
 */
@property (nonatomic, readonly, assign, getter = shouldUseSecuereConnection) BOOL useSecuereConnection;

@property (nonatomic, readonly, assign) NSUInteger order;


#pragma mark - Instance methods

/**
 Launch test along with all predefined actions and expected response observation.
 
 @param handlerBlock
 Block which is called each time when test execution status updated and pass three parameters: state string, 
 whether test completed and whether it has been successful or not.
 */
- (void)executeWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed, BOOL successful))handlerBlock;

#pragma mark -


@end
