//
//  PNBasicSubscribeTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

typedef void (^PNClientDidReceiveMessageAssertions)(PubNub *client, PNMessageResult *message);
typedef void (^PNClientDidReceivePresenceEventAssertions)(PubNub *client, PNPresenceEventResult *event);
typedef void (^PNClientDidReceiveStatusAssertions)(PubNub *client, PNSubscribeStatus *status);

@class XCTestExpectation;

@interface PNSubscribeTestData : NSObject
@property (nonatomic, strong) id publishMessage;
@property (nonatomic, assign) BOOL shouldReceiveMessage; // YES by default
@property (nonatomic, strong) NSDictionary *publishMetadata;
@property (nonatomic, strong) NSString *publishChannel;
@property (nonatomic, strong) NSNumber *expectedPublishTimetoken;
@property (nonatomic, strong) NSString *expectedPublishInformation;
@property (nonatomic, strong) NSArray *subscribedChannels;
@property (nonatomic, strong) NSArray *subscribedChannelGroups;
@property (nonatomic, strong) NSNumber *expectedStatusRegion;
@property (nonatomic, strong) NSString *expectedMessageActualChannel;
@property (nonatomic, strong) NSString *expectedMessageSubscribedChannel;
@property (nonatomic, strong) NSNumber *expectedMessageTimetoken;
@property (nonatomic, strong) NSNumber *expectedMessageRegion;
@end

@interface PNBasicSubscribeTestCase : PNBasicClientTestCase <PNObjectEventListener>

@property (nonatomic) XCTestExpectation *subscribeExpectation;
@property (nonatomic) XCTestExpectation *unsubscribeExpectation;
@property (nonatomic) XCTestExpectation *channelGroupSubscribeExpectation;
@property (nonatomic) XCTestExpectation *channelGroupUnsubscribeExpectation;

//@property (nonatomic) XCTestExpectation *presenceEventExpectation;

@property (nonatomic, copy) PNClientDidReceiveMessageAssertions didReceiveMessageAssertions;
@property (nonatomic, copy) PNClientDidReceivePresenceEventAssertions didReceivePresenceEventAssertions;
@property (nonatomic, copy) PNClientDidReceiveStatusAssertions didReceiveStatusAssertions;

- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence usingTimeToken:(NSNumber *)timeToken;
- (void)PNTest_subscribeToPresenceChannels:(NSArray *)channels;
- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence withClientState:(NSDictionary *)clientState;

- (void)PNTest_unsubscribeFromAll;
- (void)PNTest_unsubscribeFromChannels:(NSArray *)channels;
- (void)PNTest_unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_unsubscribeFromPresenceChannels:(NSArray *)channels;

- (void)PNTest_subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence usingTimeToken:(NSNumber *)timeToken;
- (void)PNTest_unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;

- (void)fulfillSubscribeExpectationAfterDelay:(NSTimeInterval)delay;

- (void)PNTest_sendAndReceiveMessageWithTestData:(PNSubscribeTestData *)testData;

@end
