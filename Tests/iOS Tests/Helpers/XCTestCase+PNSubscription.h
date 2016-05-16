//
//  XCTestCase+PNSubscription.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/5/16.
//
//

#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

typedef NS_ENUM(NSUInteger, PNTestSubscribeComparisonType) {
    PNTestSubscribeComparisonTypeMatchExactly,
    PNTestSubscribeComparisonTypeContains,
};

@interface PNTestSubscribeStatus : NSObject
@property (nonatomic, strong, readonly) PubNub *client;
@property (nonatomic, strong, readonly) NSNumber *timeToken;
@property (nonatomic, strong, readonly) NSArray<NSString *> *expectedChannels;
@property (nonatomic, strong, readonly) NSArray<NSString *> *expectedChannelGroups;
@property (nonatomic, assign, readonly) PNOperationType expectedOperation;
@property (nonatomic, assign, readonly) PNStatusCategory expectedStatusCategory;
@property (nonatomic, assign, readonly) NSSet<NSString *> *expectedChannelsSet;
@property (nonatomic, assign, readonly) NSSet<NSString *> *expectedChannelGroupsSet;
//@property (nonatomic, strong) PNStatus *actualStatus;
@property (nonatomic, assign, readonly) PNTestSubscribeComparisonType comparisonType;

- (instancetype)initWithClient:(PubNub *)client expectedTimeToken:(NSNumber *)timeToken expectedOperation:(PNOperationType)operation expectedCategory:(PNStatusCategory)category expectedChannels:(NSArray<NSString *> *)channels expectedChannelGroups:(NSArray<NSString *> *)channelGroups;
+ (instancetype)expectedConnectStatusWithClient:(PubNub *)client expectedTimeToken:(NSNumber *)timeToken expectedChannels:(NSArray<NSString *> *)channels;
+ (instancetype)expectedConnectStatusWithClient:(PubNub *)client expectedTimeToken:(NSNumber *)timeToken expectedChannelGroups:(NSArray<NSString *> *)channelGroups;
+ (instancetype)expectedConnectStatusWithClient:(PubNub *)client expectedTimeToken:(NSNumber *)timeToken expectedChannels:(NSArray<NSString *> *)channels expectedChannelGroups:(NSArray<NSString *> *)channelGroups;

//- (instancetype)initWithComparisonType:(PNTestSubscribeComparisonType)comparisonType client:(PubNub *)client status:(PNStatus *)actualStatus channels:(NSArray<NSString *> *)expectedChannels timeToken:(NSNumber *)timeToken;
//- (instancetype)initWithComparisonType:(PNTestSubscribeComparisonType)comparisonType client:(PubNub *)client status:(PNStatus *)actualStatus channelGroups:(NSArray<NSString *> *)expectedChannelGroups timeToken:(NSNumber *)timeToken;
//- (instancetype)initWithComparisonType:(PNTestSubscribeComparisonType)comparisonType client:(PubNub *)client status:(PNStatus *)actualStatus channels:(NSArray<NSString *> *)expectedChannels channelGroups:(NSArray<NSString *> *)expectedChannelGroups timeToken:(NSNumber *)timeToken;
//+ (instancetype)subscribeResultWithComparisonType:(PNTestSubscribeComparisonType)comparisonType client:(PubNub *)client status:(PNStatus *)actualStatus channels:(NSArray<NSString *> *)expectedChannels timeToken:(NSNumber *)timeToken;
//+ (instancetype)subscribeResultWithComparisonType:(PNTestSubscribeComparisonType)comparisonType client:(PubNub *)client status:(PNStatus *)actualStatus channelGroups:(NSArray<NSString *> *)expectedChannelGroups timeToken:(NSNumber *)timeToken;
//+ (instancetype)subscribeResultWithComparisonType:(PNTestSubscribeComparisonType)comparisonType client:(PubNub *)client status:(PNStatus *)actualStatus channels:(NSArray<NSString *> *)expectedChannels channelGroups:(NSArray<NSString *> *)expectedChannelGroups timeToken:(NSNumber *)timeToken;

@end

@interface PNTestMessageResult : NSObject

@end

@interface PNTestPresenceResult : NSObject

@end

/**
 *  Root class for comparing all sorts of things
 */
@interface PNTestEvent : NSObject
@property (nonatomic, strong, readonly) PubNub *client;
@property (nonatomic, assign, readonly) PNOperationType expectedOperation;
@property (nonatomic, assign, readonly) PNStatusCategory expectedStatusCategory;

@end

@interface XCTestCase (PNSubscription)

- (void)PN_successfulSubscribeWithExpectedResult:(PNTestSubscribeStatus *)expectedResult andActualStatus:(PNSubscribeStatus *)subscribeStatus withComparisonType:(PNTestSubscribeComparisonType)comparisonType;
- (void)PN_successfulMessageWithExpectedMessage:(PNTestMessageResult *)expectedResult andActualMessage:(PNMessageResult *)message;
- (void)PN_successfulPresenceEventWithExpectedEvent:(PNTestPresenceResult *)expectedResult andActualEvent:(PNPresenceEventResult *)result;

//- (BOOL)PN_successfulSubscriptionWithComparisonType:(PNTestSubscribeComparisonType)comparisonType forClient:(PubNub *)client withStatus:(PNStatus *)status forChannels:(NSArray<NSString *> *)channels;
//- (BOOL)PN_successfulSubscriptionWithComparisonType:(PNTestSubscribeComparisonType)comparisonType forClient:(PubNub *)client withStatus:(PNStatus *)status forChannelGroups:(NSArray<NSString *> *)channelGroups;
//- (BOOL)PN_successfulSubscriptionWithComparisonType:(PNTestSubscribeComparisonType)comparisonType forClient:(PubNub *)client withStatus:(PNStatus *)status forChannels:(NSArray<NSString *> *)channels andChannelGroups:(NSArray<NSString *> *)channelGroups;

@end
