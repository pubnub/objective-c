//
//  PNClientStateHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateHelper.h"

// Don't use this category on your own, because interface can be changed (private).
#import "NSDictionary+PNAdditions.h"


#pragma mark Private interface declaration

@interface PNClientStateHelper ()


#pragma mark - Properties

/**
 Stores whether malformed client state has been provided or not.
 */
@property (nonatomic, assign, getter = isValidChannelStateProvided) BOOL validChannelStateProvided;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNClientStateHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    self.validChannelStateProvided = YES;
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
                
                self.validChannelStateProvided = YES;
                _state = [stateDictionary count] ? stateDictionary : nil;
            }
            else {
                
                self.validChannelStateProvided = NO;
            }
        }
        else {
            
            _state = nil;
            self.validChannelStateProvided = YES;
        }
    }
}

- (BOOL)isValidChannelNameAdnIdentifier {
    
    return (self.channelName && self.clientIdentifier && ![self.channelName isEmpty] && ![self.clientIdentifier isEmpty]);
}

- (BOOL)isValidClientState {
    
    BOOL isChannelStateValid = YES;
    if (self.channelName) {
        
        // Checking whether user provided suitable channel state data or not.
        if (self.isValidChannelStateProvided) {
            
            // Checking whether user provided some data or not
            if ([self.state count]) {
                
                isChannelStateValid = [@{self.channelName: self.state} isValidState];
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
    
    return [PubNub subscribedChannels];
}

- (void)performRequestWithBlock:(void(^)(PNClient *, PNError *))handlerBlock {
    
    PNChannel *channel = [PNChannel channelWithName:self.channelName];
    if (self.isStateEditingAllowed) {
        
        [PubNub updateClientState:self.clientIdentifier state:self.state forChannel:channel
      withCompletionHandlingBlock:handlerBlock];
    }
    else {
        
        [PubNub requestClientState:self.clientIdentifier forChannel:channel
       withCompletionHandlingBlock:^(PNClient *client, PNError *requestError) {
           
           if (!requestError) {
               
               self.state = client.data;
           }
           if (handlerBlock) {
               
               handlerBlock(client, requestError);
           }
       }];
    }
}

- (void)resetWarnings {
    
    self.validChannelStateProvided = YES;
}

#pragma mark -


@end
