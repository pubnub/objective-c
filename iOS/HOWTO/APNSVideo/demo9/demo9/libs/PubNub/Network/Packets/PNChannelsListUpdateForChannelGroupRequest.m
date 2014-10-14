//
//  PNChannelsListUpdateForChannelGroupRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelsListUpdateForChannelGroupRequest.h"
#import "PNChannelGroupChange+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNChannelGroup.h"
#import "PNMacro.h"


#pragma mark Structures

struct PNChannelListModificationTypeStruct {
    
    __unsafe_unretained NSString *add;
    __unsafe_unretained NSString *remove;
};

struct PNChannelListModificationTypeStruct PNChannelListModificationType = {
    
    .add = @"add",
    .remove = @"remove"
};


#pragma mark - Private interface declaration

@interface PNChannelsListUpdateForChannelGroupRequest ()


#pragma mark - Properties

/**
 Stores reference on change descriptor
 */
@property (nonatomic, strong) PNChannelGroupChange *change;

/**
 Stores reference on type of action which should be performed on channel group
 */
@property (nonatomic, strong) NSString *targetAction;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;


#pragma mark - Instance methods

/**
 Initialize request for channels list modification inside channel group.
 
 @param channels
 List of \b PNChannel instances which should be added/removed to/from channel group.
 
 @param group
 Channel group information instance.
 
 @param modificationAction
 Specify exact action which should be applied on channel group with provided channels.
 
 @return Ready to use \b PNChannelsForGroupRequest request.
 */
- (id)initWithChannels:(NSArray *)channels forChannelGroup:(PNChannelGroup *)group action:(NSString *)modificationAction;

#pragma mark -


@end


#pragma mark - Instance methods

@implementation PNChannelsListUpdateForChannelGroupRequest


#pragma mark - Class methods

+ (PNChannelsListUpdateForChannelGroupRequest *)channelsListAddition:(NSArray *)channels forChannelGroup:(PNChannelGroup *)group {
    
    return [[self alloc] initWithChannels:channels forChannelGroup:group action:PNChannelListModificationType.add];
}

+ (PNChannelsListUpdateForChannelGroupRequest *)channelsListRemoval:(NSArray *)channels forChannelGroup:(PNChannelGroup *)group {
    
    return [[self alloc] initWithChannels:channels forChannelGroup:group action:PNChannelListModificationType.remove];
}


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels forChannelGroup:(PNChannelGroup *)group action:(NSString *)modificationAction {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.targetAction = modificationAction;
        self.change = [PNChannelGroupChange changeForGroup:group channels:channels addingChannels:[self isChannelAdditionRequest]];
    }
    
    
    return self;
}

- (BOOL)isChannelAdditionRequest {
    
    return [self.targetAction isEqualToString:PNChannelListModificationType.add];
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {
    
    NSString *callbackMethodName = PNServiceResponseCallbacks.channelGroupChannelsAddCallback;
    if (![self isChannelAdditionRequest]) {
        
        callbackMethodName = PNServiceResponseCallbacks.channelGroupChannelsRemoveCallback;
    }
    
    
    return callbackMethodName;
}

- (NSString *)resourcePath {
    
    return [NSString stringWithFormat:@"/v1/channel-registration/sub-key/%@/%@channel-group/%@?%@=%@&callback=%@_%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString],
            (self.change.group.nspace ? [NSString stringWithFormat:@"namespace/%@/", [self.change.group.nspace pn_percentEscapedString]] : @""),
            [self.change.group.groupName pn_percentEscapedString], self.targetAction,
            [[self.change.channels valueForKey:@"escapedName"] componentsJoinedByString:@","], [self callbackMethodName],
            self.shortIdentifier, ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
