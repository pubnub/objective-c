//
//  PNServiceChannel.m
//  pubnub
//
//  This channel is required to manage
//  service message sending to PubNub service.
//  Will send messages like:
//      - publish
//      - time
//      - history
//      - here now (list of participants)
//      - push notification state manipulation
//      - "ping" (latency measurement if enabled)
//
//  Notice: don't try to create more than
//          one messaging channel on MacOS
//  
//
//  Created by Sergey Mamontov on 12/15/12.
//
//

#import "PNServiceChannel.h"
#import "PNMessageHistoryRequest+Protected.h"
#import "PNConnectionChannel+Protected.h"
#import "PNOperationStatus+Protected.h"
#import "PNHereNowRequest+Protected.h"
#import "NSInvocation+PNAdditions.h"
#import "PNServiceChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "PNMessage+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNChannel+Protected.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNResponseParser.h"
#import "PNRequestsQueue.h"
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub service connection channel must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public interface methods

@implementation PNServiceChannel


#pragma mark - Class methods

/**
 * Return reference on configured service communication
 * channel with specified delegate
 */
+ (PNServiceChannel *)serviceChannelWithDelegate:(id<PNConnectionChannelDelegate>)delegate {

    return (PNServiceChannel *)[super connectionChannelWithType:PNConnectionChannelService
                                                    andDelegate:delegate];
}


#pragma mark - Instance methods

