//
//  PNLoggerSymbols.h
//  pubnub
//
//  Created by Sergey Mamontov on 8/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#ifndef pubnub_PNLoggerSymbols_h
#define pubnub_PNLoggerSymbols_h

struct PNLoggerSymbolsStructure {
    
    /**
     Symbol tree format: GCxxyyy
     GC - main group code
     xx - sub-groups code
     yyy - actual symbol code
     */
    
    // Connection instance log symbols. Group code: 01xxyyy
    struct {
        
        // Parameters requirements: [code, connection name, whether by user request or not, connection bit field with state]
        __unsafe_unretained NSString *connectionAttempt;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionInProgress;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reconnectionInProgress;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionResumingInProgress;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *outOfSyncWithStateForciblyReconnect;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *alreadyConnecting;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *alreadyConnected;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *triedToConnectDuringDisconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *notConfigured;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionImpossibleAtCurrentMoment;
        
        // Parameters requirements: [code, connection name, current iteration, possible attempts count, connection bit field with state]
        __unsafe_unretained NSString *connectionRetry;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryAttempt;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryOnSSLError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryOnTemporaryConnectionIssues;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryImpossibleAtCurrentMoment;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryCanceledBecauseStateAltered;
        
        // Parameters requirements: [code, connection name, whether by user request or not, connection bit field with state]
        __unsafe_unretained NSString *disconnectionAttempt;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectedOnRetryAttempt;
        
        // Parameters requirements: [code, connection name, whether by user request or not, connection bit field with state]
        __unsafe_unretained NSString *connected;
        
        // Parameters requirements: [code, connection name, whether by user request or not, connection bit field with state]
        __unsafe_unretained NSString *reconnected;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *resumed;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reconnectedAfterError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reconnectedOnWakeUpTimerRequest;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reconnectedBecauseOfSSLError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reconnectedBecauseOfTemporaryConnectionIssues;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedWithFurtherReconnectionBecauseOfError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedOnRetryAttemptWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reconnectFromTheUserName;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedWithFurtherConnectionOnUserRequest;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedOnExpectedCloseWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedOnConnectionResetWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedOnWakeUpTimerRequestWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedBecauseOfSSLErrorWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedBecauseOfTemporaryConnectionIssuesWithFurtherReconnection;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedByUserRequest;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closedBecauseOfError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *suspended;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *disconnected;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *disconnectedBecauseOfError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *notifyDelegateAboutDisconnection;
        
        // Parameters requirements: [code, connection name, request identifier, connection bit field with state]
        __unsafe_unretained NSString *unscheduleRequestProcessing;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *handleTimeoutTimer;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *handleWakeUpTimer;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *stillInBadState;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *stateCanBeRecovered;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *wakeUpEventCanceledBecauseStateHasBeenAltered;
        
        // Parameters requirements: [code, connection name, PNError instance, CFNetwork error code, error domain, whether connection should be closed or not, connection bit field with state]
        __unsafe_unretained NSString *error;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *errorOnSSLLevel;
        
        // Parameters requirements: [code, connection name, whether SSL level can be reduced, connection bit field with state]
        __unsafe_unretained NSString *isSSLLevelReductionAllowed;
        
        // Parameters requirements: [code, connection name, whether SSL can be discarded, connection bit field with state]
        __unsafe_unretained NSString *isSSLDiscardingAllowed;
        
        // Parameters requirements: [code, connection name, current SSL configuration level, connection bit field with state]
        __unsafe_unretained NSString *currentSSLConfigurationLevel;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *reduceSSLSecurityLevel;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *discardSSLLeyer;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *internalSSLError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *generalError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *generalErrorBecauseOfServerActions;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *generalErrorOfTemporaryConnectionIssues;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *internetConnectionFailure;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *uplinkConnectionFailure;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryAttemptIsPossible;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryAttemptImpossible;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closingConnectionBecauseOfError;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *closingConnectionBecauseOfErrorWhileTriedToConnect;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *fetchingProxyConfiguration;
        
        // Parameters requirements: [code, connection name, dictionary with proxy information, connection bit field with state]
        __unsafe_unretained NSString *proxyConfigurationInformation;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *proxyConfigurationNotRequired;
        
        // Parameters requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *destroyed;
        
        // Parameters requirements: [code, connection name, response deserializer instance memory address]
        __unsafe_unretained NSString *resourceLinkage;
        
        // Parameter requirements: [code, connection name, connection bit field with state]
        __unsafe_unretained NSString *connectionRetryAttemptInProgress;
        
        // Connection instance streams log symbols. Group code: 0110yyy
        struct {
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *prepareForUsage;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationStarted;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationFailed;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationCompleted;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationCompletedEarlier;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationCompletedEarlierAndConnecting;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationCompletedEarlierAndResuming;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationCompletedEarlierAndConnected;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *destroying;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *destroyed;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *opened;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *closed;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationError;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationRetryAttempt;
            
