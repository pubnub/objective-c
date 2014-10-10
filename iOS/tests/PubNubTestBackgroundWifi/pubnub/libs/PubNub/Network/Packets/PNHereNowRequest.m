//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import "PNHereNowRequest.h"
#import "PNChannel+Protected.h"
#import "NSString+PNAddition.h"
#import "PNRequestsImport.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNHereNowRequest ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, assign, getter = isClientIdentifiersRequired) BOOL clientIdentifiersRequired;
@property (nonatomic, assign, getter = shouldFetchClientState) BOOL fetchClientState;
@property (nonatomic, copy) NSString *subscriptionKey;


@end


@implementation PNHereNowRequest


#pragma mark Class methods

+ (PNHereNowRequest *)whoNowRequestForChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                   clientState:(BOOL)shouldFetchClientState {

    return [[[self class] alloc] initWithChannels:channels clientIdentifiersRequired:isClientIdentifiersRequired
                                      clientState:shouldFetchClientState];
}


#pragma mark - Instance methods

- (id)initWithChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
          clientState:(BOOL)shouldFetchClientState {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.channels = channels;
        self.clientIdentifiersRequired = isClientIdentifiersRequired;
        self.fetchClientState = shouldFetchClientState;
    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.channelParticipantsCallback;
}

- (NSString *)resourcePath {
    
    NSString *channelsList = nil;
    NSString *groupsList = nil;
    if ([self.channels count]) {
        
        NSArray *channels = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = NO"]];
        NSArray *groups = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = YES"]];
        if ([channels count]) {
            
            channelsList = [[channels valueForKey:@"escapedName"] componentsJoinedByString:@","];
        }
        if ([groups count]) {
            
            groupsList = [[groups valueForKey:@"escapedName"] componentsJoinedByString:@","];
            if (!channelsList) {
                
                channelsList = @",";
            }
        }
    }

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@%@?callback=%@_%@&disable_uuids=%@&state=%@%@%@&pnsdk=%@",
                                      [self.subscriptionKey pn_percentEscapedString],
                                      (channelsList ? [NSString stringWithFormat:@"/channel/%@", channelsList] : @""),
                                      [self callbackMethodName], self.shortIdentifier, (self.isClientIdentifiersRequired ? @"0" : @"1"),
                                      (self.shouldFetchClientState ? @"1" : @"0"),
                                      (groupsList ? [NSString stringWithFormat:@"&channel-group=%@", groupsList] : @""),
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
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