- (id)initWithType:(PNConnectionChannelType)connectionChannelType
       andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if((self = [super initWithType:PNConnectionChannelService andDelegate:delegate])) {

    }


    return self;
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {

    return ([response.callbackMethod hasPrefix:PNServiceResponseCallbacks.latencyMeasureMessageCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.timeTokenCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelPushNotificationsEnableCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelPushNotificationsDisableCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.pushNotificationEnabledChannelsCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.pushNotificationRemoveCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.sendMessageCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelParticipantsCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.messageHistoryCallback]);
}

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER MESSAGE HAS BEEN PROCESSED");
        [(PNLatencyMeasureRequest *)request markEndTime];

        // Notify delegate that network metrics gathered
        [self.serviceDelegate serviceChannel:self
                    didReceiveNetworkLatency:[(PNLatencyMeasureRequest *)request latency]
                         andNetworkBandwidth:[(PNLatencyMeasureRequest *)request bandwidthToLoadResponse:response]];
    }
    else {

        PNResponseParser *parser = [PNResponseParser parserForResponse:response];
        id parsedData = [parser parsedData];

        // Check whether request is 'Time token' request or not
        if ([request isKindOfClass:[PNTimeTokenRequest class]]){

            if (![parsedData isKindOfClass:[PNError class]]) {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" TIME TOKEN MESSAGE HAS BEEN PROCESSED");

                [self.serviceDelegate serviceChannel:self didReceiveTimeToken:[parser parsedData]];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" TIME TOKEN MESSAGE PROCESSING HAS BEEN FAILED: %@", parsedData);

                [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:parsedData];
            }
        }
        // Check whether request was sent for message posting
        else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            // Retrieve reference on message which has been sent
            PNMessage *message = ((PNMessagePostRequest *)request).message;

            if ([parsedData isKindOfClass:[PNError class]] ||
                ([parsedData isKindOfClass:[PNOperationStatus class]] &&
                 ((PNOperationStatus *)parsedData).error != nil)) {

                if ([parsedData isKindOfClass:[PNOperationStatus class]]) {

                    parsedData = ((PNOperationStatus *)parsedData).error;
                }

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" MESSAGE SENDING FAILED WITH ERROR: %@", parsedData);

                [self.serviceDelegate serviceChannel:self didFailMessageSend:message withError:parsedData];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" MESSAGE HAS BEEN SENT. SERVICE RESPONSE: %@", parsedData);

                [self.serviceDelegate serviceChannel:self didSendMessage:message];
            }
        }
        // Check whether request was sent for message history or not
        else if ([request isKindOfClass:[PNMessageHistoryRequest class]]) {

            PNChannel *channel = ((PNMessageHistoryRequest *)request).channel;

            // Check whether there is no error while loading messages history
            if (![parsedData isKindOfClass:[PNError class]]) {

                ((PNMessagesHistory *)parsedData).channel = channel;
                [((PNMessagesHistory *)parsedData).messages makeObjectsPerformSelector:@selector(setChannel:)
                                                                            withObject:channel];

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" HISTORY HAS BEEN DOWNLOADED. SERVICE RESPONSE: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self didReceiveMessagesHistory:parsedData];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" HISTORY DOWNLOAD FAILED WITH ERROR: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self didFailHisoryDownloadForChannel:channel withError:parsedData];
            }
        }
        // Check whether request was sent for participants list or not
        else if ([request isKindOfClass:[PNHereNowRequest class]]) {

            PNChannel *channel = ((PNHereNowRequest *)request).channel;

            // Check whether there is no error while loading messages history
            if (![parsedData isKindOfClass:[PNError class]]) {

                ((PNHereNow *)parsedData).channel = channel;
                [channel updateWithParticipantsList:parsedData];

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PARTICIPANTS LIST DOWNLOADED. SERVICE RESPONSE: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self didReceiveParticipantsList:parsedData];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" PARTICIPANTS LIST DOWNLOAD FAILED WITH ERROR: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self didFailParticipantsListLoadForChannel:channel withError:parsedData];
            }
        }
        else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {

            SEL selector;
            NSArray *parameters;
            NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
            NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;
            PNLogLevels logLevel = PNLogCommunicationChannelLayerInfoLevel;
            NSString *message = @" PUSH NOTIFICATIONS ENABLED. SERVICE RESPONSE: %@";

            // Check whether there is no error while processed push notifications state change
            if (![parsedData isKindOfClass:[PNError class]]) {

                selector = @selector(serviceChannel:didEnablePushNotificationsOnChannels:);
                if ([targetState isEqualToString:PNPushNotificationsState.disable]) {

                    message = @" PUSH NOTIFICATIONS DISABLED. SERVICE RESPONSE: %@";
                    selector = @selector(serviceChannel:didDisablePushNotificationsOnChannels:);
                }

                parameters = @[self, channels];
            }
            else {

                logLevel = PNLogCommunicationChannelLayerErrorLevel;
                message = @" PUSH NOTIFICATIONS ENABLING FAILED WITH ERROR: %@";
                selector = @selector(serviceChannel:didFailPushNotificationEnableForChannels:withError:);
                if ([targetState isEqualToString:PNPushNotificationsState.disable]) {

                    message = @" PUSH NOTIFICATIONS DISABLING FAILED WITH ERROR: %@";
                    selector = @selector(serviceChannel:didFailPushNotificationDisableForChannels:withError:);
                }

                parameters = @[self, channels, parsedData];
            }

            PNLog(logLevel, self, message, parsedData);

            NSInvocation *invocation = [NSInvocation invocationForObject:self.serviceDelegate
                                                                selector:selector
                                                        retainsArguments:NO
                                                              parameters:parameters];
            [invocation invoke];
        }
        else if ([request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {

            // Check whether there is no error while removed push notifications from specified set
            // of channels or not
            if (![parsedData isKindOfClass:[PNError class]]) {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PUSH NOTIFICATIONS REMOVED. SERVICE RESPONSE: %@",
                      parsedData);

                [self.serviceDelegate serviceChannelDidRemovePushNotifications:self];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" PUSH NOTIFICATIONS REMOVE FAILED WITH ERROR: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self didFailPushNotificationsRemoveWithError:parsedData];
            }
        }
        else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {

            // Check whether there is no error while retrieved list of channels on which
            // push notifications was enabled
            if (![parsedData isKindOfClass:[PNError class]]) {

                PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PUSH NOTIFICATIONS ENABLED CHANNELS LIST RECEIVED. SERVICE RESPONSE: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self
          didReceivePushNotificationsEnabledChannels:[PNChannel channelsWithNames:parsedData]];
            }
            else {

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" PUSH NOTIFICATION ENABLED CHANNELS LIST RECEIVE FAILED WITH ERROR: %@",
                      parsedData);

                [self.serviceDelegate serviceChannel:self didFailPushNotificationEnabledChannelsReceiveWithError:parsedData];
            }
        }
        else {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" PARSED DATA: %@", parser);
            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" OBSERVED REQUEST COMPLETED: %@", request);
        }
    }
}

