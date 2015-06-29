//
//  PNBasicClientTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <JSZVCR/JSZVCR.h>

#define PNWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

typedef void (^PNChannelGroupAssertions)(PNAcknowledgmentStatus *status);

@class PubNub;

@interface PNBasicClientTestCase : JSZVCRTestCase <PNObjectEventListener>

@property (nonatomic) PNConfiguration *configuration;
@property (nonatomic) PubNub *client;

- (void)performVerifiedAddChannels:(NSArray *)channels toGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

- (void)performVerifiedRemoveAllChannelsFromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

- (void)performVerifiedRemoveChannels:(NSArray *)channels fromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

@end
