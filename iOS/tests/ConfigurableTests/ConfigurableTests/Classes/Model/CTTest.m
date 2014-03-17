//
//  CTTest.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTest+Protected.h"
#import "CTTestStep+Protected.h"
#import "CTAction+Protected.h"
#import "CTTestStep.h"
#import "CTKeysSet.h"
#import "CTKeySet.h"


#pragma mark Static

static float const kCTTestStableServerVersion = 3.5f;
static float const kCTTestBetaServerVersion = 3.6f;
static NSString * const kCTTestStableServerOrigin = @"pubsub.pubnub.com";
static NSString * const kCTTestBetaServerOrigin = @"presence-beta.pubnub.com";


#pragma mark - Structures

struct CTTestSetDataKeysStruct CTTestSetDataKeys = {
    
    .common = {
        
        .clientVersionKeyPath = @"common.client",
        .serverVersionKeyPath = @"common.server",
        .keySetKeyPath = @"common.keyset",
        .secureConnectionKeyPath = @"common.ssl",
        .descriptionKeyPath = @"common.description"
    },
    .init = {
        
        .listenerInitializarionKeyPath = @"init.listener"
    },
    .stepsListKey = @"steps"
};


#pragma mark - Public interface implementation

@implementation CTTest


#pragma mark - Class methods

+ (CTTest *)testWithDictionary:(NSDictionary *)dictionary andOrderNumber:(NSUInteger)orderNumber {
    
    CTTest *test = nil;
    
    // Pulling out test case required client version.
    NSString *requiredClientVersion = [dictionary valueForKeyPath:CTTestSetDataKeys.common.clientVersionKeyPath];
    
    // Checking whether required client version is the same as embedded into test application or not.
    if ([requiredClientVersion isEqualToString:CLIENT_VERSION]) {
        
        test = [[self alloc] initWithDictionary:dictionary andOrderNumber:orderNumber];
    }
    
    
    return test;
}


#pragma mark - Instance methods

- (id)initWithDictionary:(NSDictionary *)dictionary andOrderNumber:(NSUInteger)orderNumber {
    
    // Cherck whether intialization has been successful or not.
    if ((self = [super init])) {
        
        self.currentTestCaseIndex = -1;
        self.order = orderNumber;
        self.serverVersion = [[dictionary valueForKeyPath:CTTestSetDataKeys.common.serverVersionKeyPath] floatValue];
        self.caseDescription = [dictionary valueForKeyPath:CTTestSetDataKeys.common.descriptionKeyPath];
        self.keySet = [CTKeysSet keySetWithIdentifier:[dictionary valueForKeyPath:CTTestSetDataKeys.common.keySetKeyPath]];
        self.useSecuereConnection = [[dictionary valueForKeyPath:CTTestSetDataKeys.common.secureConnectionKeyPath] boolValue];
        
        if (!IS_ACTOR_ROLE) {
            
            self.initializationSteps = [NSMutableArray array];
            NSArray *initializationSteps = [dictionary valueForKeyPath:CTTestSetDataKeys.init.listenerInitializarionKeyPath];
            
            // In case if multiple initialization steps is required, they all will be added to the list
            if ([initializationSteps count] && [[initializationSteps objectAtIndex:0] isKindOfClass:[NSArray class]]) {
                
                [initializationSteps enumerateObjectsUsingBlock:^(NSArray *action, NSUInteger actionIdx,
                                                                  BOOL *actionEnumeratorStop) {
                    
                    [self.initializationSteps addObject:[CTAction actionWithArray:action]];
                }];
            }
            // Looks like one step initialization is provided
            else if ([initializationSteps count]){
                
                [self.initializationSteps addObject:[CTAction actionWithArray:initializationSteps]];
            }
        }
        
        NSDictionary *steps = [dictionary valueForKeyPath:CTTestSetDataKeys.stepsListKey];
        if ([steps count]) {
            
            self.testSteps = [NSMutableArray arrayWithCapacity:[steps count]];
            for (int stepIndex = 0; stepIndex < [steps count]; stepIndex++) {
                
                NSString *stepIndexKey = [NSString stringWithFormat:@"%d", stepIndex];
                [self.testSteps addObject:[CTTestStep stepWithDictionary:[steps valueForKey:stepIndexKey]]];
            }
        }
    }
    
    
    return self;
}

- (NSString *)origin {
    
    NSString *origin = kCTTestStableServerOrigin;
    if (self.serverVersion == kCTTestBetaServerVersion) {
        
        origin = kCTTestBetaServerOrigin;
    }
    
    
    return origin;
}

- (void)executeWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed, BOOL successful))handlerBlock {
    
    [PubNub resetClient];
    if (IS_ACTOR_ROLE) {
        
        PNConfiguration *configuration = [PNConfiguration configurationForOrigin:[self origin]
                                                                      publishKey:[self.keySet publishKey]
                                                                    subscribeKey:[self.keySet subscribeKey]
                                                                       secretKey:nil];
        configuration.useSecureConnection = self.useSecuereConnection;
        [PubNub setConfiguration:configuration];
        [PubNub connect];
        
        if (handlerBlock) {
            
            handlerBlock([NSString stringWithFormat:@"Started '%@'", self.caseDescription], NO, YES);
        }
        
        [self executeNextStepWithStatusBlock:handlerBlock];
    }
}

- (void)executeNextStepWithStatusBlock:(void(^)(NSString *status, BOOL completed, BOOL successful))handlerBlock {
    
    self.currentTestCaseIndex = self.currentTestCaseIndex + 1;
    
    // Check whether test completed all steps or not
    if (self.currentTestCaseIndex < [self.testSteps count]) {
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        CTTestStep *step = [self.testSteps objectAtIndex:self.currentTestCaseIndex];
        [step executeWithStatusBlock:^(NSString *currentStatus, BOOL stepCompleted, BOOL stepSuccessful) {
            
            if (handlerBlock) {
                
                handlerBlock(currentStatus, NO, stepSuccessful);
            }
            
            if (stepCompleted && stepSuccessful) {
                
                [weakSelf executeNextStepWithStatusBlock:handlerBlock];
            }
        }];
    }
    else {
        
        self.currentTestCaseIndex = -1;
        
        if (handlerBlock) {
            
            handlerBlock(nil, YES, YES);
        }
    }
}


#pragma mark -


@end