- (void)handleRequestProcessingDidFail:(PNBaseRequest *)request withError:(PNError *)error {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" LATENCY METER REQUEST SENDING FAILED");
    }
            // Check whether request is 'Time token' request or not
    else if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" TIME TOKEN MESSAGE PROCESSING HAS BEEN FAILED: %@",
              error);

        [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:error];
    }
            // Check whether this is 'Push notification state change' request or not
    else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {

        NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
        NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;
        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" PUSH NOTIFICATION [%@] REQUEST HAS BEEN FAILED: %@",
              [targetState uppercaseString], error);

        if ([targetState isEqualToString:PNPushNotificationsState.enable]) {

            [self.serviceDelegate serviceChannel:self
        didFailPushNotificationEnableForChannels:channels
                                       withError:error];
        }
        else {

            [self.serviceDelegate serviceChannel:self
       didFailPushNotificationDisableForChannels:channels
                                       withError:error];
        }
    }
            // Check whether this is 'Push notification remove' request or not
    else if ([request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" PUSH NOTIFICATION REMOVE REQUEST HAS BEEN FAILED: %@",
              error);

        [self.serviceDelegate serviceChannel:self
     didFailPushNotificationsRemoveWithError:error];
    }
            // Check whether this is 'Push notification enabled channels' request or not
    else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel,
              self,
              @" PUSH NOTIFICATION ENABLED CHANNELS REQUEST HAS BEEN FAILED: %@",
              error);

        [self.serviceDelegate           serviceChannel:self
didFailPushNotificationEnabledChannelsReceiveWithError:error];
    }
            // Check whether this is 'Post message' request or not
    else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message can't be send
        [self.serviceDelegate serviceChannel:self
                          didFailMessageSend:((PNMessagePostRequest *)request).message
                                   withError:error];
    }
            // Check whether this is 'Message history' request or not
    else if ([request isKindOfClass:[PNMessageHistoryRequest class]]) {

        // Notify delegate about message history download failed
        [self.serviceDelegate serviceChannel:self
             didFailHisoryDownloadForChannel:((PNMessageHistoryRequest *)request).channel
                                   withError:error];
    }
            // Check whether this is 'Here now' request or not
    else if ([request isKindOfClass:[PNHereNowRequest class]]) {

        // Notify delegate about participants list can't be downloaded
        [self.serviceDelegate serviceChannel:self
       didFailParticipantsListLoadForChannel:((PNHereNowRequest *)request).channel
                                   withError:error];
    }
}

- (void)makeScheduledRequestsFail:(NSArray *)requestsList withError:(PNError *)processingError {

    PNError *error = processingError;
    if (error == nil) {

        error = [PNError errorWithCode:kPNRequestExecutionFailedOnInternetFailureError];
    }

    [requestsList enumerateObjectsUsingBlock:^(NSString *requestIdentifier, NSUInteger requestIdentifierIdx,
                                               BOOL *requestIdentifierEnumeratorStop) {

        PNBaseRequest *request = [self requestWithIdentifier:requestIdentifier];

        // Removing failed request from queue
        [self destroyRequest:request];

        [self handleRequestProcessingDidFail:request withError:error];
    }];
}

- (void)rescheduleStoredRequests:(NSArray *)requestsList {

    if ([requestsList count] > 0) {

        [requestsList enumerateObjectsWithOptions:NSEnumerationReverse
                                       usingBlock:^(id requestIdentifier, NSUInteger requestIdentifierIdx,
                                                    BOOL *requestIdentifierEnumeratorStop) {

               PNBaseRequest *request = [self storedRequestWithIdentifier:requestIdentifier];

               [request reset];
               request.closeConnection = NO;

               // Check whether client is waiting for request completion
               BOOL isWaitingForCompletion = [self isWaitingRequestCompletion:request.shortIdentifier];

               // Clean up query (if request has been stored in it)
               [self destroyRequest:request];

               // Send request back into queue with higher priority among other requests
               [self scheduleRequest:request
             shouldObserveProcessing:isWaitingForCompletion
                          outOfOrder:YES
                    launchProcessing:NO];
           }];

        [self scheduleNextRequest];
    }
}

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request {

    BOOL shouldStoreRequest = YES;
    if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

        shouldStoreRequest = request.isSendingByUserRequest;
    }


    return shouldStoreRequest;
}


#pragma mark - Messages processing methods

- (PNMessage *)sendMessage:(id)object toChannel:(PNChannel *)channel {

    // Create object instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:object forChannel:channel error:&error];

    // Checking whether
    if (messageObject) {

        // Schedule object sending request
        [self scheduleRequest:[PNMessagePostRequest postMessageRequestWithMessage:messageObject]
      shouldObserveProcessing:YES];
    }
    else {

        // Notify delegate about object sending error
        [self.serviceDelegate serviceChannel:self didFailMessageSend:messageObject withError:error];
    }

    return messageObject;
}

- (void)sendMessage:(PNMessage *)message {

    if (message) {

        // Schedule message sending request
        [self sendMessage:message.message toChannel:message.channel];
    }
}

#pragma mark - Handler methods

