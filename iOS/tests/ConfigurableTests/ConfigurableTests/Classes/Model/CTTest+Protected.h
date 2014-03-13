//
//  CTTest+Protected.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTest.h"


#pragma mark Structures

struct CTTestSetDataKeysStruct {
    
    struct {
        
        /**
         Stores key path to the client version for which this test should be performed.
         In case if current \b PubNub version not equal to this field value, test will be skipped.
         */
        __unsafe_unretained NSString *clientVersionKeyPath;
        
        /**
         Stores key path to the on server version against which tests should be performed.
         */
        __unsafe_unretained NSString *serverVersionKeyPath;
        
        /**
         Stores key path on key set identifier which should be used during test.
         Actual key sets will be loaded from corresponding JSON file and stored under identifiers which is used
         in tests.json file.
         */
        __unsafe_unretained NSString *keySetKeyPath;
        
        /**
         Storss key path on key which hold information on whether during test secure connection should be used or not.
         */
        __unsafe_unretained NSString *secureConnectionKeyPath;
        
        /**
         Stores key path on key under which common description for test case is stored.
         */
        __unsafe_unretained NSString *descriptionKeyPath;
    } common;
    
    struct {
        
        /**
         Stores key path on key which holds list of required actions which should be performed by actions listener
         (in future app may support this feature).
         */
        __unsafe_unretained NSString *listenerInitializarionKeyPath;
    } init;
    
    /**
     Stores key under which list of steps which should be performed during test is stored.
     */
    __unsafe_unretained NSString *stepsListKey;
};

extern struct CTTestSetDataKeysStruct CTTestSetDataKeys;


#pragma mark - Private interface declaration

@interface CTTest ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *caseDescription;
@property (nonatomic, strong) CTKeySet *keySet;
@property (nonatomic, assign, getter = shouldUseSecuereConnection) BOOL useSecuereConnection;
@property (nonatomic, assign) NSUInteger order;
@property (nonatomic, assign) float serverVersion;

/**
 Stores array of \b CTAction instances in order in which they should be executed.
 */
@property (nonatomic, strong) NSMutableArray *initializationSteps;

/**
 Stores array of \b CTTestStep instances in orded in which they should be executed.
 */
@property (nonatomic, strong) NSMutableArray *testSteps;

/**
 Stores reference on current test case index (among whole tests list).
 */
@property (nonatomic, assign) NSInteger currentTestCaseIndex;


#pragma mark - Class methods

/**
 Construct \b CTTest instance basing on dictionary.
 
 @param dictionary
 \b NSDictionary instance which holds information required by test to run.
 
 @param orderNumber
 Order number from configuration JSON.
 
 @return Configured \b CTTest instance.
 */
+ (CTTest *)testWithDictionary:(NSDictionary *)dictionary andOrderNumber:(NSUInteger)orderNumber;


#pragma mark - Instance methods

/**
 Initialize \b CTTest instance basing on dictionary.
 
 @param dictionary
 \b NSDictionary instance which holds information required by test to run.
 
 @param orderNumber
 Order number from configuration JSON.
 
 @return Initialized and ready to use \b CTTest instance.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary andOrderNumber:(NSUInteger)orderNumber;

/**
 Fetch correct origin server.
 
 @return depending on provided server version information corresponding origin will be returned.
 */
- (NSString *)origin;

/**
 Launch next test case step.
 
 @param handlerBlock
 Block which is called each time when test execution status updated and pass three parameters: state string,
 whether test completed and whether it has been successful or not.
 */
- (void)executeNextStepWithStatusBlock:(void(^)(NSString *status, BOOL completed, BOOL successful))handlerBlock;

#pragma mark -


@end
