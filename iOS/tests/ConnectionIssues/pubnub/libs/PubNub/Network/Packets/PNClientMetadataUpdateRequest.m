//
//  PNClientMetadataUpdateRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientMetadataUpdateRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNPrivateImports.h"


#pragma mark Public interface implementation

@implementation PNClientMetadataUpdateRequest


#pragma mark - Class methods

+ (PNClientMetadataUpdateRequest *)clientMetadataUpdateRequestWithIdentifier:(NSString *)clientIdentifier
                                                                     channel:(PNChannel *)channel
                                                                 andMetadata:(NSDictionary *)metadata {

    return [[self alloc] initWithIdentifier:clientIdentifier channel:channel andMetadata:metadata];
}


#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)clientIdentifier channel:(PNChannel *)channel andMetadata:(NSDictionary *)metadata {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.clientIdentifier = clientIdentifier;
        self.channel = channel;
        self.metadata = metadata;
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.metadataUpdateCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/uuid/%@/data?callback=%@_%@&metadata=%@%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      [self.channel escapedName], [self.clientIdentifier percentEscapedString],
                                      [self callbackMethodName], self.shortIdentifier,
                                      [[PNJSONSerialization stringFromJSONObject:self.metadata] percentEscapedString],
                                      ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@"")];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
