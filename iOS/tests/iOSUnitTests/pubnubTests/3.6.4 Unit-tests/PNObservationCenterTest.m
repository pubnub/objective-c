//
//  PNObservationCenterTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
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


@interface PNObservationCenterTest : SenTestCase
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
    
    STAssertNotNil( center, @"empty defaultCenter");
    STAssertNotNil( center.observers, @"empty");
    STAssertNotNil( center.oneTimeObservers, @"empty");
	STAssertTrue( center == [PNObservationCenter defaultCenter], @"");
}

-(void)testResetCenter {
	[[PNObservationCenter defaultCenter].oneTimeObservers setObject: @"object" forKey: @"key"];
	STAssertTrue( [PNObservationCenter defaultCenter].oneTimeObservers.count > 0, @"");
	[PNObservationCenter resetCenter];
	STAssertTrue( [[PNObservationCenter defaultCenter].oneTimeObservers count] == 0, @"oneTimeObservers not empty");
}

-(void)testInit {
	PNObservationCenter *center = [[PNObservationCenter alloc] init];
	STAssertTrue( [self checkNotification: kPNClientDidConnectToOriginNotification forObserver: center andSelectorWithName: @"handleClientConnectionStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientDidDisconnectFromOriginNotification forObserver: center andSelectorWithName: @"handleClientConnectionStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientConnectionDidFailWithErrorNotification forObserver: center andSelectorWithName: @"handleClientConnectionStateChange:"], @"");

	STAssertTrue( [self checkNotification: kPNClientSubscriptionDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientSubscriptionWillRestoreNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientSubscriptionDidRestoreNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientSubscriptionDidFailNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientSubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidFailNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification forObserver: center andSelectorWithName: @"handleClientUnsubscriptionProcess:"], @"");

	STAssertTrue( [self checkNotification: kPNClientPresenceEnablingDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationEnablingProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPresenceEnablingDidFailNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationEnablingProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPresenceDisablingDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationDisablingProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPresenceDisablingDidFailNotification forObserver: center andSelectorWithName: @"handleClientPresenceObservationDisablingProcess:"], @"");

	STAssertTrue( [self checkNotification: kPNClientPushNotificationEnableDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPushNotificationEnableDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPushNotificationDisableDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPushNotificationDisableDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationStateChange:"], @"");

	STAssertTrue( [self checkNotification: kPNClientPushNotificationRemoveDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationRemoveProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPushNotificationRemoveDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationRemoveProcess:"], @"");

	STAssertTrue( [self checkNotification: kPNClientPushNotificationChannelsRetrieveDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationEnabledChannels:"], @"");
	STAssertTrue( [self checkNotification: kPNClientPushNotificationChannelsRetrieveDidFailNotification forObserver: center andSelectorWithName: @"handleClientPushNotificationEnabledChannels:"], @"");

	STAssertTrue( [self checkNotification: kPNClientAccessRightsChangeDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientAccessRightsChangeDidFailNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsChange:"], @"");

	STAssertTrue( [self checkNotification: kPNClientAccessRightsAuditDidCompleteNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsRequest:"], @"");
	STAssertTrue( [self checkNotification: kPNClientAccessRightsAuditDidFailNotification forObserver: center andSelectorWithName: @"handleClientChannelAccessRightsRequest:"], @"");

	STAssertTrue( [self checkNotification: kPNClientDidReceiveTimeTokenNotification forObserver: center andSelectorWithName: @"handleClientCompletedTimeTokenProcessing:"], @"");
	STAssertTrue( [self checkNotification: kPNClientDidFailTimeTokenReceiveNotification forObserver: center andSelectorWithName: @"handleClientCompletedTimeTokenProcessing:"], @"");

	STAssertTrue( [self checkNotification: kPNClientWillSendMessageNotification forObserver: center andSelectorWithName: @"handleClientMessageProcessingStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientDidSendMessageNotification forObserver: center andSelectorWithName: @"handleClientMessageProcessingStateChange:"], @"");
	STAssertTrue( [self checkNotification: kPNClientMessageSendingDidFailNotification forObserver: center andSelectorWithName: @"handleClientMessageProcessingStateChange:"], @"");

	STAssertTrue( [self checkNotification: kPNClientDidReceiveMessageNotification forObserver: center andSelectorWithName: @"handleClientDidReceiveMessage:"], @"");
	STAssertTrue( [self checkNotification: kPNClientDidReceivePresenceEventNotification forObserver: center andSelectorWithName: @"handleClientDidReceivePresenceEvent:"], @"");

	STAssertTrue( [self checkNotification: kPNClientDidReceiveMessagesHistoryNotification forObserver: center andSelectorWithName: @"handleClientMessageHistoryProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientHistoryDownloadFailedWithErrorNotification forObserver: center andSelectorWithName: @"handleClientMessageHistoryProcess:"], @"");

	STAssertTrue( [self checkNotification: kPNClientDidReceiveParticipantsListNotification forObserver: center andSelectorWithName: @"handleClientHereNowProcess:"], @"");
	STAssertTrue( [self checkNotification: kPNClientParticipantsListDownloadFailedWithErrorNotification forObserver: center andSelectorWithName: @"handleClientHereNowProcess:"], @"");
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
    STAssertTrue( [center isSubscribedOnClientStateChange: self], @"empty");

	[center removeOneTimeObserversForEvent: @"clientConnectionStateChangeEvent"];
    STAssertFalse( [center isSubscribedOnClientStateChange: self], @"not empty");

//	id mock = [OCMockObject partialMockForObject: center];
//	[mock addClientConnectionStateObserver: self withCallbackBlock:^(NSString *__strong s, BOOL b, PNError *__strong e){}];
//	[[mock expect] addObserver: nil forEvent:nil oneTimeEvent:NO withBlock:nil];
//	[mock verify];
	[center addClientConnectionStateObserver: self withCallbackBlock: ^(NSString *__strong s, BOOL b, PNError *__strong e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientConnectionStateChange inCenter: center isOneTime: NO], @"empty");
	[center removeClientConnectionStateObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientConnectionStateChange inCenter: center isOneTime: NO], @"empty");
//8

	[center addClientChannelSubscriptionStateObserver: self withCallbackBlock: ^(PNSubscriptionProcessState state, NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientChannelSubscriptionStateObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientChannelUnsubscriptionObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientChannelUnsubscriptionObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientAsSubscriptionObserverWithBlock: ^(PNSubscriptionProcessState state, NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsSubscriptionObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientSubscriptionOnChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientAsUnsubscribeObserverWithBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsUnsubscribeObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientUnsubscribeFromChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientAsPresenceEnablingObserverWithBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPresenceEnabling];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientAsPresenceDisablingObserverWithBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPresenceDisabling];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: YES], @"empty");
//20
	[center addClientPresenceEnablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientPresenceEnablingObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceEnableOnChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientPresenceDisablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientPresenceDisablingObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPresenceDisableOnChannels inCenter: center isOneTime: NO], @"empty");

	[center addClientAsPushNotificationsEnableObserverWithBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsEnableObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsEnableObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsEnableObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabling inCenter: center isOneTime: NO], @"empty");

	[center addClientAsPushNotificationsDisableObserverWithBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsDisableObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsDisableObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsDisableObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationDisabling inCenter: center isOneTime: NO], @"empty");
//32

	[center addClientAsPushNotificationsEnabledChannelsObserverWithBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsEnabledChannelsObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsEnabledChannelsObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsEnabledChannelsObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval inCenter: center isOneTime: NO], @"empty");

	[center addClientAsPushNotificationsRemoveObserverWithBlock: ^(PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsPushNotificationsRemoveObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: YES], @"empty");

	[center addClientPushNotificationsRemoveObserver: self withCallbackBlock: ^(PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: NO], @"empty");
	[center removeClientPushNotificationsRemoveObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientPushNotificationRemovalForAllChannels inCenter: center isOneTime: NO], @"empty");
//40

	[center addClientAsTimeTokenReceivingObserverWithCallbackBlock: ^(NSNumber *n, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsTimeTokenReceivingObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: YES], @"empty");

	[center addTimeTokenReceivingObserver: self withCallbackBlock: ^(NSNumber *n, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: NO], @"empty");
	[center removeTimeTokenReceivingObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientTimeTokenReceivingComplete inCenter: center isOneTime: NO], @"empty");

	[center addClientAsMessageProcessingObserverWithBlock: ^(PNMessageState state, id object){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsMessageProcessingObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: YES], @"empty");

	[center addMessageProcessingObserver: self withBlock: ^(PNMessageState state, id object){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: NO], @"empty");
	[center removeMessageProcessingObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientMessageSendCompletion inCenter: center isOneTime: NO], @"empty");

	[center addMessageReceiveObserver: self withBlock: ^(PNMessage *message){} ];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedMessage inCenter: center isOneTime: NO], @"empty");
	[center removeMessageReceiveObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedMessage inCenter: center isOneTime: NO], @"empty");

	[center addPresenceEventObserver: self withBlock: ^(PNPresenceEvent *event){} ];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedPresenceEvent inCenter: center isOneTime: NO], @"empty");
	[center removePresenceEventObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedPresenceEvent inCenter: center isOneTime: NO], @"empty");

	[center addClientAsHistoryDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsHistoryDownloadObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: YES], @"empty");

	[center addMessageHistoryProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: NO], @"empty");
	[center removeMessageHistoryProcessingObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedHistory inCenter: center isOneTime: NO], @"empty");
