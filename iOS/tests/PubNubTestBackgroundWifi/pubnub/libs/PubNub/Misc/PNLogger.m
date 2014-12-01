//
//  PNLogger.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNLogger.h"
#import "NSString+PNAddition.h"
#import "NSDate+PNAdditions.h"
#import "PNLoggerSymbols.h"
#import "PNConstants.h"
#import "PNHelper.h"
#ifdef DEBUG
    #include <sys/sysctl.h>
    #include <sys/types.h>
    #include <stdbool.h>
    #include <unistd.h>
    #include <assert.h>
#endif
#include <stdlib.h>
#import "PNMacro.h"


#pragma mark Static

static NSString * const kPNLoggerDumpFileName = @"pubnub-console-dump.pnlog";
static NSString * const kPNLoggerOldDumpFileName = @"pubnub-console-dump.1.pnlog";

/**
 Stores maximum in-memory log size before storing it into the file. As soon as in-memory storage will reach this limit it
 will be flushed on file system.
 
 @note Default in-memory storage size is 16Kb.
 */
static NSUInteger const kPNLoggerMaximumInMemoryLogSize = (16 * 1024);

/**
 Stores maximum file size which should be stored on file system. As soon as limit will be reached, beginning of the file
 will be truncated.
 
 @note Default file size is 10Mb
 */
static NSUInteger const kPNLoggerMaximumDumpFileSize = (10 * 1024 * 1024);

/**
 Timeout which is used by timer to configure timeouts after which logger should force console dump.
 */
static NSTimeInterval const kPNLoggerDumpForceTimeout = 10.0f;


#pragma mark - Structures

struct PNLoggerSymbolsStructure PNLoggerSymbols = {

