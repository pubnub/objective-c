//
//  PNObservationCenterTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNObservationCenter.h"
#import "PNObservationCenter+Protected.h"

#define PNObservationObserverData_observer					@"observer"
#define PNObservationObserverData_observerCallbackBlock		@"observerCallbackBlock"

struct PNObservationEventsStruct {

    __unsafe_unretained NSString *clientConnectionStateChange;
    __unsafe_unretained NSString *clientSubscriptionOnChannels;
    __unsafe_unretained NSString *clientUnsubscribeFromChannels;
    __unsafe_unretained NSString *clientPresenceEnableOnChannels;
    __unsafe_unretained NSString *clientPresenceDisableOnChannels;
    __unsafe_unretained NSString *clientPushNotificationEnabling;
    __unsafe_unretained NSString *clientPushNotificationDisabling;
    __unsafe_unretained NSString *clientPushNotificationEnabledChannelsRetrieval;
    __unsafe_unretained NSString *clientPushNotificationRemovalForAllChannels;
    __unsafe_unretained NSString *clientTimeTokenReceivingComplete;
    __unsafe_unretained NSString *clientAccessRightsChange;
    __unsafe_unretained NSString *clientAccessRightsAudit;
    __unsafe_unretained NSString *clientMessageSendCompletion;
    __unsafe_unretained NSString *clientReceivedMessage;
    __unsafe_unretained NSString *clientReceivedPresenceEvent;
    __unsafe_unretained NSString *clientReceivedHistory;
    __unsafe_unretained NSString *clientReceivedParticipantsList;
};

static struct PNObservationEventsStruct PNObservationEvents = {
    .clientConnectionStateChange = @"clientConnectionStateChangeEvent",
    .clientTimeTokenReceivingComplete = @"clientReceivingTimeTokenEvent",
    .clientSubscriptionOnChannels = @"clientSubscribtionOnChannelsEvent",
    .clientUnsubscribeFromChannels = @"clientUnsubscribeFromChannelsEvent",
    .clientPresenceEnableOnChannels = @"clientPresenceEnableOnChannels",
    .clientPresenceDisableOnChannels = @"clientPresenceDisableOnChannels",
    .clientPushNotificationEnabling = @"clientPushNotificationEnabling",
    .clientPushNotificationDisabling = @"clientPushNotificationDisabling",
    .clientPushNotificationEnabledChannelsRetrieval = @"clientPushNotificationEnabledChannelsRetrieval",
    .clientPushNotificationRemovalForAllChannels = @"clientPushNotificationRemovalForAllChannels",
    .clientAccessRightsChange = @"clientAccessRightsChange",
    .clientAccessRightsAudit = @"clientAccessRightsAudit",
    .clientMessageSendCompletion = @"clientMessageSendCompletionEvent",
    .clientReceivedMessage = @"clientReceivedMessageEvent",
    .clientReceivedPresenceEvent = @"clientReceivedPresenceEvent",
    .clientReceivedHistory = @"clientReceivedHistoryEvent",
    .clientReceivedParticipantsList = @"clientReceivedParticipantsListEvent"
};

@interface NSNotificationCenter (AllObservers)

- (NSSet *) my_observersForNotificationName:(NSString *)notificationName;

@end

@interface PNObservationCenter (test)

+ (void)resetCenter;
@property (nonatomic, strong) NSMutableDictionary *oneTimeObservers;
@property (nonatomic, strong) NSMutableDictionary *observers;
- (BOOL)isSubscribedOnClientStateChange:(id)observer;
- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block;
- (void)removeOneTimeObserversForEvent:(NSString *)eventName;
- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName;
- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName;
- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock;
- (void)handleClientConnectionStateChange:(NSNotification *)notification;
- (void)handleClientSubscriptionProcess:(NSNotification *)notification;
- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification;
- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification;
- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification;
- (void)handleClientPushNotificationStateChange:(NSNotification *)notification;
- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification;
- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification;
- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification;
- (void)handleClientDidReceiveMessage:(NSNotification *)notification;
- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification;
- (void)handleClientMessageHistoryProcess:(NSNotification *)notification;
- (void)handleClientChannelAccessRightsChange:(NSNotification *)notification;
- (void)handleClientChannelAccessRightsRequest:(NSNotification *)notification;
- (void)handleClientHereNowProcess:(NSNotification *)notification;
- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification;


@end


