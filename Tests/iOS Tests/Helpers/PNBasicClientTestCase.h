//
//  PNBasicClientTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <BeKindRewind/BeKindRewind.h>
#import <PubNub/PubNub.h>

#define PNWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

typedef void (^PNChannelGroupAssertions)(PNAcknowledgmentStatus *status);

@class PubNub;

@interface PNBasicClientTestCase : BKRTestCase <PNObjectEventListener>

@property (nonatomic) PNConfiguration *configuration;
@property (nonatomic, strong) PubNub *client;
@property (nonatomic, strong) XCTestExpectation *publishExpectation;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PAM enabled PubNub subscribe key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *pamSubscribeKey;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PAM enabled PubNub publish key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *pamPublishKey;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PubNub subscribe key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *subscribeKey;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PubNub publish key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *publishKey;

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration;

- (void)PNTest_publish:(id)message toChannel:(NSString *)channel withMetadata:(NSDictionary *)metadata withCompletion:(PNPublishCompletionBlock)block;

- (void)performVerifiedAddChannels:(NSArray *)channels toGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

- (void)performVerifiedRemoveAllChannelsFromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

- (void)performVerifiedRemoveChannels:(NSArray *)channels fromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

@end