    .connection = {

        .connectionAttempt = @"0100000",
        .connectionInProgress = @"0100001",
        .reconnectionInProgress = @"0100002",
        .connectionResumingInProgress = @"0100003",
        .outOfSyncWithStateForciblyReconnect = @"0100004",
        .alreadyConnecting = @"0100005",
        .alreadyConnected = @"0100006",
        .triedToConnectDuringDisconnection = @"0100007",
        .notConfigured = @"0100008",
        .connectionImpossibleAtCurrentMoment = @"0100009",
        .connectionRetry = @"0100010",
        .connectionRetryAttempt = @"0100011",
        .connectionRetryOnSSLError = @"0100012",
        .connectionRetryOnTemporaryConnectionIssues = @"0100013",
        .connectionRetryImpossibleAtCurrentMoment = @"0100014",
        .connectionRetryCanceledBecauseStateAltered = @"0100015",
        .disconnectionAttempt = @"0100016",
        .connectedOnRetryAttempt = @"0100017",
        .connected = @"0100018",
        .reconnected = @"0100019",
        .resumed = @"0100020",
        .reconnectedAfterError = @"0100021",
        .reconnectedOnWakeUpTimerRequest = @"0100022",
        .reconnectedBecauseOfSSLError = @"0100023",
        .reconnectedBecauseOfTemporaryConnectionIssues = @"0100024",
        .closedWithFurtherReconnection = @"0100025",
        .closedWithFurtherReconnectionBecauseOfError = @"0100026",
        .closedOnRetryAttemptWithFurtherReconnection = @"0100027",
        .reconnectFromTheUserName = @"0100028",
        .closedWithFurtherConnectionOnUserRequest = @"0100029",
        .closedOnExpectedCloseWithFurtherReconnection = @"0100030",
        .closedOnConnectionResetWithFurtherReconnection = @"0100031",
        .closedOnWakeUpTimerRequestWithFurtherReconnection = @"0100032",
        .closedBecauseOfSSLErrorWithFurtherReconnection = @"0100033",
        .closedBecauseOfTemporaryConnectionIssuesWithFurtherReconnection = @"0100034",
        .closedByUserRequest = @"0100035",
        .closedBecauseOfError = @"0100036",
        .suspended = @"0100037",
        .disconnected = @"0100038",
        .disconnectedBecauseOfError = @"0100039",
        .notifyDelegateAboutDisconnection = @"0100040",
        .unscheduleRequestProcessing = @"0100041",
        .handleTimeoutTimer = @"0100042",
        .handleWakeUpTimer = @"0100043",
        .stillInBadState = @"0100044",
        .stateCanBeRecovered = @"0100045",
        .wakeUpEventCanceledBecauseStateHasBeenAltered = @"0100046",
        .error = @"0100047",
        .errorOnSSLLevel = @"0100048",
        .isSSLLevelReductionAllowed = @"0100049",
        .isSSLDiscardingAllowed = @"0100050",
        .currentSSLConfigurationLevel = @"0100051",
        .reduceSSLSecurityLevel = @"0100052",
        .discardSSLLeyer = @"0100053",
        .internalSSLError = @"0100054",
        .generalError = @"0100055",
        .generalErrorBecauseOfServerActions = @"0100056",
        .generalErrorOfTemporaryConnectionIssues = @"0100057",
        .internetConnectionFailure = @"0100058",
        .uplinkConnectionFailure = @"0100059",
        .connectionRetryAttemptIsPossible = @"0100060",
        .connectionRetryAttemptImpossible = @"0100061",
        .closingConnectionBecauseOfError = @"0100062",
        .closingConnectionBecauseOfErrorWhileTriedToConnect = @"0100063",
        .fetchingProxyConfiguration = @"0100064",
        .proxyConfigurationInformation = @"0100065",
        .proxyConfigurationNotRequired = @"0100066",
        .destroyed = @"0100067",
        .resourceLinkage = @"0100068",
        .connectionRetryAttemptInProgress = @"0100069",

        .stream = {

            .prepareForUsage = @"0110000",
            .configurationStarted = @"0110001",
            .configurationFailed = @"0110002",
            .configurationCompleted = @"0110003",
            .configurationCompletedEarlier = @"0110004",
            .configurationCompletedEarlierAndConnecting = @"0110005",
            .configurationCompletedEarlierAndConnected = @"0110006",
            .configurationCompletedEarlierAndResuming = @"0110007",
            .destroying = @"0110008",
            .destroyed = @"0110009",
            .opened = @"0110010",
            .closed = @"0110011",
            .configurationError = @"0110012",
            .configurationRetryAttempt = @"0110013",
            .configurationRetryAttemptsExceeded = @"0110014",
            .read = {

                .configurationStarted = @"0111000",
                .configurationFailed = @"0111001",
                .configurationCompleted = @"0111002",
                .initOpening = @"0111003",
                .unableToOpen = @"0111004",
                .opening = @"0111005",
                .opened = @"0111006",
                .disconnecting = @"0111007",
                .destroying = @"0111008",
                .destroyed = @"0111009",
                .hasData = @"0111010",
                .error = @"0111011",
                .cantAcceptDataAnymore = @"0111012",
                .readingArrivedData = @"0111013",
                .readedPortionOfArrivedData = @"0111014",
                .deserializerIsBusy = @"0111015",
                .readingError = @"0111016",
                .processedArrivedData = @"0111017",
                .processingAdditionalData = @"0111018",
                .rawHTTPResponse = @"0111019",
            },
            .write = {

                .configurationStarted = @"0112000",
                .configurationFailed = @"0112001",
                .configurationCompleted = @"0112002",
                .initOpening = @"0112003",
                .unableToOpen = @"0112004",
                .opening = @"0112005",
                .opened = @"0112006",
                .disconnecting = @"0112007",
                .destroying = @"0112008",
                .destroyed = @"0112009",
                .alreadySendingData = @"0112010",
                .canSendData = @"0112011",
                .error = @"0112012",
                .cantSendDataAnymore = @"0112013",
                .writeDataFromBuffer = @"0112014",
                .dataWriteError = @"0112015",
                .writenDataFromBufferAtOnce = @"0112016",
                .writenPartOfDataFromBuffer = @"0112017",
                .writeCanceled = @"0112018",
                .unableProcessNextRequestOnConnectionTermination = @"0112019",
                .nothingToWrite = @"0112020",
            }
        }
    },
    .connectionChannel = {

        .connectionAttempt = @"0200000",
        .outOfSyncWithConnection = @"0200001",
        .connecting = @"0200002",
        .disconnectingWithEvent = @"0200003",
        .disconnectingWithOutEvent = @"0200004",
        .disconnected = @"0200005",
        .outOfSyncWithDisconnection = @"0200006",
        .disconnecting = @"0200007",
        .alreadyDisconnected = @"0200008",
        .suspensionAttempt = @"0200009",
        .outOfSyncWithSuspension = @"0200010",
        .suspending = @"0200011",
        .resumeAttempt = @"0200012",
        .outOfSyncWithResuming = @"0200013",
        .resuming = @"0200014",
        .ignoreScheduledRequest = @"0200015",
        .reconnectingByRequest = @"0200016",
        .configurationFailed = @"0200017",
        .handleConnectionReset = @"0200018",
        .handleConnectionReady = @"0200019",
        .connected = @"0200020",
        .handleSuspension = @"0200021",
        .suspended = @"0200022",
        .handleResume = @"0200023",
        .resumed = @"0200024",
        .willRestoreConnection = @"0200025",
        .handleConnectionRestore = @"0200026",
        .connectionRestored = @"0200027",
        .willRestoreConnectionAfterError = @"0200028",
        .handleConnectionRestoreAfterError = @"0200029",
        .handleDisconnectionBecauseOfError = @"0200030",
        .disconnectedBecauseOfError = @"0200031",
        .handleDisconnection = @"0200032",
        .connectionRestoredAfterClosingByServerRequest = @"0200034",
        .closingConnectionByServerRequest = @"0200035",
        .disconnectedByServerRequest = @"0200036",
        .handleConnectionFailedBecauseOfError = @"0200037",
        .connectionFailedBecauseOfError = @"0200038",
        .malformedJSONPResponse = @"0200039",
        .receivedResponse = @"0200040",
        .reschedulingRequest = @"0200041",
        .requestRescheduleImpossible = @"0200042",
        .connectionReset = @"0200043",
        .destroyed = @"0200044",
        .resourceLinkage = @"0200045",
        .subscribe = {

            .leaveAllChannels = @"0201000",
            .leaveSpecificChannels = @"0201001",
            .restoringSubscription = @"0201002",
            .resubscribeOnIdle = @"0201003",
            .updateSubscriptionWithNewTimeToken = @"0201004",
            .subscriptionUpdateCanceled = @"0201005",
            .enablingPresenceOnSetOfChannels = @"0201006",
            .enablingPresenceAndSubscribingOnSetOfChannels = @"0201007",
            .enablingDisablingPresenceOnSetOfChannels = @"0201008",
            .enablingDisablingPresenceAndSubscribingOnSetOfChannels = @"0201009",
            .disablingPresenceOnSetOfChannels = @"0201010",
            .disablingPresenceAndSubscribingOnSetOfChannels = @"0201011",
            .subscribingOnSetOfChannels = @"0201012",
            .subscribedOnSetOfChannelsEarlier = @"0201013",
            .enabledPresenceOnSetOfChannelsEarlier = @"0201014",
            .disabledPresenceOnSetOfChannelsEarlier = @"0201015",
            .subscribingOnPreviousChannels = @"0201016",
            .leaveRequestCompleted = @"0201017",
            .leaveRequestFailed = @"0201018",
            .unsubscribedFromSetOfChannels = @"0201019",
            .handleEvent = @"0201020",
            .parsedData = @"0201021",
            .subscribeError = @"0201022",
            .presenceEnablingError = @"0201023",
            .presenceDisablingError = @"0201024",
            .willStartRequestSending = @"0201025",
            .sentRequest = @"0201026",
            .subscriptionRestored = @"0201027",
            .subscriptionCompleted = @"0201028",
            .enabledPresence = @"0201030",
            .disabledPresence = @"0201031",
            .leaved = @"0201032",
            .requestSendingFailed = @"0201033",
            .requestSendingCanceled = @"0201034",
        },
        .service = {

            .latencyMeterRequestCompleted = @"0202000",
            .latencyMeterRequestDidFail = @"0202001",
            .timeTokenRequestCompleted = @"0202002",
            .timeTokenRequestFailed = @"0202003",
            .clientStateAuditRequestCompleted = @"0202004",
            .clientStateAuditRequestFailed = @"0202005",
            .clientStateUpdateRequestCompleted = @"0202006",
            .clientStateUpdateRequestFailed = @"0202007",
            .messageSendRequestCompleted = @"0202008",
            .messageSendRequestFailed = @"0202009",
            .historyRequestCompleted = @"0202010",
            .historyRequestFailed = @"0202011",
            .participantsListRequestCompleted = @"0202012",
            .participantsListRequestFailed = @"0202013",
            .participantChannelsListRequestCompleted = @"0202014",
            .participantChannelsListRequestFailed = @"0202015",
            .pushNotificationEnableRequestCompleted = @"0202016",
            .pushNotificationEnableRequestFailed = @"0202017",
            .pushNotificationDisableRequestCompleted = @"0202018",
            .pushNotificationDisableRequestFailed = @"0202019",
            .pushNotificationRemoveRequestCompleted = @"0202020",
            .pushNotificationRemoveRequestFailed = @"0202021",
            .pushNotificationsAuditRequestCompleted = @"0202022",
            .pushNotificationsAuditRequestFailed = @"0202023",
            .accessRightsChangeRequestCompleted = @"0202024",
            .accessRightsChangeRequestFailed = @"0202025",
            .accessRightsAuditRequestCompleted = @"0202026",
            .accessRightsAuditRequestFailed = @"0202027",
            .parsedData = @"0202028",
            .observerRequestCompleted = @"0202029",
            .willStartRequestProcessing = @"0202030",
            .didSendRequest = @"0202031",
            .requestSendingDidFail = @"0202032",
            .requestWontBeSent = @"0202033",
            .latencyMeterRequestSent = @"0202034",
            .latencyMeterRequestSendingCanceled = @"0202035",
            .messagePostRequestSent = @"0202036",
            .channelGroupsRetrieveRequestCompleted = @"0202037",
            .channelGroupsRetrieveRequestFailed = @"0202038",
            .channelsForGroupRetrieveRequestCompleted = @"0202039",
            .channelsForGroupRetrieveRequestFailed = @"0202040",
            .channelsAdditionToGroupRequestCompleted = @"0202041",
            .channelsAdditionToGroupRequestFailed = @"0202042",
            .channelsRemovalFromGroupRequestCompleted = @"0202043",
            .channelsRemovalFromGroupRequestFailed = @"0202044",
            .channelGroupNamespacesRetrievalRequestCompleted = @"0202045",
            .channelGroupNamespacesRetrievalRequestFailed = @"0202046",
            .channelGroupNamespaceRemovalRequestCompleted = @"0202047",
            .channelGroupNamespaceRemovalRequestFailed = @"0202048",
            .channelGroupRemovalRequestCompleted = @"0202049",
            .channelGroupRemovalRequestFailed = @"0202050",
        }
    },
    .requests = {

        .methodRequiresOwnImplementation = @"0300000",
        .messagePost = {

            .messageBodyEncryptionError = @"0301000"
        }
    },
    .reachability = {

        .reachabilityFlagsChangedOnCallback = @"0400000",
        .reachabilityFlagsChangeIgnoredOnCallback = @"0400001",
        .reachabilityFlagsChangesWhileSuspendedOnCallback = @"0400002",
        .startReachabilityObservation = @"0400003",
        .restartReachabilityObservation = @"0400004",
        .reachabilityObservationCantBeUsedWithOutOrigin = @"0400005",
        .stopReachabilityObservation = @"0400006",
        .suspendedReachabilityObservation = @"0400007",
        .resumedReachabilityObservation = @"0400008",
        .lookupFailedWithError = @"0400009",
        .malformedLookupResponse = @"0400010",
        .unacceptableLookupResponseStatusCode = @"0400011",
        .uplinkRestored = @"0400012",
        .uplinkWentDown = @"0400013",
        .uplinkStillDown = @"0400014",
        .uplinkStateChangedDuringSuspension = @"0400015",
        .reachabilityFlagsRefresh = @"0400016",
        .reachabilityForcedFlagsChangeOnRefresh = @"0400017",
        .reachabilityFlagsChangedOnRefresh = @"0400018",
        .reachabilityFlagsChangedWithOutEventOnRefresh = @"0400019",
        .reachabilityFlagsChangeIgnoredOnRefresh = @"0400020",
        .reachabilityNetworkAddressChangedOnSet = @"0400021",
        .reachabilityHotspotChangedOnSet = @"0400022",
        .reachabilityInterfaceChangedOnSet = @"0400023",
        .reachabilityForcedFlagsChangeOnSet = @"0400024",
        .reachabilityFlagsChangeEventGeneratedOnSet = @"0400025",
        .reachabilityFlagsChangedOnSet = @"0400026",
        .unknownReachabilityFlagsOnSet = @"0400027",
    },
    .deserializer = {

        .unableToEncodeResponseData = @"0500000",
        .unexpectedResponseStatusCode = @"0500001",
        .rawResponseData = @"0500002",
    },
    .cryptor = {

        .destroyed = @"0600000"
    },
    .channel = {

        .nameRequired = @"0700000"
    },
    .JSONserializer = {

        .emptyJSONString = @"0800000",
        .JSONDecodeError = @"0800001",
        .decodeFailed = @"0800002",
    },
    .api = {

        .reset = @"0900000",
        .connectionAttemptWithOutHandlerBlock = @"0900001",
        .connectionAttemptHandlerBlock = @"0900002",
        .alreadyConnected = @"0900003",
        .alreadyConnecting = @"0900004",
        .prepareCommunicationComponents = @"0900005",
        .connectionImpossibleWithOutConfiguration = @"0900006",
        .connectionAttemptDuringSuspension = @"0900007",
        .connectionAttemptDuringResume = @"0900008",
        .reachabilityChecked = @"0900009",
        .internetConnectionAvailable = @"0900010",
        .createNewCommunicationComponents = @"0900011",
        .previousCommunicationComponentsHasBeenDestroyed = @"0900012",
        .reuseExistingCommunicationComponents = @"0900013",
        .internetConnectionNotAvailableAtThisMoment = @"0900014",
        .internetConnectionAvailabilityNotCheckedYet = @"0900015",
        .postponeConnection = @"0900016",
        .disconnectionAttemptByUserRequest = @"0900017",
        .disconnectionAttemptByInternalRequest = @"0900018",
        .disconnecting = @"0900019",
        .disconnectingForConfigurationChange = @"0900020",
        .disconnectedByUserRequest = @"0900021",
        .disconnected = @"0900022",
        .postponeDisconnected = @"0900023",
        .disconnectionAttemptForConfigurationChange = @"0900024",
        .postponeDisconnectionForConfigurationChange = @"0900026",
        .configurationUpdateAttempt = @"0900027",
        .validConfigurationProvided = @"0900028",
        .configurationUpdateRequireReconnection = @"0900029",
        .configurationUpdateDoesntRequireReconnection = @"0900030",
        .triedUpdateConfigurationDuringConnection = @"0900031",
        .sameConfigurationHasBeenProvided = @"0900032",
        .clientIdentifierUpdateAttempt = @"0900033",
        .updatingClientIdentifier = @"0900034",
        .postponeClientIdentifierUpdate = @"0900035",
        .sameClientIdentifierProvided = @"0900036",
        .clientStateAuditAttempt = @"0900037",
        .auditClientState = @"0900038",
        .clientStateAuditionImpossible = @"0900039",
        .postponeClientStateAudit = @"0900040",
        .clientStateChangeAttempt = @"0900041",
        .changeClientState = @"0900042",
        .clientStateChangeImpossible = @"0900043",
        .postponeClientStateChange = @"0900044",
        .subscribeAttempt = @"0900045",
        .subscribing = @"0900046",
        .subscriptionImpossible = @"0900047",
        .postponeSubscription = @"0900048",
        .unsubscribeAttempt = @"0900049",
        .unsubscribing = @"0900050",
        .unsubscriptionImpossible = @"0900051",
        .postponeUnsubscription = @"0900052",
        .pushNotificationsEnableAttempt = @"0900053",
        .enablingPushNotifications = @"0900054",
        .pushNotificationEnablingImpossible = @"0900055",
        .postponePushNotificationEnabling = @"0900056",
        .pushNotificationsDisableAttempt = @"0900057",
        .disablingPushNotifications = @"0900058",
        .pushNotificationDisablingImpossible = @"0900059",
        .postponePushNotificationDisabling = @"0900060",
        .pushNotificationsRemovalAttempt = @"0900061",
        .removePushNotifications = @"0900062",
        .pushNotificationRemovalImpossible = @"0900063",
        .postponePushNotificationRemoval = @"0900064",
        .pushNotificationsAuditAttempt = @"0900065",
        .auditPushNotifications = @"0900066",
        .pushNotificationAuditImpossible = @"0900067",
        .postponePushNotificationAudit = @"0900068",
        .accessRightsChangeAttempt = @"0900069",
        .changeAccessRights = @"0900070",
        .accessRightsChangeImpossible = @"0900071",
        .postponeAccessRightsChange = @"0900072",
        .accessRightsAuditAttempt = @"0900073",
        .auditAccessRights = @"0900074",
        .accessRightsAuditImpossible = @"0900075",
        .postponeAccessRightsAudit = @"0900076",
        .presenceObservationEnableAttempt = @"0900077",
        .enablingPresenceObservation = @"0900078",
        .presenceObservationEnableImpossible = @"0900079",
        .postponePresenceObservationEnable = @"0900080",
        .presenceObservationDisableAttempt = @"0900081",
        .disablingPresenceObservation = @"0900082",
        .presenceObservationDisableImpossible = @"0900083",
        .postponePresenceObservationDisable = @"0900084",
        .timeTokenFetchAttempt = @"0900085",
        .fetchingTimeToken = @"0900086",
        .timeTokenFetchImpossible = @"0900087",
        .postponeTimeTokenFetch = @"0900088",
        .messageSendAttempt = @"0900089",
        .sendingMessage = @"0900090",
        .messageSendImpossible = @"0900091",
        .postponeMessageSending = @"0900092",
        .historyFetchAttempt = @"0900093",
        .fetchingHistory = @"0900094",
        .historyFetchImpossible = @"0900095",
        .postponeHistoryFetching = @"0900096",
        .participantsListRequestAttempt = @"0900097",
        .requestingParticipantsList = @"0900098",
        .participantsListRequestImpossible = @"0900099",
        .postponeParticipantsListRequest = @"0900100",
        .participantChannelsListRequestAttempt = @"0900101",
        .requestingParticipantChannelsList = @"0900102",
        .participantChannelsListRequestImpossible = @"0900103",
        .postponeParticipantChannelsListRequest = @"0900104",
        .messageDecryptionError = @"0900105",
        .messageEncryptionError = @"0900106",
        .isConnected = @"0900107",
        .connectOnNetworkReachabilityCheck = @"0900108",
        .networkAvailableProceedConnection = @"0900109",
        .networkNotAvailableReportError = @"0900110",
        .networkAvailable = @"0900111",
        .previouslyDisconnectedBecauseOfError = @"0900112",
        .connectionStateImpossibleOnNetworkBecomeAvailable = @"0900113",
        .shouldRestoreConnection = @"0900114",
        .shouldResumeConnection = @"0900115",
        .shouldConnect = @"0900116",
        .noSuitableActionsForCurrentSituation = @"0900117",
        .networkNotAvailable = @"0900118",
        .triedToConnect = @"0900119",
        .networkWentDownDuringConnectionRestoring = @"0900120",
        .networkWentDownWhileSuspended = @"0900121",
        .networkWentDownWhileWasConnected = @"0900122",
        .autoConnectionDisabled = @"0900123",
        .connectionWillBeRestoredOnNetworkConnectionRestore = @"0900124",
        .networkWentDownBeforeConnectionCompletion = @"0900125",
        .connectionChannelConnected = @"0900126",
        .allConnectionChannelsConnected = @"0900127",
        .connectionChannelReconnected = @"0900128",
        .anotherConnectionChannelNotReconnectedYet = @"0900129",
        .connectionChannelConnectionFailed = @"0900130",
        .connectionFailed = @"0900131",
        .DNSCacheKillAttempt = @"0900132",
        .notifyDelegateConnectionCantBeEstablished = @"0900133",
        .connectionChannelDisconnected = @"0900134",
        .connectionChannelDisconnectedOnReleaseWithOutEvent = @"0900135",
        .disconnectingServiceChannel = @"0900136",
        .disconnectingMessagingChannel = @"0900137",
        .allConnectionChannelsDisconnected = @"0900138",
        .connectionShouldBeRestoredOnReacabilityCheck = @"0900139",
        .disconnectedBecauseOfError = @"0900140",
        .destroyCommunicationComponents = @"0900141",
        .alreadyRestoringConnection = @"0900142",
        .handleEnteredBackground = @"0900143",
        .unableToRunInBackground = @"0900144",
        .completeTasksBeforeCompleteTransitionToBackground = @"0900145",
        .suspendingOnTransitionToBackground = @"0900146",
        .connectionAttemptWhileTransitToBackground = @"0900147",
        .disconnectionAttemptWhileTransitToBackground = @"0900148",
        .disconnectionAttemptBecauseOfErrorWhileTransitToBackground = @"0900149",
        .notInBackground = @"0900150",
        .postponeSuspensionOnTransitionToBackground = @"0900151",
        .userDidntCallSuspensionOperationCompletionBlock = @"0900152",
        .handleEnterForeground = @"0900153",
        .resumingConnection = @"0900154",
        .previousConnectionWasTerminatedBecauseOfErrorOnTransitionToForeground = @"0900155",
        .networkConnectionWentDownWhileWasInBackgroundOnTransitionToForeground = @"0900156",
        .connectionWillRestoreOnNetworkAvailability = @"0900157",
        .handleWorkspaceSleep = @"0900158",
        .suspendingOnWorkspaceSleep = @"0900159",
        .unableToSuspendOnWorkspaceSleep = @"0900160",
        .connectionAttemptDuringWorkspaceSleep = @"0900161",
        .disconnectionAttemptDuringWorkspaceSleep = @"0900162",
        .disconnectionAttemptBecauseOfErrorDuringWorkspaceSleep = @"0900163",
        .handleWorkspaceWake = @"0900164",
        .previousConnectionWasTerminatedBecauseOfErrorOnWorkspaceWeak = @"0900165",
        .networkConnectionWentDownWhileWasInBackgroundOnWorkspaceWeak = @"0900166",
        .cryptoInitializationFailed = @"0900167",
        .connected = @"0900168",
        .clientStateAuditFailed = @"0900169",
        .clientStateChangeFailed = @"0900170",
        .resumingSubscription = @"0900171",
        .subscriptionFailed = @"0900172",
        .subscriptionOnClientIdentifierChangeFailed = @"0900173",
        .unsubscriptionFailed = @"0900174",
        .unsubscriptionOnClientIdentifierChangeFailed = @"0900175",
        .presenceObservationEnablingFailed = @"0900176",
        .presenceObservationDisablingFailed = @"0900177",
        .pushNotificationEnablingFailed = @"0900178",
        .pushNotificationDisablingFailed = @"0900179",
        .pushNotificationRemovalFailed = @"0900180",
        .pushNotificationAuditFailed = @"0900181",
        .accessRightsChangeFailed = @"0900182",
        .accessRightsAuditFailed = @"0900183",
        .timeTokenRetrieveFailed = @"0900184",
        .messageSendingFailed = @"0900185",
        .historyDownloadFailed = @"0900186",
        .participantsListDownloadFailed = @"0900187",
        .participantChannelsListDownloadFailed = @"0900188",
        .generalError = @"0900189",
        .disconnectingBecauseOfError = @"0900190",
        .connectedFailedBecauseOfError = @"0900192",
        .shouldCommunicationChannelNotifyDelegate = @"0900193",
        .willSubscribe = @"0900194",
        .didSubscribe = @"0900195",
        .didSubscribeDuringClientIdentifierChange = @"0900196",
        .willRestoreSubscription = @"0900197",
        .restoredSubscription = @"0900198",
        .willUnsubscribe = @"0900199",
        .didUnsubscribe = @"0900200",
        .didUnsubscribeDuringClientIdentifierChange = @"0900201",
        .willEnablePresenceObservation = @"0900202",
        .enabledPresenceObservation = @"0900203",
        .willDisablePresenceObservation = @"0900204",
        .disabledPresenceObservation = @"0900205",
        .didReceiveMessage = @"0900206",
        .didReceiveEvent = @"0900207",
        .didReceiveClientState = @"0900208",
        .rescheduleClientStateAudit = @"0900209",
        .didChangeClientState = @"0900210",
        .rescheduleClientStateChange = @"0900211",
        .didChangeAccessRights = @"0900212",
        .rescheduleAccessRightsChange = @"0900213",
        .didAuditAccessRights = @"0900214",
        .rescheduleAccessRightsAudit = @"0900215",
        .didReceiveTimeToken = @"0900216",
        .rescheduleTimeTokenRequest = @"0900217",
        .didEnablePushNotifications = @"0900218",
        .reschedulePushNotificationEnable = @"0900219",
        .didDisablePushNotifications = @"0900220",
        .reschedulePushNotificationDisable = @"0900221",
        .didRemovePushNotifications = @"0900222",
        .reschedulePushNotificationRemove = @"0900223",
        .didAuditPushNotifications = @"0900224",
        .reschedulePushNotificationAudit = @"0900225",
        .willSendMessage = @"0900226",
        .didSendMessage = @"0900227",
        .rescheduleMessageSending = @"0900228",
        .didReceiveHistory = @"0900229",
        .rescheduleHistoryRequest = @"0900230",
        .didReceiveParticipantsList = @"0900231",
        .rescheduleParticipantsListRequest = @"0900232",
        .didReceiveParticipantChannelsList = @"0900233",
        .rescheduleParticipantChannelsListRequest = @"0900234",
        .destroyed = @"0900235",
        .willConnect = @"0900236",
        .clientInformation = @"0900237",
        .configurationInformation = @"0900238",
        .resourceLinkage = @"0900239",
        .channelGroupsRequestAttempt = @"0900240",
        .requestChannelGroups = @"0900241",
        .channelGroupsRequestImpossible = @"0900242",
        .postponeChannelGroupsRequest = @"0900243",
        .channelGroupsRequestCompleted = @"0900244",
        .rescheduleChannelGroupsRequest = @"0900245",
        .channelGroupsRequestFailed = @"0900246",
        .channelsForGroupRequestAttempt = @"0900247",
        .requestChannelsForGroup = @"0900248",
        .channelsForGroupRequestImpossible = @"0900249",
        .postponeChannelsForGroupRequest = @"0900250",
        .channelsForGroupRequestCompleted = @"0900251",
        .rescheduleChannelsForGroupRequest = @"0900252",
        .channelsForGroupRequestFailed = @"0900253",
        .channelsAdditionToGroupAttempt = @"0900254",
        .addingChannelsToGroup = @"0900255",
        .channelsAdditionToGroupImpossible = @"0900256",
        .postponeChannelsAdditionToGroup = @"0900257",
        .channelsAdditionToGroupCompleted = @"0900258",
        .rescheduleChannelsAdditionToGroup = @"0900259",
        .channelsAdditionToGroupFailed = @"0900260",
        .channelsRemovalFromGroupAttempt = @"0900261",
        .removingChannelsFromGroup = @"0900262",
        .channelsRemovalGroupImpossible = @"0900263",
        .postponeChannelsRemovalFromGroup = @"0900264",
        .channelsRemovalFromGroupCompleted = @"0900265",
        .rescheduleChannelsRemovalFromGroup = @"0900266",
        .channelsRemovalFromGroupFailed = @"0900267",
        .channelGroupNamespacesRetrieveAttempt = @"0900268",
        .retrievingChannelGroupNamespaces = @"0900269",
        .channelGroupNamespacesRetrieveImpossible = @"0900270",
        .postponeChannelGroupNamespacesRetrieval = @"0900271",
        .channelGroupNamespacesRetrievalCompleted = @"0900272",
        .rescheduleChannelGroupNamespacesRetrieval = @"0900273",
        .channelGroupNamespacesRetrievalFailed = @"0900274",
        .channelGroupNamespaceRemovalAttempt = @"0900275",
        .removingChannelGroupNamespace = @"0900276",
        .channelGroupNamespaceRemovalImpossible = @"0900277",
        .postponeChannelGroupNamespaceRemoval = @"0900278",
        .channelGroupNamespaceRemovalCompleted = @"0900279",
        .rescheduleChannelGroupNamespaceRemoval = @"0900280",
        .channelGroupNamespaceRemovalFailed = @"0900281",
        .channelGroupRemovalAttempt = @"0900282",
        .removingChannelGroup = @"0900283",
        .channelGroupRemovalImpossible = @"0900284",
        .postponeChannelGroupRemoval = @"0900285",
        .channelGroupRemovalCompleted = @"0900286",
        .rescheduleChannelGroupRemoval = @"0900287",
        .channelGroupRemovalFailed = @"0900288",
        
    },
    .observationCenter = {
        
        .destroyed = @"1000000"
    }
};


