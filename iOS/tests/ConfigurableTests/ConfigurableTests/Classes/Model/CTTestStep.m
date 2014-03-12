//
//  CTTestStep.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTestStep+Protected.h"
#import "CTExpectedEvent+Protected.h"
#import "CTAction+Protected.h"



#pragma mark Structures

struct CTTestStepsDataKeysStruct CTTestStepsDataKeys = {
    
    .actorActionsKey = @"actor",
    .expectedEventsKey = @"listener"
};


#pragma mark - Public interface implementation

@implementation CTTestStep


#pragma mark - Class methods

+ (CTTestStep *)stepWithDictionary:(NSDictionary *)dictionary {
    
    return [[self alloc] initWithDictionary:dictionary];
}


#pragma mark - Instance methods

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.currentActionIndex = -1;
        self.actions = [NSMutableArray array];
        self.expectedEvents = [NSMutableArray array];
        
        NSArray *actions = [dictionary valueForKey:CTTestStepsDataKeys.actorActionsKey];
        NSArray *expectedEvents = [dictionary valueForKey:CTTestStepsDataKeys.expectedEventsKey];
        
        // In case if multiple actions steps is required, they all will be added to the list
        if ([actions count] && [[actions objectAtIndex:0] isKindOfClass:[NSArray class]]) {
            
            [actions enumerateObjectsUsingBlock:^(NSArray *action, NSUInteger actionIdx, BOOL *actionEnumeratorStop) {
                
                [self.actions addObject:[CTAction actionWithArray:action]];
            }];
        }
        // Looks like one step initialization is provided
        else if ([actions count]){
            
            [self.actions addObject:[CTAction actionWithArray:actions]];
        }
        
        [expectedEvents enumerateObjectsUsingBlock:^(NSArray *expectedEvent, NSUInteger expectedEventIdx,
                                                     BOOL *expectedEventEnumeratorStop) {
            
            [self.expectedEvents addObject:[CTExpectedEvent eventWithArray:expectedEvent]];
        }];
    }
    
    
    return self;
}

- (void)executeWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed, BOOL successful))handlerBlock {
    
    if (IS_ACTOR_ROLE) {
        
        [self executeNextActionWithStatusBlock:handlerBlock];
    }
}

- (void)executeNextActionWithStatusBlock:(void(^)(NSString *status, BOOL completed, BOOL successful))handlerBlock {
    
    self.currentActionIndex = self.currentActionIndex + 1;
    
    if (self.currentActionIndex < [self.actions count]) {
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        CTAction *action = [self.actions objectAtIndex:self.currentActionIndex];
        [action executeWithStatusBlock:^(NSString *executionStatus, BOOL actionCompleted, BOOL actionFailed) {
            
            if (handlerBlock) {
                
                handlerBlock(executionStatus, NO, !actionFailed);
            }
            
            if (!actionFailed && actionCompleted) {
                
                [weakSelf executeNextActionWithStatusBlock:handlerBlock];
            }
        }];
    }
    else {
        
        self.currentActionIndex = -1;
        
        if (handlerBlock) {
            
            handlerBlock(nil, YES, YES);
        }
    }
}

#pragma mark -


@end