@interface PNObservationCenterTest : XCTestCase
- (BOOL)isObserver:(id)observer presentForEvent:(NSString*)event inCenter:(PNObservationCenter *)center isOneTime:(BOOL)isOneTime;
@end

@implementation PNObservationCenterTest


- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDefaultCenter {

	PNObservationCenter *center = [PNObservationCenter defaultCenter];
    
    XCTAssertNotNil( center, @"empty defaultCenter");
    XCTAssertNotNil( center.observers, @"empty");
    XCTAssertNotNil( center.oneTimeObservers, @"empty");
	XCTAssertTrue( center == [PNObservationCenter defaultCenter], @"");
}

-(void)testResetCenter {
	[[PNObservationCenter defaultCenter].oneTimeObservers setObject: @"object" forKey: @"key"];
	XCTAssertTrue( [PNObservationCenter defaultCenter].oneTimeObservers.count > 0, @"");
	[PNObservationCenter resetCenter];
	XCTAssertTrue( [[PNObservationCenter defaultCenter].oneTimeObservers count] == 0, @"oneTimeObservers not empty");
}

-(void)testInit {
	PNObservationCenter *center = [[PNObservationCenter alloc] init];
	XCTAssertTrue( [self checkNotification: kPNClientDidConnectToOriginNotification forObserver: center andSelectorWithName: @"handleClientConnectionStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientDidDisconnectFromOriginNotification forObserver: center andSelectorWithName: @"handleClientConnectionStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientConnectionDidFailWithErrorNotification forObserver: center andSelectorWithName: @"handleClientConnectionStateChange:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientSubscriptionDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientSubscriptionWillRestoreNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientSubscriptionDidRestoreNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientSubscriptionDidFailNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidFailNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientPresenceEnablingDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationEnablingProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPresenceEnablingDidFailNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationEnablingProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPresenceDisablingDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationDisablingProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPresenceDisablingDidFailNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationDisablingProcess:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationEnableDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationEnableDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationDisableDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationDisableDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationRemoveDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationRemoveProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationRemoveDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationRemoveProcess:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationChannelsRetrieveDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationEnabledChannels:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientPushNotificationChannelsRetrieveDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationEnabledChannels:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientAccessRightsChangeDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientAccessRightsChangeDidFailNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsChange:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientAccessRightsAuditDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsRequest:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientAccessRightsAuditDidFailNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsRequest:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientDidReceiveTimeTokenNotification forObserver: center andSelectorWithName: @"handleClientCompletedTimeTokenProcessing:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientDidFailTimeTokenReceiveNotification forObserver: center andSelectorWithName: @"handleClientCompletedTimeTokenProcessing:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientWillSendMessageNotification forObserver: center andSelectorWithName: @"handleClientMessageProcessingStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientDidSendMessageNotification forObserver: center andSelectorWithName: @"handleClientMessageProcessingStateChange:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientMessageSendingDidFailNotification forObserver: center andSelectorWithName: @"handleClientMessageProcessingStateChange:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientDidReceiveMessageNotification forObserver: center andSelectorWithName: @"handleClientDidReceiveMessage:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientDidReceivePresenceEventNotification forObserver: center andSelectorWithName: @"handleClientDidReceivePresenceEvent:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientDidReceiveMessagesHistoryNotification forObserver: center andSelectorWithName: @"handleClientMessageHistoryProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientHistoryDownloadFailedWithErrorNotification forObserver: center andSelectorWithName: @"handleClientMessageHistoryProcess:"], @"");

	XCTAssertTrue( [self checkNotification: kPNClientDidReceiveParticipantsListNotification forObserver: center andSelectorWithName: @"handleClientHereNowProcess:"], @"");
	XCTAssertTrue( [self checkNotification: kPNClientParticipantsListDownloadFailedWithErrorNotification forObserver: center andSelectorWithName: @"handleClientHereNowProcess:"], @"");
}

-(BOOL)checkNotification:(NSString*)name forObserver:(id)observer andSelectorWithName:(NSString*)selectorName {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSArray *observers = [[notificationCenter my_observersForNotificationName: name] allObjects];
	for( int i=0; i<observers.count; i++ ) {
		NSDictionary *observerInfo = observers[i];
		if( [[observerInfo objectForKey: @"observer"] isEqual: observer] == YES &&
		    [[observerInfo objectForKey: @"selector"] isEqual: selectorName] == YES ) {
			return YES;
		}
	}
	return NO;
}

-(void)testIsSubscribedOnClientStateChange {
	PNObservationCenter *center = [PNObservationCenter defaultCenter];
	[center addObserver: self forEvent: @"clientConnectionStateChangeEvent" oneTimeEvent: YES withBlock: ^{}];
    XCTAssertTrue( [center isSubscribedOnClientStateChange: self], @"empty");

	[center removeOneTimeObserversForEvent: @"clientConnectionStateChangeEvent"];
    XCTAssertFalse( [center isSubscribedOnClientStateChange: self], @"not empty");

//	id mock = [OCMockObject partialMockForObject: center];
//	[mock addClientConnectionStateObserver: self withCallbackBlock:^(NSString *__strong s, BOOL b, PNError *__strong e){}];
//	[[mock expect] addObserver: nil forEvent:nil oneTimeEvent:NO withBlock:nil];
//	[mock verify];
	[center addClientConnectionStateObserver: self withCallbackBlock: ^(NSString *__strong s, BOOL b, PNError *__strong e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientConnectionStateChange inCenter: center isOneTime: NO], @"empty");
	[center removeClientConnectionStateObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientConnectionStateChange inCenter: center isOneTime: NO], @"empty");
//8

	[center addClientChannelSubscriptionStateObserver: self withCallbackBlock: ^(PNSubscriptionProcessState state, NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientChannelSubscriptionStateObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientChannelUnsubscriptionObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientChannelUnsubscriptionObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientAsSubscriptionObserverWithBlock: ^(PNSubscriptionProcessState state, NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsSubscriptionObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientAsUnsubscribeObserverWithBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsUnsubscribeObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientAsPresenceEnablingObserverWithBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPresenceEnabling];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientAsPresenceDisablingObserverWithBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPresenceDisabling];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: YES], @"empty");
//20
	[center addClientPresenceEnablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientPresenceEnablingObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientPresenceDisablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientPresenceDisablingObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientAsPushNotificationsEnableObserverWithBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsEnableObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsEnableObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsEnableObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: NO], @"empty");

	[center addClientAsPushNotificationsDisableObserverWithBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsDisableObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsDisableObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsDisableObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: NO], @"empty");