#pragma mark - Types

/**
 Enum represent available logger configuration bit masks.
 */
typedef NS_OPTIONS(NSUInteger, PNLoggerConfiguration) {

    PNConsoleOutput = 1 << 11,
    PNConsoleDumpIntoFile = 1 << 12,
    PNHTTPResponseDumpIntoFile = 1 << 13
};


#pragma mark - Private interface declaration

@interface PNLogger ()


#pragma mark - Properties

/**
 Stores bit field which keep logger configuration information.
 */
@property (atomic, assign) NSUInteger configuration;

/**
 Stores reference on full file path to the current file which is used as console dump.
 */
@property (nonatomic, copy) NSString *dumpFilePath;

/**
 Stores reference on full file path to the old file which is has been used as console dump earlier.
 */
@property (nonatomic, copy) NSString *oldDumpFilePath;

/**
 Stores reference on full path to the folder which will be used for HTTP packet storage.
 */
@property (nonatomic, copy) NSString *httpPacketStoreFolderPath;

/**
 Stores reference on symbols mapping table.
 */
@property (nonatomic, strong) NSDictionary *symbolsTable;

/**
 Stores reference on name of section to which core is related.
 */
@property (nonatomic, strong) NSDictionary *symbolsSectionName;

/**
 Stores reference on queue which will be used during console dump and log rotation process to reduce main thread load.
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_queue_t dumpProcessingQueue;

/**
 Stores reference on queue which will be used during HTTP packet saving process to reduce main thread load.
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_queue_t httpProcessingQueue;

/**
 Stores reference on channel which is used to perform I/O operations when writting file in more efficient way.
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_io_t consoleDumpStoringChannel;

/**
 Stores reference on data storage which is used to write into the file using GCD i/O.
 */