            // Parameters requirements: [code, connection name, connection bit field with state]
            __unsafe_unretained NSString *configurationRetryAttemptsExceeded;
            
            // Connection instance read stream log symbols. Group code: 0111yyy
            struct {
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *configurationStarted;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *configurationFailed;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *configurationCompleted;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *initOpening;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *unableToOpen;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *opening;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *opened;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *disconnecting;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *destroying;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *destroyed;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *hasData;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *error;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *cantAcceptDataAnymore;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *readingArrivedData;
                
                // Parameters requirements: [code, connection name, number of readed bytes, connection bit field with state]
                __unsafe_unretained NSString *readedPortionOfArrivedData;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *deserializerIsBusy;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *readingError;
                
                // Parameters requirements: [code, connection name, number of correct responses, connection bit field with state]
                __unsafe_unretained NSString *processedArrivedData;
                
                // Parameters requirements: [code, connection name, number of butes in secondary storage, connection bit field with state]
                __unsafe_unretained NSString *processingAdditionalData;
                
                // Parameters requirements: [code, connection name, response, connection bit field with state]
                __unsafe_unretained NSString *rawHTTPResponse;
            } read;
            
            // Connection instance write stream log symbols. Group code: 0112yyy
            struct {
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *configurationStarted;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *configurationFailed;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *configurationCompleted;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *initOpening;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *unableToOpen;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *opening;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *opened;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *disconnecting;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *destroying;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *destroyed;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *alreadySendingData;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *canSendData;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *error;
                
                // Parameters requirements: [code, connection name, stringified even status, connection bit field with state]
                __unsafe_unretained NSString *cantSendDataAnymore;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *writeDataFromBuffer;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *dataWriteError;
                
                // Parameters requirements: [code, connection name, written bytes count, total number of bytes, connection bit field with state]
                __unsafe_unretained NSString *writenDataFromBufferAtOnce;
                
                // Parameters requirements: [code, connection name, written bytes count, total number of bytes, connection bit field with state]
                __unsafe_unretained NSString *writenPartOfDataFromBuffer;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *writeCanceled;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *unableProcessNextRequestOnConnectionTermination;
                
                // Parameters requirements: [code, connection name, connection bit field with state]
                __unsafe_unretained NSString *nothingToWrite;
            } write;
        } stream;
    } connection;
    
    // Connection channel instance symbols. Group code: 02xxyyy
    struct {
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *connectionAttempt;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *outOfSyncWithConnection;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *connecting;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *disconnectingWithEvent;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *disconnectingWithOutEvent;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *disconnected;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *outOfSyncWithDisconnection;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *disconnecting;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *alreadyDisconnected;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *suspensionAttempt;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *outOfSyncWithSuspension;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *suspending;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *resumeAttempt;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *outOfSyncWithResuming;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *resuming;
        
        // Parameters requirements: [code, connection channel name, PNBaseRequest instance, connection channel bit field with state]
        __unsafe_unretained NSString *ignoreScheduledRequest;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *reconnectingByRequest;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *configurationFailed;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleConnectionReset;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleConnectionReady;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *connected;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleSuspension;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *suspended;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleResume;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *resumed;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *willRestoreConnection;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleConnectionRestore;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *connectionRestored;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *willRestoreConnectionAfterError;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleConnectionRestoreAfterError;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleDisconnectionBecauseOfError;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *disconnectedBecauseOfError;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleDisconnection;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *connectionRestoredAfterClosingByServerRequest;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *closingConnectionByServerRequest;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *disconnectedByServerRequest;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *handleConnectionFailedBecauseOfError;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *connectionFailedBecauseOfError;
        
        // Parameters requirements: [code, connection channel name, PNResponse instance with malformed data, connection channel bit field with state]
        __unsafe_unretained NSString *malformedJSONPResponse;
        
        // Parameters requirements: [code, connection channel name, PNResponse instance, connection channel bit field with state]
        __unsafe_unretained NSString *receivedResponse;
        
        // Parameters requirements: [code, connection channel name, PNBaseRequest instance, connection channel bit field with state]
        __unsafe_unretained NSString *reschedulingRequest;
        
        // Parameters requirements: [code, connection channel name, PNBaseRequest instance, connection channel bit field with state]
        __unsafe_unretained NSString *requestRescheduleImpossible;
        
        // Parameters requirements: [code, connection channel name, reference on connection memory address, connection channel bit field with state]
        __unsafe_unretained NSString *connectionReset;
        
        // Parameters requirements: [code, connection channel name, connection channel bit field with state]
        __unsafe_unretained NSString *destroyed;
        
        // Parameters requirements: [code, connection channel name, request queue instance memory address, connection instance memory address]
        __unsafe_unretained NSString *resourceLinkage;
        
        // Blocking request connection channel symbols. Group code: 0201yyy
        struct {
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *leaveAllChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *leaveSpecificChannels;
            
            // Parameters requirements: [code, connection channel name, whether last time token should be used or not, connection channel bit field with state]
            __unsafe_unretained NSString *restoringSubscription;
            