- (void)handleTimeoutTimer:(NSTimer *)timer {

    PNBaseRequest *request = (PNBaseRequest *)timer.userInfo;
    NSInteger errorCode = kPNRequestExecutionFailedByTimeoutError;
    NSString *errorMessage = @"Message sending failed by timeout";
    if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

        errorMessage = @"Time token request failed by timeout";

        [self.serviceDelegate serviceChannel:self
            receiveTimeTokenDidFailWithError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else if ([request isKindOfClass:[PNMessageHistoryRequest class]]) {

        errorMessage = @"Channel history request failed by timeout";

        [self.serviceDelegate serviceChannel:self
             didFailHisoryDownloadForChannel:((PNMessageHistoryRequest *)request).channel
                                   withError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else if ([request isKindOfClass:[PNHereNowRequest class]]) {

        errorMessage = @"\"Here now\" request failed by timeout";

        [self.serviceDelegate serviceChannel:self
       didFailParticipantsListLoadForChannel:((PNHereNowRequest *)request).channel
                                   withError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {

        NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;
        NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
        NSString *state = @"enabling";
        if ([targetState isEqualToString:PNPushNotificationsState.disable]) {

            state = @"disabling";
        }
        errorMessage = [NSString stringWithFormat:@"Push notification '%@' failed by timeout", state];

        if ([targetState isEqualToString:PNPushNotificationsState.enable]) {

            [self.serviceDelegate serviceChannel:self
        didFailPushNotificationEnableForChannels:channels
                                       withError:[PNError errorWithMessage:errorMessage code:errorCode]];
        }
        else {

            [self.serviceDelegate serviceChannel:self
       didFailPushNotificationDisableForChannels:channels
                                       withError:[PNError errorWithMessage:errorMessage code:errorCode]];
        }
    }
    else if ([request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {

        errorMessage = @"Push notification removal from all channels failed by timeout";

        [self.serviceDelegate serviceChannel:self
     didFailPushNotificationsRemoveWithError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {

        errorMessage = @"Push notification enabled channels retrieval failed by timeout";

        [self.serviceDelegate           serviceChannel:self
didFailPushNotificationEnabledChannelsReceiveWithError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else {

        [self.serviceDelegate serviceChannel:self
                          didFailMessageSend:((PNMessagePostRequest *)request).message
                                   withError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }


    [self destroyRequest:request];


    // Check whether connection available or not
    [[PubNub sharedInstance].reachability refreshReachabilityState];
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        // Asking to schedule next request
        [self scheduleNextRequest];
    }
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" WILL START REQUEST PROCESSING: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // Check whether this is 'Message post' request or not
    if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message post request will be sent now
        [self.serviceDelegate serviceChannel:self willSendMessage:((PNMessagePostRequest *)request).message];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID SEND REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // If we are not waiting for request completion, inform delegate
    // immediately
    if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Checking whether request was sent to measure network latency or not
        if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER MESSAGE SENT");
            [(PNLatencyMeasureRequest *)request markStartTime];
        }
    }
    else {

        // Check whether this is 'Post message' request or not
        if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" DID SEND MESSAGE REQUEST");

            // Notify delegate about that message post request will be sent now
            [self.serviceDelegate serviceChannel:self didSendMessage:((PNMessagePostRequest *)request).message];
        }
    }


    [self scheduleNextRequest];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Forward to the super class
    [super requestsQueue:queue didFailRequestSend:request withError:error];


    PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @" DID FAIL TO SEND REQUEST: %@ [BODY: %@]",
          request,
          request.resourcePath);


    // Check whether request can be rescheduled or not
    if (![request canRetry]) {

        PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"[CHANNEL::%@] DID FAIL TO SEND REQUEST: %@ [BODY: %@]",
              self, request, request.resourcePath);

        // Removing failed request from queue
        [self destroyRequest:request];

        [self handleRequestProcessingDidFail:request withError:error];
    }


    // Check whether connection available or not
    if ([self isConnected] && [[PubNub sharedInstance].reachability isServiceAvailable]) {

        [self scheduleNextRequest];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" LATENCY METER REQUEST CANCELED");

        // Removing 'Latency meter' request because PubNub client
        // is not interested in delayed response on network measurements
        [self destroyRequest:request];
    }

    // Forward to the super class
    [super requestsQueue:queue didCancelRequest:request];
}

- (BOOL)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request {

    BOOL shouldRemoveRequest = YES;

    // Check whether leave request has been sent to PubNub
    // services or not
    if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

        shouldRemoveRequest = NO;
    }


    return shouldRemoveRequest;
}

#pragma mark -


@end