@property (nonatomic, strong) NSMutableData *consoleDump;

/**
 Stores reference on timer which should force dump process in case if buffer size is not enough and last dump update
 passed allowed delay.
 */
@property (nonatomic, strong) NSTimer *consoleDumpTimer;

/**
 Stores maximum dump file size after which it should be truncated or log rotation should be performed.
 */
@property (nonatomic, assign) NSUInteger maximumDumpFileSize;


#pragma mark - Class methods

/**
 Compose singleton instance which further will store configuration and handle all logging events.
 */
+ (PNLogger *)sharedInstance;

/**
 Allow to check whether debugger connected to the running process or not.
 
 @return \c NO if application is running w/o debugger.
 */
+ (BOOL)isDebuggerAttached;

/**
 @brief Store binary data received from remote server.
 
 @param isExpectedResponse Whether packet received under expected status code and it's content valid.
 @param httpPacketBlock    Block which is called to calculate data which should be stored.
 
 @since 3.7.3
 */
+ (void)storeRAWHTTPPacket:(BOOL)isExpectedResponse dataDescription:(NSString *)dataDescription
                  withData:(NSData *(^)(void))httpPacketBlock;


#pragma mark - Instance methods

/**
 Perform logger default configuration based on available macros specified in header file.
 */
- (void)applyDefaultConfiguration;

