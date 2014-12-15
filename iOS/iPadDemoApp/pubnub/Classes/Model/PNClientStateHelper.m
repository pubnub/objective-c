//
//  PNClientStateHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateHelper.h"
#import "NSDictionary+PNDemoAddition.h"

#pragma mark Private interface declaration

@interface PNClientStateHelper ()


#pragma mark - Properties

/**
 Stores whether malformed client state has been provided or not.
 */
@property (nonatomic, assign, getter = isValidObjectStateProvided) BOOL validObjectStateProvided;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNClientStateHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    self.validObjectStateProvided = YES;
}

- (void)setState:(id)state {
    
    if ([state isKindOfClass:[NSDictionary class]]) {
        
        _state = state;
    }
    else {
        
        if (((NSString *)state).length > 0) {
            
            NSError *serializationError;
            NSDictionary *stateDictionary = [NSJSONSerialization JSONObjectWithData:[((NSString *)state) dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:(NSJSONReadingOptions)0 error:&serializationError];
            if (!serializationError && stateDictionary) {
                
                self.validObjectStateProvided = YES;
                _state = [stateDictionary count] ? stateDictionary : nil;
            }
            else {
                
                self.validObjectStateProvided = NO;
            }
        }
        else {
            
            _state = nil;
            self.validObjectStateProvided = YES;
        }
    }
}

- (BOOL)isValidChannelNameAdnIdentifier {
    
    return (self.channelName && self.clientIdentifier && ![self.channelName pn_isEmpty] && ![self.clientIdentifier pn_isEmpty]);
}

- (BOOL)isValidClientState {
    
    BOOL isChannelStateValid = YES;
    if (self.channelName) {
        
        // Checking whether user provided suitable object state data or not.
        if (self.isValidObjectStateProvided) {
            
            // Checking whether user provided some data or not
            if ([self.state count]) {
                
                isChannelStateValid = [@{self.channelName : self.state} pn_isValidState];
            }
            else {
                
                isChannelStateValid = NO;
            }
        }
        else {
            
            isChannelStateValid = NO;
        }
    }
    
    
    return isChannelStateValid;
}

- (NSArray *)existingChannels {
    
    return [PubNub subscribedObjectsList];
}

- (void)performRequestWithBlock:(void(^)(PNClient *, PNError *))handlerBlock {
    
    PNChannel *channel = [PNChannel channelWithName:self.channelName];
    if (self.isStateEditingAllowed) {
        
        [PubNub updateClientState:self.clientIdentifier state:self.state forObject:channel
      withCompletionHandlingBlock:handlerBlock];
    }
    else {
        
        [PubNub requestClientState:self.clientIdentifier forObject:channel
       withCompletionHandlingBlock:^(PNClient *client, PNError *requestError) {
           
           if (!requestError) {
               
               self.state = [client stateForChannel:client.channel];
           }
           if (handlerBlock) {
               
               handlerBlock(client, requestError);
           }
       }];
    }
}

- (void)resetWarnings {
    
    self.validObjectStateProvided = YES;
}

#pragma mark -


@end