//32

	[center addClientAsPushNotificationsEnabledChannelsObserverWithBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsEnabledChannelsObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsEnabledChannelsObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsEnabledChannelsObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: NO], @"empty");

	[center addClientAsPushNotificationsRemoveObserverWithBlock: ^(PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsRemoveObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsRemoveObserver: self withCallbackBlock: ^(PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsRemoveObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: NO], @"empty");
//40

	[center addClientAsTimeTokenReceivingObserverWithCallbackBlock: ^(NSNumber *n, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsTimeTokenReceivingObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: YES], @"empty");

	[center addTimeTokenReceivingObserver: self withCallbackBlock: ^(NSNumber *n, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: NO], @"empty");
	[center removeTimeTokenReceivingObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: NO], @"empty");

	[center addClientAsMessageProcessingObserverWithBlock: ^(PNMessageState state, id object){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsMessageProcessingObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: YES], @"empty");

	[center addMessageProcessingObserver: self withBlock: ^(PNMessageState state, id object){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: NO], @"empty");
	[center removeMessageProcessingObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: NO], @"empty");

	[center addMessageReceiveObserver: self withBlock: ^(PNMessage *message){} ];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedMessage inCenter: center isOneTime: NO], @"empty");
	[center removeMessageReceiveObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedMessage inCenter: center isOneTime: NO], @"empty");

	[center addPresenceEventObserver: self withBlock: ^(PNPresenceEvent *event){} ];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedPresenceEvent inCenter: center isOneTime: NO], @"empty");
	[center removePresenceEventObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedPresenceEvent inCenter: center isOneTime: NO], @"empty");

	[center addClientAsHistoryDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsHistoryDownloadObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: YES], @"empty");

	[center addMessageHistoryProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: NO], @"empty");
	[center removeMessageHistoryProcessingObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: NO], @"empty");
//56
	[center addClientAsAccessRightsChangeObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsAccessRightsChangeObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: YES], @"empty");

	[center addAccessRightsChangeObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: NO], @"empty");
	[center removeAccessRightsObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: NO], @"empty");

	[center addClientAsAccessRightsAuditObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsAccessRightsAuditObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: YES], @"empty");

	[center addAccessRightsAuditObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: NO], @"empty");
	[center removeAccessRightsAuditObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: NO], @"empty");

	[center addClientAsParticipantsListDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNError *e){}];
	XCTAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsParticipantsListDownloadObserver];
	XCTAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: YES], @"empty");