/**
 Prepare async processing "tools".
 */
- (void)prepareForAsynchronousFileProcessing;

/**
 Prepare symbols for entries deserialization.
 */
- (void)prepareSymbols;

/**
 Manage I/O channel which is responsible for console output dumping.
 */
- (void)openConsoleDumpChannel;
- (void)closeConsoleDumpChannel;

/**
 Check whether logger has been enabled for specified level or not.

 @param level
 Level against which check should be performed.

 @return \c YES if logging has been enabled for provided level or not.
 */
- (BOOL)isLoggerEnabledFor:(PNLogLevel)level;

/**
 Compose correct log prefix based on specified level (warn, info, error, delegate, reaschability).

 @param level
 Level against which check should be performed.

 @return Composed \b NSString instance which can be used for addendum in log output.
 */
- (NSString *)logEntryPrefixForLevel:(PNLogLevel)level;

/**
 Compose correct log prefix basing on specified code symbol.
 */
- (NSString *)logEntryPrefixForSymbol:(NSString *)symbolCode;

/**
 Compose correct log entry message by specified code symbol.
 */
- (NSString *)logEntryMessageForSymbol:(NSString *)symbolCode;

/**
 Store currently accumulated console output into the file (if required.
 
 @param output
 If specified, this message will be placed into the dump if required, in case if this entry is empty, it will force data
 storage.
 */
- (void)dumpConsoleOutput:(NSString *)output;

/**
 Perform log rotation if required (depending on whether current log file reached limit or not).
 */
- (void)rotateDumpFiles;


#pragma mark - Handler methods

- (void)handleConsoleDumpTimer:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation PNLogger


#pragma mark - Class methods

+ (PNLogger *)sharedInstance {

    static PNLogger *_sharedInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{

        _sharedInstance = [self new];
    });


    return _sharedInstance;
}

+ (BOOL)isDebuggerAttached {
    
    static BOOL isDebuggerAttached;
    static dispatch_once_t debuggerCheckToken;
    dispatch_once(&debuggerCheckToken, ^{
#ifdef DEBUG
        struct kinfo_proc info;
        info.kp_proc.p_flag = 0;
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
        size_t size = sizeof(info);
        int junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
        assert(junk == 0);
        isDebuggerAttached = ((info.kp_proc.p_flag & P_TRACED) != 0);
#else
        isDebuggerAttached = NO;
#endif
    });
    
    
    return isDebuggerAttached;
}

+ (void)prepare {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Retrieve path to the 'Documents' folder
        NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        [self sharedInstance].dumpFilePath = [documentsFolder stringByAppendingPathComponent:kPNLoggerDumpFileName];
        [self sharedInstance].oldDumpFilePath = [documentsFolder stringByAppendingPathComponent:kPNLoggerOldDumpFileName];
        [self sharedInstance].httpPacketStoreFolderPath = [documentsFolder stringByAppendingPathComponent:@"http-response-dump"];
        [self sharedInstance].maximumDumpFileSize = kPNLoggerMaximumDumpFileSize;
        
        [[self sharedInstance] prepareForAsynchronousFileProcessing];
        [[self sharedInstance] prepareSymbols];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[self sharedInstance].httpPacketStoreFolderPath isDirectory:NULL]) {
            
            [fileManager createDirectoryAtPath:[self sharedInstance].httpPacketStoreFolderPath withIntermediateDirectories:YES
                                    attributes:nil error:NULL];
        }
        
        [[self sharedInstance] applyDefaultConfiguration];
    });
}