//56
	[center addClientAsAccessRightsChangeObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsAccessRightsChangeObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: YES], @"empty");

	[center addAccessRightsChangeObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: NO], @"empty");
	[center removeAccessRightsObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsChange inCenter: center isOneTime: NO], @"empty");

	[center addClientAsAccessRightsAuditObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsAccessRightsAuditObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: YES], @"empty");

	[center addAccessRightsAuditObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: NO], @"empty");
	[center removeAccessRightsAuditObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientAccessRightsAudit inCenter: center isOneTime: NO], @"empty");

	[center addClientAsParticipantsListDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNError *e){}];
	STAssertTrue( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: YES], @"empty");
	[center removeClientAsParticipantsListDownloadObserver];
	STAssertFalse( [self isObserver: [PubNub sharedInstance] presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: YES], @"empty");
//66
	[center addChannelParticipantsListProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNError *e){}];
	STAssertTrue( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: NO], @"empty");
	[center removeChannelParticipantsListProcessingObserver: self];
	STAssertFalse( [self isObserver: self presentForEvent: PNObservationEvents.clientReceivedParticipantsList inCenter: center isOneTime: NO], @"empty");
}//68

-(void)testHandle {
	PNObservationCenter *center = [PNObservationCenter defaultCenter];

	__block BOOL isCalled = NO;
	__block BOOL isCalled1 = NO;
	[center addClientConnectionStateObserver: self withCallbackBlock: ^(NSString *s, BOOL b, PNError *e){isCalled = YES;}];
	[center handleClientConnectionStateChange: nil];
	STAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	[center addClientChannelSubscriptionStateObserver: self withCallbackBlock: ^(PNSubscriptionProcessState state, NSArray *a, PNError *e){isCalled = YES;}];
	[center handleClientSubscriptionProcess: nil];
	STAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	[center addClientChannelUnsubscriptionObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center handleClientUnsubscriptionProcess: nil];
	STAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPresenceEnablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPresenceEnablingObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPresenceObservationEnablingProcess: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPresenceEnablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPresenceEnablingObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPresenceObservationEnablingProcess: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");
//75
	isCalled = NO;
	isCalled1 = NO;
	[center addClientPresenceDisablingObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPresenceDisablingObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPresenceObservationDisablingProcess: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPushNotificationsEnableObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPushNotificationsEnableObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPushNotificationStateChange: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPushNotificationsRemoveObserver: self withCallbackBlock: ^(PNError *e){isCalled = YES;}];
	[center addClientAsPushNotificationsRemoveObserverWithBlock: ^(PNError *e){isCalled1 = YES;}];
	[center handleClientPushNotificationRemoveProcess: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addClientPushNotificationsEnabledChannelsObserver: self withCallbackBlock: ^(NSArray *a, PNError *e){isCalled = YES;}];
	[center addClientAsPushNotificationsEnabledChannelsObserverWithBlock: ^(NSArray *a, PNError *e){isCalled1 = YES;}];
	[center handleClientPushNotificationEnabledChannels: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	[center addMessageProcessingObserver: self withBlock: ^(PNMessageState state, id object){isCalled = YES;} oneTimeEvent: YES];
	[center handleClientMessageProcessingStateChange: nil];
	STAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	[center addMessageReceiveObserver: self withBlock: ^(PNMessage *m){isCalled = YES;}];
	[center handleClientDidReceiveMessage: nil];
	STAssertTrue( isCalled, @"block not called");
//85
	isCalled = NO;
	[center addPresenceEventObserver: self withBlock: ^(PNPresenceEvent *e){isCalled = YES;}];
	[center handleClientDidReceivePresenceEvent: nil];
	STAssertTrue( isCalled, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addMessageHistoryProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){isCalled = YES;}];
	[center addClientAsHistoryDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNDate *d, PNDate *dt, PNError *e){isCalled1 = YES;}];
	[center handleClientMessageHistoryProcess: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addAccessRightsChangeObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled = YES;}];
	[center addClientAsAccessRightsChangeObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled1 = YES;}];
	[center handleClientChannelAccessRightsChange: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addAccessRightsAuditObserver: self withBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled = YES;}];
	[center addClientAsAccessRightsAuditObserverWithBlock: ^(PNAccessRightsCollection *c, PNError *e){isCalled1 = YES;}];
	[center handleClientChannelAccessRightsRequest: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addChannelParticipantsListProcessingObserver: self withBlock: ^(NSArray *a, PNChannel *c, PNError *e){isCalled = YES;}];
	[center addClientAsParticipantsListDownloadObserverWithBlock: ^(NSArray *a, PNChannel *c, PNError *e){isCalled1 = YES;}];
	[center handleClientHereNowProcess: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");

	isCalled = NO;
	isCalled1 = NO;
	[center addTimeTokenReceivingObserver: self withCallbackBlock: ^(NSNumber *n, PNError *e){isCalled = YES;}];
	[center addClientAsTimeTokenReceivingObserverWithCallbackBlock: ^(NSNumber *n, PNError *e){isCalled1 = YES;}];
	[center handleClientCompletedTimeTokenProcessing: nil];
	STAssertTrue( isCalled, @"block not called");
	STAssertTrue( isCalled1, @"block not called");
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