            // Parameters requirements: [code, connection channel name, whether last time token should be used or not, connection channel bit field with state]
            __unsafe_unretained NSString *resubscribeOnIdle;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *updateSubscriptionWithNewTimeToken;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *subscriptionUpdateCanceled;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *enablingPresenceOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *enablingPresenceAndSubscribingOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *enablingDisablingPresenceOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *enablingDisablingPresenceAndSubscribingOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *disablingPresenceOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *disablingPresenceAndSubscribingOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *subscribingOnSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *subscribedOnSetOfChannelsEarlier;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *enabledPresenceOnSetOfChannelsEarlier;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *disabledPresenceOnSetOfChannelsEarlier;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *subscribingOnPreviousChannels;
            
            // Parameters requirements: [code, connection channel name, connection channel bit field with state]
            __unsafe_unretained NSString *leaveRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNError instance, list of channels for which request failed, connection channel bit field with state]
            __unsafe_unretained NSString *leaveRequestFailed;
            
            // Parameters requirements: [code, connection channel name, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *unsubscribedFromSetOfChannels;
            
            // Parameters requirements: [code, connection channel name, PNBaseRequest which generated response, list of channels, PNResponse instance with data, connection channel bit field with state]
            __unsafe_unretained NSString *handleEvent;
            
            // Parameters requirements: [code, connection channel name, data, connection channel bit field with state]
            __unsafe_unretained NSString *parsedData;
            
            // Parameters requirements: [code, connection channel name, PNError instance, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *subscribeError;
            
            // Parameters requirements: [code, connection channel name, PNError instance, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *presenceEnablingError;
            
            // Parameters requirements: [code, connection channel name, PNError instance, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *presenceDisablingError;
            
            // Parameters requirements: [code, connection channel name, request, connection channel bit field with state]
            __unsafe_unretained NSString *willStartRequestSending;
            
            // Parameters requirements: [code, connection channel name, request, whether waiting for request completion, connection channel bit field with state]
            __unsafe_unretained NSString *sentRequest;
            
            // Parameters requirements: [code, connection channel name, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *subscriptionRestored;
            
            // Parameters requirements: [code, connection channel name, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *subscriptionCompleted;
            
            // Parameters requirements: [code, connection channel name, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *enabledPresence;
            
            // Parameters requirements: [code, connection channel name, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *disabledPresence;
            
            // Parameters requirements: [code, connection channel name, list of channels, connection channel bit field with state]
            __unsafe_unretained NSString *leaved;
            
            // Parameters requirements: [code, connection channel name, request, PNError instance, connection channel bit field with state]
            __unsafe_unretained NSString *requestSendingFailed;
            
            // Parameters requirements: [code, connection channel name, request, connection channel bit field with state]
            __unsafe_unretained NSString *requestSendingCanceled;
        } subscribe;
        
        // Non-blocking request connection channel symbols. Group code: 0202yyy
        struct {
            
            // Parameters requirements: [code, connection channel name]
            __unsafe_unretained NSString *latencyMeterRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNError instance]
            __unsafe_unretained NSString *latencyMeterRequestDidFail;
            