+ (void)logFrom:(id)sender forLevel:(PNLogLevel)level withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    // Ensure that user allowed message output for provided logging level.
    if ([[self sharedInstance] isLoggerEnabledFor:level] && parametersBlock) {

        // Checking whether logger allowed to log or dump console output.
        if ([self isLoggerEnabled] || [self isDumpingToFile]) {
            
            NSArray *parameters = parametersBlock();
            NSString *message = @"";
            NSString *messageToStore = @"";
            if ([parameters count] == 1 && [[self sharedInstance] logEntryMessageForSymbol:[parameters lastObject]].length == 0) {
                
                message = [parameters lastObject];
                messageToStore = message;
            }
            else if ([parameters count]){
                
                // Extract symbol code and clear parameters array to be ready for format.
                NSString *symbolCode = [parameters objectAtIndex:0];
                NSString *symbolPrefix = [[self sharedInstance] logEntryPrefixForSymbol:symbolCode];
                parameters = [parameters subarrayWithRange:NSMakeRange(1, ([parameters count] - 1))];
                
                // Checking whether logger should print out log entries in console depending on user configuration
                // and on whether app is running through Xcode debugger connected to it or not.
                if ([self isLoggerEnabled] && [self isDebuggerAttached]) {
                    
                    // Composing initial entry prefix
                    message = [NSString stringWithFormat:@"%@ (%p) %@%@", NSStringFromClass([sender class]), sender,
                               (symbolPrefix ? symbolPrefix : @""), [[self sharedInstance] logEntryMessageForSymbol:symbolCode]];
                    message = [NSString pn_stringWithFormat:message argumentsArray:parameters];
                }
                
                if ([self isDumpingToFile]) {
                    
                    NSMutableArray *parametersForLog = [NSMutableArray arrayWithCapacity:([parameters count] + 1)];
                    
                    // Storing initial symbol code value
                    [parametersForLog addObject:symbolCode];
                    
                    // Storing sender address
                    [parametersForLog addObject:[NSString stringWithFormat:@"%p", sender]];
                    
                    // Transform parameters using description suitable for log
                    [parameters enumerateObjectsUsingBlock:^(id parameter, NSUInteger idx, BOOL *stop) {
                        
                        #pragma clang diagnostic push
                        #pragma clang diagnostic ignored "-Wundeclared-selector"
                        // Check whether parameter can be transformed for log or not
                        if ([parameter respondsToSelector:@selector(logDescription)]) {
                            
                            parameter = [parameter performSelector:@selector(logDescription)];
                            parameter = (parameter ? parameter : @"");
                        }
                        #pragma clang diagnostic pop
                        [parametersForLog addObject:parameter];
                    }];
                    
                    messageToStore = [parametersForLog componentsJoinedByString:@";sp;"];
                }
            }
            
            // Checking whether logger should print out log entries in console depending on user configuration
            // and on whether app is running through Xcode debugger connected to it or not.
            if ([self isLoggerEnabled] && [self isDebuggerAttached]) {
            
                NSLog(@"%@", message);
            }
            
            if ([self isDumpingToFile]) {
                
                [[self sharedInstance] dumpConsoleOutput:messageToStore];
            }
        }
    }
}

+ (void)logGeneralMessageFrom:(id)sender message:(NSString *(^)(void))messageBlock {
    
    [self logFrom:sender forLevel:PNLogGeneralLevel withParametersFromBlock:^NSArray *{
        
        return @[(messageBlock ? messageBlock() : @"nothing to say")];
    }];
}

+ (void)logGeneralMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogGeneralLevel withParametersFromBlock:parametersBlock];
}

+ (void)logReachabilityMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogReachabilityLevel withParametersFromBlock:parametersBlock];
}

+ (void)logDeserializerInfoMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogDeserializerInfoLevel withParametersFromBlock:parametersBlock];
}

+ (void)logDeserializerErrorMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogDeserializerErrorLevel withParametersFromBlock:parametersBlock];
}

+ (void)logConnectionHTTPPacketFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:self forLevel:PNLogConnectionLayerHTTPLoggingLevel withParametersFromBlock:parametersBlock];
}

+ (void)logConnectionErrorMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogConnectionLayerErrorLevel withParametersFromBlock:parametersBlock];
}

+ (void)logConnectionInfoMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogConnectionLayerInfoLevel withParametersFromBlock:parametersBlock];
}

+ (void)logCommunicationChannelErrorMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogCommunicationChannelLayerErrorLevel withParametersFromBlock:parametersBlock];
}

+ (void)logCommunicationChannelWarnMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogCommunicationChannelLayerWarnLevel withParametersFromBlock:parametersBlock];
}

+ (void)logCommunicationChannelInfoMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock {

    [self logFrom:sender forLevel:PNLogCommunicationChannelLayerInfoLevel withParametersFromBlock:parametersBlock];
}

+ (void)storeHTTPPacketData:(NSData *(^)(void))httpPacketBlock {

    if ([self isDumpingHTTPResponse]) {
        
        [self storeRAWHTTPPacket:YES dataDescription:nil withData:httpPacketBlock];
    }
}

+ (void)storeUnexpectedHTTPDescription:(NSString *)packetDescription packetData:(NSData *(^)(void))httpPacketBlock {
    
    [self storeRAWHTTPPacket:NO dataDescription:packetDescription withData:httpPacketBlock];
}

+ (void)storeRAWHTTPPacket:(BOOL)isExpectedResponse dataDescription:(NSString *)dataDescription
                  withData:(NSData *(^)(void))httpPacketBlock {
    
    if (httpPacketBlock) {
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        NSString *entryTimeToken = [[NSDate date] performSelector:@selector(logDescription)];
        NSString *baseFileName = [NSString stringWithFormat:@"%@response-%@",
                                  (!isExpectedResponse ? [NSString stringWithFormat:@"unexpected-"] : @""),
                                  entryTimeToken];
        NSString *packetName = [baseFileName stringByAppendingPathExtension:@"dmp"];
        NSString *packetDetailsName = [baseFileName stringByAppendingString:@"-details.dmp"];
        NSString *packetStorePath = [[self sharedInstance].httpPacketStoreFolderPath stringByAppendingPathComponent:packetName];
        
        NSString *detailsStorePath = nil;
        if (dataDescription) {
            
            detailsStorePath = [[self sharedInstance].httpPacketStoreFolderPath stringByAppendingPathComponent:packetDetailsName];
        }
        #pragma clang diagnostic pop
        
        NSData *packetData = httpPacketBlock();
        NSData *packetDescription = (dataDescription ? [dataDescription dataUsingEncoding:NSUTF8StringEncoding] : nil);
        dispatch_async([self sharedInstance].httpProcessingQueue, ^{

            if(![packetData writeToFile:packetStorePath atomically:YES]){
                
                NSLog(@"CAN'T SAVE DUMP: %@", packetData);
            }
            if(![packetDescription writeToFile:detailsStorePath atomically:YES]){
                
                NSLog(@"CAN'T SAVE DUMP: %@", packetData);
            }
        });
    }
}


#pragma mark - General logger state manipulation

+ (void)loggerEnabled:(BOOL)isLoggerEnabled {

    unsigned long configuration = [self sharedInstance].configuration;
    (isLoggerEnabled ? [PNBitwiseHelper addTo:&configuration bit:PNConsoleOutput] :
                       [PNBitwiseHelper removeFrom:&configuration bit:PNConsoleOutput]);
    [self sharedInstance].configuration = configuration;
}

+ (BOOL)isLoggerEnabled {

    return [PNBitwiseHelper is:[self sharedInstance].configuration containsBit:PNConsoleOutput];
}