//66
	[center addChannelParticipantsListProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNError *e){}];
	XCTAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: NO], @"empty");
	[center removeChannelParticipantsListProcessingObserver: self];
	XCTAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: NO], @"empty");
}//68

-(void)testHandle {
	PNObservationCenter *center = [PNObservationCenter defaultCenter];

	__block BOOL isCalled = NO;
	__block BOOL isCalled1 = NO;
	[center addClientConnectionStateObserver: self withCallbackBlock: ^(NSString *s, BOOL b, PNError *e){isCalled = YES;}];
	[center handleClientConnectionStateChange: nil];
	XCTAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	[center addClientChannelSubscriptionStateObserver: self withCallbackBlock: ^(PNSubscriptionProcessState state, NSArray *a, PNError *e){isCalled = YES;}];
	[center handleClientSubscriptionProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	[center addClientChannelUnsubscriptionObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center handleClientUnsubscriptionProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPresenceEnablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPresenceEnablingObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPresenceObservationEnablingProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPresenceEnablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPresenceEnablingObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPresenceObservationEnablingProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");
//75
	isCalled = NO;
	isCalled1 = NO;
	[center addClientPresenceDisablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPresenceDisablingObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPresenceObservationDisablingProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPushNotificationsEnableObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPushNotificationsEnableObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPushNotificationStateChange: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPushNotificationsRemoveObserver: self withCallbackBlock: ^(PNError *e){isCalled = YES;}];
	[center addClientAsPushNotificationsRemoveObserverWithBlock: ^(PNError *e){isCalled1 = YES;}];
	[center handleClientPushNotificationRemoveProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPushNotificationsEnabledChannelsObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPushNotificationsEnabledChannelsObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPushNotificationEnabledChannels: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	[center addMessageProcessingObserver: self withBlock: ^(PNMessageState state, id object){isCalled = YES;} oneTimeEvent: YES];
	[center handleClientMessageProcessingStateChange: nil];
	XCTAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	[center addMessageReceiveObserver: self withBlock: ^(PNMessage *m){isCalled = YES;}];
	[center handleClientDidReceiveMessage: nil];
	XCTAssertTrue( isCalled, @"block not called");
//85
	isCalled = NO;
	[center addPresenceEventObserver: self withBlock: ^(PNPresenceEvent *e){isCalled = YES;}];
	[center handleClientDidReceivePresenceEvent: nil];
	XCTAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addMessageHistoryProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){isCalled = YES;}];
	[center addClientAsHistoryDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){isCalled1 = YES;}];
	[center handleClientMessageHistoryProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addAccessRightsChangeObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled = YES;}];
	[center addClientAsAccessRightsChangeObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled1 = YES;}];
	[center handleClientChannelAccessRightsChange: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addAccessRightsAuditObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled = YES;}];
	[center addClientAsAccessRightsAuditObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled1 = YES;}];
	[center handleClientChannelAccessRightsRequest: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addChannelParticipantsListProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNError *e){isCalled = YES;}];
	[center addClientAsParticipantsListDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNError *e){isCalled1 = YES;}];
	[center handleClientHereNowProcess: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addTimeTokenReceivingObserver: self withCallbackBlock: ^(NSNumber *n, PNError *e){isCalled = YES;}];
	[center addClientAsTimeTokenReceivingObserverWithCallbackBlock: ^(NSNumber *n, PNError *e){isCalled1 = YES;}];
	[center handleClientCompletedTimeTokenProcessing: nil];
	XCTAssertTrue( isCalled, @"block not called");
	XCTAssertTrue( isCalled1, @"block not called");
}//96

- (BOOL)isObserver:(id)observer presentForEvent:(NSString*)event inCenter:(PNObservationCenter *)center isOneTime:(BOOL)isOneTime {
    NSMutableArray *observersData = nil;
	if( isOneTime == YES )
		observersData = [center oneTimeObserversForEvent: event];
	else
		observersData = [center persistentObserversForEvent: event];
	
    NSArray *observers = [observersData valueForKey:PNObservationObserverData_observer];
    return [observers containsObject:observer];
}


@end