            // Parameters requirements: [code, connection channel name, NSNumber instance]
            __unsafe_unretained NSString *timeTokenRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNError instance]
            __unsafe_unretained NSString *timeTokenRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNClient instance]
            __unsafe_unretained NSString *clientStateAuditRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNError instance, PNClient instance]
            __unsafe_unretained NSString *clientStateAuditRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNClient instance]
            __unsafe_unretained NSString *clientStateUpdateRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNError instance, PNClient instance]
            __unsafe_unretained NSString *clientStateUpdateRequestFailed;
            
            // Parameters requirements: [code, connection channel name, message payload, PNChannel instance]
            __unsafe_unretained NSString *messageSendRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, message payload, PNChannel instance, PNError instance]
            __unsafe_unretained NSString *messageSendRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNChannel instance, start PNDate instance, end PNDate instance, limit, whether messages should be revresed, whether time token should be included, list of PNMessage instances]
            __unsafe_unretained NSString *historyRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNChannel instance, start PNDate instance, end PNDate instance, limit, whether messages should be revresed, whether time token should be included, PNError instance]
            __unsafe_unretained NSString *historyRequestFailed;
            
            // Parameters requirements: [code, connection channel name, list of PNChannel instances, whether client identifiers should be pulled, whether clien't state should be pulled, PNHereNow instance]
            __unsafe_unretained NSString *participantsListRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, list of PNChannel instances, whether client identifiers should be pulled, whether clien't state should be pulled, PNError instance]
            __unsafe_unretained NSString *participantsListRequestFailed;
            
            // Parameters requirements: [code, connection channel name, client identifier, list of PNChannel instances]
            __unsafe_unretained NSString *participantChannelsListRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, client identifier, PNError instance]
            __unsafe_unretained NSString *participantChannelsListRequestFailed;
            
            // Parameters requirements: [code, connection channel name, NSData instance, list of PNChannel instances]
            __unsafe_unretained NSString *pushNotificationEnableRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, NSData instance, list of PNChannel instances, PNError instance]
            __unsafe_unretained NSString *pushNotificationEnableRequestFailed;
            
            // Parameters requirements: [code, connection channel name, NSData instance, list of PNChannel instances]
            __unsafe_unretained NSString *pushNotificationDisableRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, NSData instance, list of PNChannel instances, PNError instance]
            __unsafe_unretained NSString *pushNotificationDisableRequestFailed;
            
            // Parameters requirements: [code, connection channel name, NSData instance]
            __unsafe_unretained NSString *pushNotificationRemoveRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, NSData instance, PNError instance]
            __unsafe_unretained NSString *pushNotificationRemoveRequestFailed;
            
            // Parameters requirements: [code, connection channel name, NSData instance, list of PNChannel instances]
            __unsafe_unretained NSString *pushNotificationsAuditRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, NSData instance, PNError instance]
            __unsafe_unretained NSString *pushNotificationsAuditRequestFailed;
            
            // Parameters requirements: [code, connection channel name, list of client identifiers, list of PNChannel instances, access rights, duration, PNAccessRightsCollection instasnce]
            __unsafe_unretained NSString *accessRightsChangeRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, list of client identifiers, list of PNChannel instances, access rights, duration, PNError instance]
            __unsafe_unretained NSString *accessRightsChangeRequestFailed;
            
            // Parameters requirements: [code, connection channel name, list of client identifiers, list of PNChannel instances, PNAccessRightsCollection instasnce]
            __unsafe_unretained NSString *accessRightsAuditRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, list of client identifiers, list of PNChannel instances, PNError instance]
            __unsafe_unretained NSString *accessRightsAuditRequestFailed;
            
            // Parameters requirements: [code, connection channel name, id instance]
            __unsafe_unretained NSString *parsedData;
            
            // Parameters requirements: [code, connection channel name, PNBaseRequest instance]
            __unsafe_unretained NSString *observerRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNBaseRequest instance]
            __unsafe_unretained NSString *willStartRequestProcessing;
            
            // Parameters requirements: [code, connection channel name, PNBaseRequest instance]
            __unsafe_unretained NSString *didSendRequest;
            
            // Parameters requirements: [code, connection channel name, PNBaseRequest instance]
            __unsafe_unretained NSString *requestSendingDidFail;
            
            // Parameters requirements: [code, connection channel name]
            __unsafe_unretained NSString *requestWontBeSent;
            
            // Parameters requirements: [code, connection channel name]
            __unsafe_unretained NSString *latencyMeterRequestSent;
            
            // Parameters requirements: [code, connection channel name]
            __unsafe_unretained NSString *latencyMeterRequestSendingCanceled;
            
            // Parameters requirements: [code, connection channel name]
            __unsafe_unretained NSString *messagePostRequestSent;
            
            // Parameters requirements: [code, connection channel name, namespace name, NSArray of group names]
            __unsafe_unretained NSString *channelGroupsRetrieveRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, namespace name, PNError instance]
            __unsafe_unretained NSString *channelGroupsRetrieveRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance, list of PNChannel instances]
            __unsafe_unretained NSString *channelsForGroupRetrieveRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance, PNError instance]
            __unsafe_unretained NSString *channelsForGroupRetrieveRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance]
            __unsafe_unretained NSString *channelsAdditionToGroupRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance, PNError instance]
            __unsafe_unretained NSString *channelsAdditionToGroupRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance]
            __unsafe_unretained NSString *channelsRemovalFromGroupRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance, PNError instance]
            __unsafe_unretained NSString *channelsRemovalFromGroupRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNChannel instance list]
            __unsafe_unretained NSString *channelGroupNamespacesRetrievalRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNError instance]
            __unsafe_unretained NSString *channelGroupNamespacesRetrievalRequestFailed;
            
            // Parameters requirements: [code, connection channel name, namespace name]
            __unsafe_unretained NSString *channelGroupNamespaceRemovalRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, namespace name, PNError instance]
            __unsafe_unretained NSString *channelGroupNamespaceRemovalRequestFailed;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance]
            __unsafe_unretained NSString *channelGroupRemovalRequestCompleted;
            
            // Parameters requirements: [code, connection channel name, PNChannelGroup instance, PNError instance]
            __unsafe_unretained NSString *channelGroupRemovalRequestFailed;
        } service;
        
    } connectionChannel;
    
    // Request symbols. Group code: 03xxyyy
    struct {
        
        // Parameters requirements: [code, method signature]
        __unsafe_unretained NSString *methodRequiresOwnImplementation;
        
        // Message post request symbols. Group code: 0301yyy
        struct {
            
            // Parameters requirements: [code, PNError instance]
            __unsafe_unretained NSString *messageBodyEncryptionError;
        } messagePost;
        
    } requests;
    
    // Reachability symbols. Group code: 04xxyyy
    struct {
        
        // Parameters requirements: [code, flags, human readable flags, whether connection available or not]
        __unsafe_unretained NSString *reachabilityFlagsChangedOnCallback;
        
        // Parameters requirements: [code, human readable flags, human readable flags from lookup, whether connection available or not]
        __unsafe_unretained NSString *reachabilityFlagsChangeIgnoredOnCallback;
        
        // Parameters requirements: [code, human readable flags, whether connection available or not]
        __unsafe_unretained NSString *reachabilityFlagsChangesWhileSuspendedOnCallback;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *startReachabilityObservation;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *restartReachabilityObservation;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *reachabilityObservationCantBeUsedWithOutOrigin;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *stopReachabilityObservation;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *suspendedReachabilityObservation;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *resumedReachabilityObservation;
        
        // Parameters requirements: [code, NSError instance]
        __unsafe_unretained NSString *lookupFailedWithError;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *malformedLookupResponse;
        
        // Parameters requirements: [code, status code]
        __unsafe_unretained NSString *unacceptableLookupResponseStatusCode;
        
        // Parameters requirements: [code, human readable interface name]
        __unsafe_unretained NSString *uplinkRestored;
        
        // Parameters requirements: [code, human readable interface name]
        __unsafe_unretained NSString *uplinkWentDown;
        
        // Parameters requirements: [code, human readable interface name]
        __unsafe_unretained NSString *uplinkStillDown;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *uplinkStateChangedDuringSuspension;
        
        // Parameters requirements: [code, old human readable flags, human readable flags, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityFlagsRefresh;
        
        // Parameters requirements: [code, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityForcedFlagsChangeOnRefresh;
        
        // Parameters requirements: [code, human readable flags, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityFlagsChangedOnRefresh;
        
        // Parameters requirements: [code, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityFlagsChangedWithOutEventOnRefresh;
        
        // Parameters requirements: [code, human readable flags, human readable flags from lookup, whether connection available or not]
        __unsafe_unretained NSString *reachabilityFlagsChangeIgnoredOnRefresh;
        
        // Parameters requirements: [code, current network address, new network address, whether connection available or not, flags]
        __unsafe_unretained NSString *reachabilityNetworkAddressChangedOnSet;
        
        // Parameters requirements: [code, current network SSID, new network SSID, whether connection available or not, flags]
        __unsafe_unretained NSString *reachabilityHotspotChangedOnSet;
        
        // Parameters requirements: [code, current network interface name, new network interface name, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityInterfaceChangedOnSet;
        
        // Parameters requirements: [code, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityForcedFlagsChangeOnSet;
        
        // Parameters requirements: [code, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityFlagsChangeEventGeneratedOnSet;
        
        // Parameters requirements: [code, human readable flags, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *reachabilityFlagsChangedOnSet;
        
        // Parameters requirements: [code, new human readable flags, human readable flags, whether connection available or not, network address, flags]
        __unsafe_unretained NSString *unknownReachabilityFlagsOnSet;
    } reachability;
    
    // Deserializer symbols. Group code: 05xxyyy
    struct {
        
        // Parameters requirements: [code, content length, response content]
        __unsafe_unretained NSString *unableToEncodeResponseData;
        
        // Parameters requirements: [code, status code, response content]
        __unsafe_unretained NSString *unexpectedResponseStatusCode;
        
        // Parameters requirements: [code, status code, raw response content]
        __unsafe_unretained NSString *rawResponseData;
    } deserializer;
    
    // Cryptor symbols. Group code: 06xxyyy
    struct {
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *destroyed;
    } cryptor;
    
    // Channels symbols. Group code: 07xxyyy
    struct {
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *nameRequired;
    } channel;
    
    // JSON serializer/deserializer symbols. Group code: 08xxyyy
    struct {
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *emptyJSONString;
        
        // Parameters requirements: [code, NSError instance]
        __unsafe_unretained NSString *JSONDecodeError;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *decodeFailed;
    } JSONserializer;
    
    // Core API access instance symbols. Group code: 09xxyyy
    struct {
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *reset;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionAttemptWithOutHandlerBlock;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionAttemptHandlerBlock;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *alreadyConnected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *alreadyConnecting;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *prepareCommunicationComponents;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionImpossibleWithOutConfiguration;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionAttemptDuringSuspension;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionAttemptDuringResume;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *reachabilityChecked;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *internetConnectionAvailable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *createNewCommunicationComponents;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *previousCommunicationComponentsHasBeenDestroyed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *reuseExistingCommunicationComponents;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *internetConnectionNotAvailableAtThisMoment;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *internetConnectionAvailabilityNotCheckedYet;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptByUserRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptByInternalRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnecting;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectingForConfigurationChange;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectedByUserRequest;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *disconnected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeDisconnected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptForConfigurationChange;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeDisconnectionForConfigurationChange;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *configurationUpdateAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *validConfigurationProvided;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *configurationUpdateRequireReconnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *configurationUpdateDoesntRequireReconnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *triedUpdateConfigurationDuringConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *sameConfigurationHasBeenProvided;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *clientIdentifierUpdateAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *updatingClientIdentifier;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeClientIdentifierUpdate;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *sameClientIdentifierProvided;
        
        // Parameters requirements: [code, client identifier, PNChannel instance, stringified state]
        __unsafe_unretained NSString *clientStateAuditAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *auditClientState;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *clientStateAuditionImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeClientStateAudit;
        
        // Parameters requirements: [code, client identifier, PNChannel instance, NSDictionary instance, stringified state]
        __unsafe_unretained NSString *clientStateChangeAttempt;
        
        // Parameters requirements: [code, NSDictionary instance, stringified state]
        __unsafe_unretained NSString *changeClientState;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *clientStateChangeImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeClientStateChange;
        
        // Parameters requirements: [code, array of PNChannel instances, whether should catchup with previous session, stringified state]
        __unsafe_unretained NSString *subscribeAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *subscribing;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *subscriptionImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeSubscription;
        
        // Parameters requirements: [code, array of PNChannel instances, stringified state]
        __unsafe_unretained NSString *unsubscribeAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *unsubscribing;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *unsubscriptionImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeUnsubscription;
        
        // Parameters requirements: [code, array of PNChannel instances, NSData instance, stringified state]
        __unsafe_unretained NSString *pushNotificationsEnableAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *enablingPushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationEnablingImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponePushNotificationEnabling;
        
        // Parameters requirements: [code, array of PNChannel instances, NSData instance, stringified state]
        __unsafe_unretained NSString *pushNotificationsDisableAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disablingPushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationDisablingImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponePushNotificationDisabling;
        
        // Parameters requirements: [code, NSData instance, stringified state]
        __unsafe_unretained NSString *pushNotificationsRemovalAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *removePushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationRemovalImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponePushNotificationRemoval;
        
        // Parameters requirements: [code, NSData instance, stringified state]
        __unsafe_unretained NSString *pushNotificationsAuditAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *auditPushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationAuditImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponePushNotificationAudit;
        
        // Parameters requirements: [code, array of PNChannel instances, array of identifiers, access rights, duration, stringified state]
        __unsafe_unretained NSString *accessRightsChangeAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *changeAccessRights;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *accessRightsChangeImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeAccessRightsChange;
        
        // Parameters requirements: [code, array of PNChannel instances, array of identifiers, stringified state]
        __unsafe_unretained NSString *accessRightsAuditAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *auditAccessRights;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *accessRightsAuditImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeAccessRightsAudit;
        
        // Parameters requirements: [code, array of PNChannel instances, stringified state]
        __unsafe_unretained NSString *presenceObservationEnableAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *enablingPresenceObservation;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *presenceObservationEnableImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponePresenceObservationEnable;
        
        // Parameters requirements: [code, array of PNChannel instances, stringified state]
        __unsafe_unretained NSString *presenceObservationDisableAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disablingPresenceObservation;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *presenceObservationDisableImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponePresenceObservationDisable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *timeTokenFetchAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *fetchingTimeToken;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *timeTokenFetchImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeTimeTokenFetch;
        
        // Parameters requirements: [code, message payload, PNChannel instance, whether message should be compressed or not, whether message should be stored in history or not, stringified state]
        __unsafe_unretained NSString *messageSendAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *sendingMessage;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *messageSendImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeMessageSending;
        
        // Parameters requirements: [code, PNChannel instance, PNDate start, PNDate end, limit, whether should traverse, whether should include time token, stringified state]
        __unsafe_unretained NSString *historyFetchAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *fetchingHistory;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *historyFetchImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeHistoryFetching;
        
        // Parameters requirements: [code, list of PNChannel instances, whether client identifiers should be included, stringified state]
        __unsafe_unretained NSString *participantsListRequestAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *requestingParticipantsList;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *participantsListRequestImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeParticipantsListRequest;
        
        // Parameters requirements: [code, client identifier, stringified state]
        __unsafe_unretained NSString *participantChannelsListRequestAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *requestingParticipantChannelsList;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *participantChannelsListRequestImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeParticipantChannelsListRequest;
        
        // Parameters requirements: [code, NSError/PNError instance]
        __unsafe_unretained NSString *messageDecryptionError;
        
        // Parameters requirements: [code, PNError instance]
        __unsafe_unretained NSString *messageEncryptionError;
        
        // Parameters requirements: [code, whether internet connection available or not, stringified state]
        __unsafe_unretained NSString *isConnected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectOnNetworkReachabilityCheck;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkAvailableProceedConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkNotAvailableReportError;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkAvailable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *previouslyDisconnectedBecauseOfError;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionStateImpossibleOnNetworkBecomeAvailable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *shouldRestoreConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *shouldResumeConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *shouldConnect;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *noSuitableActionsForCurrentSituation;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkNotAvailable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *triedToConnect;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkWentDownDuringConnectionRestoring;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkWentDownWhileSuspended;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkWentDownWhileWasConnected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *autoConnectionDisabled;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionWillBeRestoredOnNetworkConnectionRestore;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkWentDownBeforeConnectionCompletion;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *connectionChannelConnected;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *allConnectionChannelsConnected;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *connectionChannelReconnected;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *anotherConnectionChannelNotReconnectedYet;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *connectionChannelConnectionFailed;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *connectionFailed;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *DNSCacheKillAttempt;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *notifyDelegateConnectionCantBeEstablished;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *connectionChannelDisconnected;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *connectionChannelDisconnectedOnReleaseWithOutEvent;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *disconnectingServiceChannel;
        
        // Parameters requirements: [code, connection channel name, connection channel instance, stringified state]
        __unsafe_unretained NSString *disconnectingMessagingChannel;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *allConnectionChannelsDisconnected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionShouldBeRestoredOnReacabilityCheck;
        
        // Parameters requirements: [code, PNError instance, stringified state]
        __unsafe_unretained NSString *disconnectedBecauseOfError;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *destroyCommunicationComponents;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *alreadyRestoringConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *handleEnteredBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *unableToRunInBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *completeTasksBeforeCompleteTransitionToBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *suspendingOnTransitionToBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionAttemptWhileTransitToBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptWhileTransitToBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptBecauseOfErrorWhileTransitToBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *notInBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeSuspensionOnTransitionToBackground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *userDidntCallSuspensionOperationCompletionBlock;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *handleEnterForeground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *resumingConnection;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *previousConnectionWasTerminatedBecauseOfErrorOnTransitionToForeground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkConnectionWentDownWhileWasInBackgroundOnTransitionToForeground;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionWillRestoreOnNetworkAvailability;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *handleWorkspaceSleep;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *suspendingOnWorkspaceSleep;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *unableToSuspendOnWorkspaceSleep;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *connectionAttemptDuringWorkspaceSleep;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptDuringWorkspaceSleep;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *disconnectionAttemptBecauseOfErrorDuringWorkspaceSleep;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *handleWorkspaceWake;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *previousConnectionWasTerminatedBecauseOfErrorOnWorkspaceWeak;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *networkConnectionWentDownWhileWasInBackgroundOnWorkspaceWeak;
        
        // Parameters requirements: [code, PNError instance, stringified state]
        __unsafe_unretained NSString *cryptoInitializationFailed;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *connected;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *clientStateAuditFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *clientStateChangeFailed;
        
        // Parameters requirements: [code, list of PNChannel instance, stringified state]
        __unsafe_unretained NSString *resumingSubscription;
        
        // Parameters requirements: [code, list of PNChannel instance, PNError instance, stringified state]
        __unsafe_unretained NSString *subscriptionFailed;
        
        // Parameters requirements: [code, list of PNChannel instance, PNError instance, stringified state]
        __unsafe_unretained NSString *subscriptionOnClientIdentifierChangeFailed;
        
        // Parameters requirements: [code, list of PNChannel instance, PNError instance, stringified state]
        __unsafe_unretained NSString *unsubscriptionFailed;
        
        // Parameters requirements: [code, list of PNChannel instance, PNError instance, stringified state]
        __unsafe_unretained NSString *unsubscriptionOnClientIdentifierChangeFailed;
        
        // Parameters requirements: [code, list of PNChannel instance, PNError instance, stringified state]
        __unsafe_unretained NSString *presenceObservationEnablingFailed;
        
        // Parameters requirements: [code, list of PNChannel instance, PNError instance, stringified state]
        __unsafe_unretained NSString *presenceObservationDisablingFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationEnablingFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationDisablingFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationRemovalFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *pushNotificationAuditFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *accessRightsChangeFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *accessRightsAuditFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *timeTokenRetrieveFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *messageSendingFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *historyDownloadFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *participantsListDownloadFailed;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *participantChannelsListDownloadFailed;
        
        // Parameters requirements: [code, PNError instance, stringified state]
        __unsafe_unretained NSString *generalError;
        
        // Parameters requirements: [code, PNError instance, stringified state]
        __unsafe_unretained NSString *disconnectingBecauseOfError;
        
        // Parameters requirements: [code, PNError instance, stringified state]
        __unsafe_unretained NSString *connectedFailedBecauseOfError;
        
        // Parameters requirements: [code, communication channel name, communication channel instance memory address, whether notification should be done or not, stringified state]
        __unsafe_unretained NSString *shouldCommunicationChannelNotifyDelegate;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *willSubscribe;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *didSubscribe;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *didSubscribeDuringClientIdentifierChange;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *willRestoreSubscription;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *restoredSubscription;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *willUnsubscribe;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *didUnsubscribe;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *didUnsubscribeDuringClientIdentifierChange;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *willEnablePresenceObservation;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *enabledPresenceObservation;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *willDisablePresenceObservation;
        
        // Parameters requirements: [code, list of PNChannel instances, stringified state]
        __unsafe_unretained NSString *disabledPresenceObservation;
        
        // Parameters requirements: [code, message payload, PNChannel instance, stringified state]
        __unsafe_unretained NSString *didReceiveMessage;
        
        // Parameters requirements: [code, PNPresenceEvent instance, PNChannel instance, stringified state]
        __unsafe_unretained NSString *didReceiveEvent;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didReceiveClientState;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleClientStateAudit;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didChangeClientState;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleClientStateChange;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didChangeAccessRights;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleAccessRightsChange;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didAuditAccessRights;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleAccessRightsAudit;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didReceiveTimeToken;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleTimeTokenRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didEnablePushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *reschedulePushNotificationEnable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didDisablePushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *reschedulePushNotificationDisable;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didRemovePushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *reschedulePushNotificationRemove;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didAuditPushNotifications;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *reschedulePushNotificationAudit;
        
        // Parameters requirements: [code, message payload, PNChannel instance, stringified state]
        __unsafe_unretained NSString *willSendMessage;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didSendMessage;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleMessageSending;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didReceiveHistory;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleHistoryRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didReceiveParticipantsList;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleParticipantsListRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *didReceiveParticipantChannelsList;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleParticipantChannelsListRequest;
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *destroyed;
        
        // Parameters requirements: [code, origin name, stringified state]
        __unsafe_unretained NSString *willConnect;
        
        // Parameters requirements: [code, version, git branch name, commit SHA]
        __unsafe_unretained NSString *clientInformation;
        
        // Parameters requirements: [code, origin name, publish key, subscribe key, secret key, whether cipher key used, subscribe requests timeout, non-subscribe requests timeout, whether should reconnect on network restore, whether should keep previous time token on channels list change, whether should resubscribe on connection restore, whether should use previous token during resubscription process, whether should use secure connection, whether allowed to decrease security level, whetehr allowed to use unsecure connection, whether allowed to receive GZIP compressed responses, presence heartbeat timeout, presence heartbeat interval]
        __unsafe_unretained NSString *configurationInformation;
        
        // Parameters requirements: [code, observer instance address, reachability instance memory address, crypto helper instance memory address, messaging channel instance memory address, service channel instance memory address]
        __unsafe_unretained NSString *resourceLinkage;
        
        // Parameters requirements: [code, namespace name, stringified state]
        __unsafe_unretained NSString *channelGroupsRequestAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *requestChannelGroups;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupsRequestImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelGroupsRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupsRequestCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelGroupsRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupsRequestFailed;
        
        // Parameters requirements: [code, PNChannelGroup instance, stringified state]
        __unsafe_unretained NSString *channelsForGroupRequestAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *requestChannelsForGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsForGroupRequestImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelsForGroupRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsForGroupRequestCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelsForGroupRequest;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsForGroupRequestFailed;
        
        // Parameters requirements: [code, list of PNChannel instances, PNChannelGroup instance, stringified state]
        __unsafe_unretained NSString *channelsAdditionToGroupAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *addingChannelsToGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsAdditionToGroupImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelsAdditionToGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsAdditionToGroupCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelsAdditionToGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsAdditionToGroupFailed;
        
        // Parameters requirements: [code, list of PNChannel instances, PNChannelGroup instance, stringified state]
        __unsafe_unretained NSString *channelsRemovalFromGroupAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *removingChannelsFromGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsRemovalGroupImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelsRemovalFromGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsRemovalFromGroupCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelsRemovalFromGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelsRemovalFromGroupFailed;
        
        
        
        
        
        
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespacesRetrieveAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *retrievingChannelGroupNamespaces;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespacesRetrieveImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelGroupNamespacesRetrieval;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespacesRetrievalCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelGroupNamespacesRetrieval;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespacesRetrievalFailed;
        
        // Parameters requirements: [code, channel group namespace name, stringified state]
        __unsafe_unretained NSString *channelGroupNamespaceRemovalAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *removingChannelGroupNamespace;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespaceRemovalImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelGroupNamespaceRemoval;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespaceRemovalCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelGroupNamespaceRemoval;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupNamespaceRemovalFailed;
        
        // Parameters requirements: [code, PNChannelGroup instance, stringified state]
        __unsafe_unretained NSString *channelGroupRemovalAttempt;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *removingChannelGroup;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupRemovalImpossible;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *postponeChannelGroupRemoval;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupRemovalCompleted;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *rescheduleChannelGroupRemoval;
        
        // Parameters requirements: [code, stringified state]
        __unsafe_unretained NSString *channelGroupRemovalFailed;
    } api;
    
    // Observation center symbols. Group code: 10xxyyy
    struct {
        
        // Parameters requirements: [code]
        __unsafe_unretained NSString *destroyed;
    } observationCenter;
};

extern struct PNLoggerSymbolsStructure PNLoggerSymbols;

#endif // pubnub_PNLoggerSymbols_h