+ (void)dumpToFile:(BOOL)shouldDumpToFile {

    BOOL isDumpingIntoFile = [self isDumpingToFile];
    unsigned long configuration = [self sharedInstance].configuration;
    (shouldDumpToFile ? [PNBitwiseHelper addTo:&configuration bit:PNConsoleDumpIntoFile] :
                        [PNBitwiseHelper removeFrom:&configuration bit:PNConsoleDumpIntoFile]);
    [self sharedInstance].configuration = configuration;

    if (isDumpingIntoFile != [self isDumpingToFile] && [self isDumpingToFile]) {

        [[self sharedInstance] rotateDumpFiles];
        if ([self isDumpingToFile] && ![self sharedInstance].consoleDumpTimer) {
            
            [self sharedInstance].consoleDumpTimer = [NSTimer timerWithTimeInterval:kPNLoggerDumpForceTimeout
                                                                             target:[self sharedInstance]
                                                                           selector:@selector(handleConsoleDumpTimer:)
                                                                           userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:[self sharedInstance].consoleDumpTimer forMode:NSRunLoopCommonModes];
        } else if (![self isDumpingToFile] && [[self sharedInstance].consoleDumpTimer isValid]) {
            
            [[self sharedInstance].consoleDumpTimer invalidate];
            [self sharedInstance].consoleDumpTimer = nil;
        }
    }
}

+ (BOOL)isDumpingToFile {

    return [PNBitwiseHelper is:[self sharedInstance].configuration containsBit:PNConsoleDumpIntoFile];
}

+ (NSString *)dumpFilePath {

    return [self sharedInstance].dumpFilePath;
}


#pragma mark - File dump manipulation methods

+ (void)setMaximumDumpFileSize:(NSUInteger)fileSize {

    [self sharedInstance].maximumDumpFileSize = fileSize;
}


#pragma mark - HTTP response dump methods

+ (void)dumpHTTPResponseToFile:(BOOL)shouldDumpHTTPResponseToFile {

    unsigned long configuration = [self sharedInstance].configuration;
    (shouldDumpHTTPResponseToFile ? [PNBitwiseHelper addTo:&configuration bit:PNHTTPResponseDumpIntoFile] :
                                    [PNBitwiseHelper removeFrom:&configuration bit:PNHTTPResponseDumpIntoFile]);
    [self sharedInstance].configuration = configuration;
}

+ (BOOL)isDumpingHTTPResponse {

    return [PNBitwiseHelper is:[self sharedInstance].configuration containsBit:PNHTTPResponseDumpIntoFile];
}


#pragma mark - Levels manipulation methods

+ (void)enableFor:(PNLogLevel)level {

    unsigned long configuration = [self sharedInstance].configuration;
    [PNBitwiseHelper addTo:&configuration bit:level];
    [self sharedInstance].configuration = configuration;
}

+ (void)disableFor:(PNLogLevel)level {

    unsigned long configuration = [self sharedInstance].configuration;
    [PNBitwiseHelper removeFrom:&configuration bit:level];
    [self sharedInstance].configuration = configuration;
}


#pragma mark - Instance methods

- (void)applyDefaultConfiguration {

    [[self class] loggerEnabled:(PNLOG_LOGGING_ENABLED == 1)];
    [[self class] dumpToFile:(PNLOG_STORE_LOG_TO_FILE == 1)];
    [[self class] dumpHTTPResponseToFile:(PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_STORING_ENABLED == 1)];

    PNLogLevel level = 0;
    #if PNLOG_GENERAL_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogGeneralLevel];
    #endif

    #if PNLOG_REACHABILITY_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogReachabilityLevel];
    #endif

    #if PNLOG_DESERIALIZER_INFO_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogDeserializerInfoLevel];
    #endif

    #if PNLOG_DESERIALIZER_ERROR_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogDeserializerErrorLevel];
    #endif

    #if PNLOG_COMMUNICATION_CHANNEL_LAYER_ERROR_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogCommunicationChannelLayerErrorLevel];
    #endif

    #if PNLOG_COMMUNICATION_CHANNEL_LAYER_INFO_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogCommunicationChannelLayerInfoLevel];
    #endif

    #if PNLOG_COMMUNICATION_CHANNEL_LAYER_WARN_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogCommunicationChannelLayerWarnLevel];
    #endif

    #if PNLOG_CONNECTION_LAYER_ERROR_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogConnectionLayerErrorLevel];
    #endif

    #if PNLOG_CONNECTION_LAYER_INFO_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogConnectionLayerInfoLevel];
    #endif

    #if PNLOG_CONNECTION_LAYER_RAW_HTTP_RESPONSE_LOGGING_ENABLED == 1
        [PNBitwiseHelper addTo:&level bit:PNLogConnectionLayerHTTPLoggingLevel];
    #endif
    
    [[self class] enableFor:level];
}

- (void)prepareForAsynchronousFileProcessing {

    self.consoleDump = [NSMutableData data];
    dispatch_queue_t dumpProcessingQueue = dispatch_queue_create("com.pubnub.logger-dump-processing", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(dumpProcessingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    [PNDispatchHelper retain:dumpProcessingQueue];
    self.dumpProcessingQueue = dumpProcessingQueue;
    [self openConsoleDumpChannel];
    
    dispatch_queue_t httpProcessingQueue = dispatch_queue_create("com.pubnub.logger-http-processing", DISPATCH_QUEUE_SERIAL);
    [PNDispatchHelper retain:httpProcessingQueue];
    self.httpProcessingQueue = httpProcessingQueue;
}

- (void)openConsoleDumpChannel {
    
    dispatch_async(self.dumpProcessingQueue, ^{
        
        dispatch_io_t consoleDumpStoringChannel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, [self.dumpFilePath UTF8String],
                                                                               (O_RDWR|O_CREAT|O_NONBLOCK|O_APPEND), (S_IRWXU|S_IRWXG|S_IRWXO),
                                                                               self.dumpProcessingQueue, ^(int error) {
               
               if (error != 0) {
                   
                   [self closeConsoleDumpChannel];
               }
           });
        [PNDispatchHelper retain:consoleDumpStoringChannel];
        self.consoleDumpStoringChannel = consoleDumpStoringChannel;
    });
}

- (void)closeConsoleDumpChannel {
    
    if (self.consoleDumpStoringChannel) {
        
        dispatch_async(self.dumpProcessingQueue, ^{
            
            if (self.consoleDumpStoringChannel) {
                
                dispatch_io_close(self.consoleDumpStoringChannel, 0);
                [PNDispatchHelper release:self.consoleDumpStoringChannel];
                self.consoleDumpStoringChannel = NULL;
            }
        });
    }
}

- (BOOL)isLoggerEnabledFor:(PNLogLevel)level {

    return [PNBitwiseHelper is:self.configuration containsBit:level];
}

- (void)prepareSymbols {
    
    NSDictionary *symbolsTree = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PNLoggerSymbols"
                                                                                                           ofType:@"plist"]];
    if (symbolsTree) {

        NSMutableDictionary *flattenedTree = [NSMutableDictionary dictionary];
        NSMutableDictionary *symbolsSectionName = [NSMutableDictionary dictionary];
        
        __block __pn_desired_weak void(^symbolsFlatteningBlockWeak)(NSString *, NSString *, id, BOOL *);
        void(^symbolsFlatteningBlock)(NSString *, NSString *, id, BOOL *);

        symbolsFlatteningBlockWeak = symbolsFlatteningBlock = ^(NSString *groupCode, NSString *entryCode,
                                                                id entryContent, BOOL *entryEnumeratorStop){
            
            if ([entryContent isKindOfClass:[NSString class]]) {
                
                if ([entryCode isEqualToString:@"name"]) {
                    
                    // Storing group name by code
                    [symbolsSectionName setValue:entryContent forKeyPath:groupCode];
                }
                else {
                    
                    [flattenedTree setValue:entryContent forKeyPath:entryCode];
                }
            }
            else if ([entryContent isKindOfClass:[NSDictionary class]]) {
                
                [entryContent enumerateKeysAndObjectsUsingBlock:^(NSString *subGroupEntryCode, id subEntryContent, BOOL *subEntryEnumeratorStop){
                    
                    symbolsFlatteningBlockWeak(entryCode, subGroupEntryCode, subEntryContent, subEntryEnumeratorStop);
                }];
            }
        };
        [symbolsTree enumerateKeysAndObjectsUsingBlock:^(NSString *groupCode, NSDictionary *groupCodeTable, BOOL *groupCodeEnumeratorStop) {
            
            [groupCodeTable enumerateKeysAndObjectsUsingBlock:^(NSString *entryCode, id entryContent, BOOL *entryEnumeratorStop){
                
                symbolsFlatteningBlock(groupCode, entryCode, entryContent, entryEnumeratorStop);
            }];
        }];
        
        // Storing processed tree with immutable container.
        self.symbolsTable = [NSDictionary dictionaryWithDictionary:flattenedTree];
        self.symbolsSectionName = [NSDictionary dictionaryWithDictionary:symbolsSectionName];
    }
    else {
        
        NSLog(@"{WARNING} SYMBOLS TABLE CAN'T BE LOADED");
    }
}

