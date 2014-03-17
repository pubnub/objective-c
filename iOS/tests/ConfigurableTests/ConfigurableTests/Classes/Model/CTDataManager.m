//
//  CTDataManager.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTDataManager.h"
#import "CTTestsSet.h"
#import "CTKeysSet.h"
#import "CTTest.h"


#pragma mark Private interface declaration

@interface CTDataManager ()


#pragma mark - Properties

@property (nonatomic, strong) CTTestsSet *testsSet;
@property (nonatomic, assign) NSUInteger testsCount;
@property (nonatomic, strong) NSMutableArray *testsQueue;
@property (nonatomic, strong) NSMutableDictionary *testStates;
@property (nonatomic, assign) NSInteger currentTestIndex;


#pragma mark - Instance methods

/**
 Launch next tests which has been scheduled by user.
 
 @param handlerBlock
 Block which is called each time when test execution status updated and pass three parameters: state string,
 whether test completed and whether it has been successful or not. Last parameter returns reference on \b CTTest instance
 for which test is launched.
 */
- (void)executeNextScheduledTestWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed,
                                                         BOOL successful, CTTest *activeTest))handlerBlock;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation CTDataManager


#pragma mark - Class methods

+ (CTDataManager *)sharedInstance {
    
    static CTDataManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [self new];
    });
    
    
    return _sharedManager;
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        [CTKeysSet initWithJSONFileContent:[[NSBundle mainBundle] pathForResource:@"keyset" ofType:@"json"]];
        self.testsSet = [CTTestsSet testsSetWithJSONFileContent:[[NSBundle mainBundle] pathForResource:@"tests" ofType:@"json"]];
        self.testsCount = [self.testsSet count];
        self.testsQueue = [NSMutableArray array];
        self.testStates = [NSMutableDictionary dictionary];
        self.currentTestIndex = -1;
    }
    
    
    return self;
}

- (NSUInteger)scheduledTestsCount {
    
    return [self.testsQueue count];
}

- (void)scheduleTest:(CTTest *)test {
    
    [self.testsQueue addObject:test];
    [self.testsQueue sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

- (void)unscheduleTest:(CTTest *)test {
    
    [self.testsQueue removeObject:test];
}

- (void)unscheduleAlltests {
    
    [self.testsQueue removeAllObjects];
}

- (BOOL)isScheduledTest:(CTTest *)test {
    
    return [self.testsQueue containsObject:test];
}

- (BOOL)hasScheduledTests {
    
    return [self.testsQueue count] > 0;
}

- (void)setState:(CTTestState)testState forTest:(CTTest *)test {
    
    [self.testStates setValue:@(testState) forKeyPath:[NSString stringWithFormat:@"%p", test]];
}

- (CTTestState)stateForTest:(CTTest *)test {
    
    CTTestState state = CTTestNotPassedState;
    NSString *testStateKey = [NSString stringWithFormat:@"%p", test];
    if ([self.testStates objectForKey:testStateKey]) {
        
        state = [[self.testStates valueForKey:testStateKey] intValue];
    }
    
    
    return state;
}

- (void)resetTestStates {
    
    [self.testStates removeAllObjects];
}

- (NSArray *)tests {
    
    return [self.testsSet tests];
}

- (void)executeScheduledTestsWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed, BOOL successful, CTTest *activeTest))handlerBlock {
    
    if (IS_ACTOR_ROLE) {
        
        [self executeNextScheduledTestWithStatusBlock:handlerBlock];
    }
}

- (void)executeNextScheduledTestWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed, BOOL successful, CTTest *activeTest))handlerBlock {
    
    self.currentTestIndex = self.currentTestIndex + 1;
    
    if (self.currentTestIndex < [self.testsQueue count]) {
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        CTTest *test = [self.testsQueue objectAtIndex:self.currentTestIndex];
        [test executeWithStatusBlock:^(NSString *currentStatus, BOOL testCompleted, BOOL testSuccessful) {
            
            if (handlerBlock) {
                
                handlerBlock(currentStatus, testCompleted, testSuccessful, test);
            }
            
            if (testSuccessful && testCompleted) {
                
                [weakSelf executeNextScheduledTestWithStatusBlock:handlerBlock];
            }
        }];
    }
    else {
        
        CTTest *previousTest = [self.testsQueue count] ? [self.testsQueue objectAtIndex:MAX(0, (self.currentTestIndex - 1))] : nil;
        self.currentTestIndex = -1;
        
        if (handlerBlock) {
            
            handlerBlock(nil, YES, YES, previousTest);
        }
    }
}

#pragma mark -


@end
