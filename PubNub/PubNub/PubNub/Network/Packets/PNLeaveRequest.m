//
//  PNLeaveRequest.m
//  pubnub
//
//  This request instance is used to describe
//  channel(s) leave request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNLeaveRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub leave request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


@interface PNLeaveRequest ()


#pragma mark - Properties

// Stores reference on channels list
@property (nonatomic, strong) NSArray *channels;

// Stores reference on whether connection should
// be closed before sending this message or not
@property (nonatomic, assign, getter = shouldCloseConnection) BOOL closeConnection;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;


@end


@implementation PNLeaveRequest


#pragma mark - Class methods

+ (PNLeaveRequest *)leaveRequestForChannel:(PNChannel *)channel
                             byUserRequest:(BOOL)isLeavingByUserRequest {
    
    return [self leaveRequestForChannels:@[channel] byUserRequest:isLeavingByUserRequest];
}

+ (PNLeaveRequest *)leaveRequestForChannels:(NSArray *)channels
                              byUserRequest:(BOOL)isLeavingByUserRequest {
    
    return [[self alloc] initForChannels:channels byUserRequest:isLeavingByUserRequest];
}


#pragma mark - Instance methods

- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isLeavingByUserRequest {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        self.sendingByUserRequest = isLeavingByUserRequest;
        self.closeConnection = YES;
        self.channels = [[NSArray alloc] initWithArray:channels copyItems:NO];
    }
    
    
    return self;
}

- (void)setChannels:(NSArray *)channels {
    
    _channels = [[NSArray alloc] initWithArray:channels copyItems:NO];
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.leaveChannelCallback;
}

- (NSString *)resourcePath {

    // Compose filtering predicate to retrieve list of channels which are not presence observing channels
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"isPresenceObserver = NO"];
    NSArray *channelsToLeave = [self.channels filteredArrayUsingPredicate:filterPredicate];
    NSString *channelsListParameter = nil;
    NSString *groupsListParameter = nil;
    if ([channelsToLeave count]) {
        
        NSArray *channels = [channelsToLeave filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = NO"]];
        NSArray *groups = [channelsToLeave filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = YES"]];
        if ([channels count]) {
            
            channelsListParameter = [[channels valueForKey:@"escapedName"] componentsJoinedByString:@","];
        }
        if ([groups count]) {
            
            groupsListParameter = [[groups valueForKey:@"escapedName"] componentsJoinedByString:@","];
        }
    }


    return [[NSString alloc] initWithFormat:@"/v2/presence/sub_key/%@/channel/%@/leave?uuid=%@&callback=%@_%@%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString], (channelsListParameter ? channelsListParameter : @","),
            [self.clientIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [self callbackMethodName], self.shortIdentifier,
            (groupsListParameter ? [[NSString alloc] initWithFormat:@"&channel-group=%@", groupsListParameter] : @""),
            ([self authorizationField] ? [[NSString alloc] initWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [[NSString alloc] initWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
