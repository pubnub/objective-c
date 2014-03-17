//
//  CTAction.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTAction+Protected.h"


#pragma mark Public interface declaration

@implementation CTAction


#pragma mark - Class methods

+ (CTAction *)actionWithArray:(NSArray *)actionData {
    
    return [[self alloc] initWithArray:actionData];
}


#pragma mark - Instance methods

- (id)initWithArray:(NSArray *)actionData; {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.actionName = [actionData objectAtIndex:CTActionName];
        self.action = [self actionTypeFromName:self.actionName];
        self.parameters = [actionData objectAtIndex:CTActionParameters];
        self.delay = [[actionData objectAtIndex:CTActionExecutionDelay] unsignedIntegerValue] / 1000;
    }
    
    
    return self;
}

- (CTActionType)actionTypeFromName:(NSString *)actionName {
    
    CTActionType type = CTUnkonwnAction;
    if ([actionName isEqualToString:@"subscribe"]) {
        
        type = CTSubscribeAction;
    }
    else if ([actionName isEqualToString:@"unsubscribe"]) {
        
        type = CTUnsubscribeAction;
    }
    
    
    return type;
}

- (void)executeWithStatusBlock:(void(^)(NSString *executionStatus, BOOL completed, BOOL failed))executionStatusBlock {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *executionResult = [NSString stringWithFormat:@"Can't execute action. There is no known actions for '%@'",
                                     self.actionName];
        BOOL isMultipleParameters = [self.parameters respondsToSelector:@selector(count)];
        
        switch (self.action) {
                
            case CTSubscribeAction:
            {
                executionResult = [NSString stringWithFormat:@"Subscription on %@ scheduled.", self.parameters];
                
                PNClientChannelSubscriptionHandlerBlock handlerBlock = ^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
                    
                    // Inform observer about current execution status.
                    if (executionStatusBlock) {
                        
                        if (state == PNSubscriptionProcessNotSubscribedState && subscriptionError) {
                            
                            executionStatusBlock([NSString stringWithFormat:@"Subscription on %@ failed with error: %@.",
                                                  self.parameters, subscriptionError.localizedFailureReason], YES, YES);
                        }
                        else if (state == PNSubscriptionProcessSubscribedState) {
                            
                            executionStatusBlock([NSString stringWithFormat:@"Subscribed on %@.", self.parameters], YES, NO);
                        }
                    }
                };
                
                if (!isMultipleParameters) {
                    
                    [PubNub subscribeOnChannel:[PNChannel channelWithName:self.parameters] withCompletionHandlingBlock:handlerBlock];
                }
                else {
                    
                    [PubNub subscribeOnChannels:[PNChannel channelsWithNames:self.parameters] withCompletionHandlingBlock:handlerBlock];
                }
                break;
            }
            case CTUnsubscribeAction:
            {
                executionResult = [NSString stringWithFormat:@"Unsubscription from %@ scheduled.", self.parameters];
                
                PNClientChannelUnsubscriptionHandlerBlock handlerBlock = ^(NSArray *channels, PNError *unsubscribeError) {
                    
                    // Inform observer about current execution status.
                    if (executionStatusBlock) {
                        
                        if (unsubscribeError) {
                            
                            executionStatusBlock([NSString stringWithFormat:@"Unsubscription from %@ failed with error: %@.",
                                                  self.parameters, unsubscribeError.localizedFailureReason], YES, YES);
                        }
                        else {
                            
                            executionStatusBlock([NSString stringWithFormat:@"Unsubscribed from %@.", self.parameters], YES, NO);
                        }
                    }
                };
                
                if (!isMultipleParameters) {
                    
                    [PubNub unsubscribeFromChannel:[PNChannel channelWithName:self.parameters] withCompletionHandlingBlock:handlerBlock];
                }
                else {
                    
                    [PubNub unsubscribeFromChannels:[PNChannel channelsWithNames:self.parameters] withCompletionHandlingBlock:handlerBlock];
                }
            }
                break;
            default:
                break;
        }
        
        // Inform observer about current execution status.
        if (executionStatusBlock) {
            
            executionStatusBlock(executionResult, NO, NO);
        }
    });
}

#pragma mark -


@end
