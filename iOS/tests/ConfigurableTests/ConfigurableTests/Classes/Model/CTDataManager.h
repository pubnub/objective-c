//
//  CTDataManager.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTTest.h"


#pragma mark - Public interface declaration

@interface CTDataManager : NSObject


#pragma mark - Class methods

/**
 Singleton method.
 
 @return Reference on CTDataManager singleton instance.
 */
+ (CTDataManager *)sharedInstance;


#pragma mark - Instance methods

- (NSUInteger)scheduledTestsCount;

/**
 Place specified \b CTTest instance into queue.
 
 @param test
 \b CTTest instance which should be placed into queue and executed when it will be requested.
 */
- (void)scheduleTest:(CTTest *)test;

/**
 Remove specified \b CTTest test from queue.
 */
- (void)unscheduleTest:(CTTest *)test;
- (void)unscheduleAlltests;

/**
 Checking whether test has bee placed into queue or not.
 
 @param test
 \b CTTest instance agains which test should be performed.
 
 @return \c YES if provided test has been placed into queue.
 */
- (BOOL)isScheduledTest:(CTTest *)test;

- (BOOL)hasScheduledTests;

/**
 Update test verification information.
 
 @param testState
 One of \b CTTestState enum fields which represent current test state.
 
 @param tets
 \b CTTest instance for which new state should be applied.
 */
- (void)setState:(CTTestState)testState forTest:(CTTest *)test;

/**
 Fetch state for specified test.
 
 @param test
 \b CTTest instance for which state should be fetched.
 
 @return Value from one of \b CTTestState enum fields.
 */
- (CTTestState)stateForTest:(CTTest *)test;

/**
 Clear all testing information.
 */
- (void)resetTestStates;

/**
 Number of tests, which is available for app in current configuration.
 
 @return Available tests count.
 */
- (NSUInteger)testsCount;

/**
 List of test which is available for app.
 
 @return List of \b CTTest instances.
 */
- (NSArray *)tests;

/**
 Launch all tests which has been scheduled by user.
 
 @param handlerBlock
 Block which is called each time when test execution status updated and pass four parameters: state string,
 whether test completed and whether it has been successful or not. Last parameter returns reference on \b CTTest instance
 for which test is launched.
 */
- (void)executeScheduledTestsWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed,
                                                      BOOL successful, CTTest *activeTest))handlerBlock;

#pragma mark -


@end