- (NSString *)logEntryPrefixForLevel:(PNLogLevel)level {

    NSString *prefix = @"";
    PNLogLevel reachabilityMask = PNLogReachabilityLevel;
    PNLogLevel infoMask = (PNLogDeserializerInfoLevel|PNLogConnectionLayerInfoLevel|
                           PNLogConnectionLayerHTTPLoggingLevel|PNLogCommunicationChannelLayerInfoLevel);
    PNLogLevel errorMask = (PNLogDeserializerErrorLevel|PNLogConnectionLayerErrorLevel|
                            PNLogCommunicationChannelLayerErrorLevel);
    PNLogLevel warnMask = (PNLogDeserializerErrorLevel|PNLogConnectionLayerErrorLevel|
                           PNLogCommunicationChannelLayerErrorLevel);
    if ([PNBitwiseHelper is:level containsBit:reachabilityMask]) {

        prefix = @"{REACHABILITY} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:infoMask]) {

        prefix = @"{INFO} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:errorMask]) {

        prefix = @"{ERROR} ";
    }
    else if ([PNBitwiseHelper is:level containsBit:warnMask]) {

        prefix = @"{WARN} ";
    }


    return prefix;
}

/**
 Compose correct log prefic basing on specified code symbol.
 */
- (NSString *)logEntryPrefixForSymbol:(NSString *)symbolCode {
    
    NSString *prefix = nil;
    NSString *baseGroupName = [self.symbolsSectionName valueForKey:[symbolCode substringToIndex:2]];
    NSString *subGroupName = [self.symbolsSectionName valueForKey:[symbolCode substringToIndex:4]];
    
    if (baseGroupName) {
        
        if ([baseGroupName rangeOfString:@"CONNECTION"].location != NSNotFound) {
            
            prefix = [NSString stringWithFormat:@"[%@::%%@%@", baseGroupName,
                      (subGroupName ? [NSString stringWithFormat:@"::%@] ", subGroupName] : @"] ")];
        }
        else if ([baseGroupName rangeOfString:@"CHANNEL"].location != NSNotFound) {
            
            prefix = [NSString stringWithFormat:@"[%@::%%@] ", baseGroupName];
        }
    }
    
    
    return prefix;
}

- (NSString *)logEntryMessageForSymbol:(NSString *)symbolCode {
    
    NSString *message = @"";
    if ([self.symbolsTable objectForKey:symbolCode]) {
        
        message = [self.symbolsTable valueForKey:symbolCode];
    }
    
    
    return message;
}

- (void)dumpConsoleOutput:(NSString *)output {
    
    dispatch_async(self.dumpProcessingQueue, ^{
        
        if (output) {
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.consoleDump appendData:[[NSString stringWithFormat:@";ls;%@;sp;%@;le;\n", [[NSDate date] performSelector:@selector(logDescription)], output]
                                          dataUsingEncoding:NSUTF8StringEncoding]];
            #pragma clang diagnostic pop
        }
        
        if (([self.consoleDump length] >= kPNLoggerMaximumInMemoryLogSize || !output) && [self.consoleDump length] > 0) {
            
            if (self.consoleDumpStoringChannel) {
                
                dispatch_data_t data = dispatch_data_create([self.consoleDump bytes], [self.consoleDump length],
                                                            self.dumpProcessingQueue, NULL);
                [self.consoleDump setLength:0];
                dispatch_io_write(self.consoleDumpStoringChannel, 0, data, self.dumpProcessingQueue,
                                  ^(bool done, dispatch_data_t data, int error) {
                                      
                                      if (!done && error != 0) {
                                          
                                          NSLog(@"PNLog: Can't write into file (%@)", [self dumpFilePath]);
                                          [self closeConsoleDumpChannel];
                                      }
                                  });
            }
            else {
                
                FILE *consoleDumpFilePointer = fopen([[self dumpFilePath] UTF8String], "a+");
                if (consoleDumpFilePointer == NULL) {
                    
                    NSLog(@"PNLog: Can't open console dump file (%@)", [self dumpFilePath]);
                }
                else {
                    
                    fwrite([self.consoleDump bytes], [self.consoleDump length], 1, consoleDumpFilePointer);
                    fclose(consoleDumpFilePointer);
                    [self.consoleDump setLength:0];
                }
            }
        }
    });
}

- (void)rotateDumpFiles {

    if ([[self class] isDumpingToFile]) {
        
        [self dumpConsoleOutput:nil];
        [self closeConsoleDumpChannel];
        dispatch_async(self.dumpProcessingQueue, ^{
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:self.dumpFilePath]) {
                
                NSError *attributesFetchError = nil;
                NSDictionary *fileInformation = [fileManager attributesOfItemAtPath:self.dumpFilePath error:&attributesFetchError];
                if (attributesFetchError == nil) {
                    
                    unsigned long long consoleDumpFileSize = [(NSNumber *)[fileInformation valueForKey:NSFileSize] unsignedLongLongValue];
                    
                    NSLog(@"PNLog: Current console dump file size is %lld bytes (maximum allowed: %lu bytes)",
                          consoleDumpFileSize, (unsigned long)self.maximumDumpFileSize);
                    
                    if (consoleDumpFileSize > self.maximumDumpFileSize) {
                        
                        NSError *oldLogDeleteError = nil;
                        if ([fileManager fileExistsAtPath:self.oldDumpFilePath]) {
                            
                            [fileManager removeItemAtPath:self.oldDumpFilePath error:&oldLogDeleteError];
                        }
                        
                        if (oldLogDeleteError == nil) {
                            
                            NSError *fileCopyError;
                            [fileManager copyItemAtPath:self.dumpFilePath toPath:self.oldDumpFilePath error:&fileCopyError];
                            
                            if (fileCopyError == nil) {
                                
                                if ([fileManager fileExistsAtPath:self.dumpFilePath]) {
                                    
                                    NSError *currentLogDeleteError = nil;
                                    [fileManager removeItemAtPath:self.dumpFilePath error:&currentLogDeleteError];
                                    
                                    if (currentLogDeleteError != nil) {
                                        
                                        NSLog(@"PNLog: Can't remove current console dump log (%@) because of error: %@",
                                              self.dumpFilePath, currentLogDeleteError);
                                    }
                                }
                            }
                            else {
                                
                                NSLog(@"PNLog: Can't copy current log (%@) to new location (%@) because of error: %@",
                                      self.dumpFilePath, self.oldDumpFilePath, fileCopyError);
                            }
                        }
                        else {
                            
                            NSLog(@"PNLog: Can't remove old console dump log (%@) because of error: %@",
                                  self.oldDumpFilePath, oldLogDeleteError);
                        }
                    }
                }
                [self openConsoleDumpChannel];
            }
        });
    }
}


#pragma mark - Handler methods

- (void)handleConsoleDumpTimer:(NSTimer *)timer {
    
    [self dumpConsoleOutput:nil];
}


#pragma mark - Misc methods

- (void)dealloc {

    if (_consoleDumpStoringChannel) {
        
        dispatch_io_close(_consoleDumpStoringChannel, 0);
    }
    [PNDispatchHelper release:_consoleDumpStoringChannel];
    _consoleDumpStoringChannel = NULL;
    _consoleDump = nil;
    [PNDispatchHelper release:_dumpProcessingQueue];
    _dumpProcessingQueue = NULL;
    [PNDispatchHelper release:_httpProcessingQueue];
    _httpProcessingQueue = NULL;
}

#pragma mark -


@end
