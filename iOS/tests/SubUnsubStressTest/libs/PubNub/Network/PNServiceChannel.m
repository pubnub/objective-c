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
#import "PNAccessRightsCollection+Protected.h"
#import "PNMessageHistoryRequest+Protected.h"
#import "PNConnectionChannel+Protected.h"
#import "PNOperationStatus+Protected.h"
#import "NSInvocation+PNAdditions.h"
#import "PNServiceChannelDelegate.h"
#import "PNConnection+Protected.h"
#import "PNResponse+Protected.h"
#import "PNMessage+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNChannel+Protected.h"
#import "PNClient+Protected.h"
#import "PubNub+Protected.h"
#import "PNRequestsImport.h"
#import "PNResponseParser.h"
#import "PNRequestsQueue.h"
#import "PNClient.h"
#import "PNDate.h"


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

- (id)initWithType:(PNConnectionChannelType)connectionChannelType andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if((self = [super initWithType:PNConnectionChannelService andDelegate:delegate])) {

    }


    return self;
}

- (BOOL)shouldHandleResponse:(PNResponse *)response {

    return ([response.callbackMethod hasPrefix:PNServiceResponseCallbacks.latencyMeasureMessageCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.stateRetrieveCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.stateUpdateCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.timeTokenCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelPushNotificationsEnableCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelPushNotificationsDisableCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.pushNotificationEnabledChannelsCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.pushNotificationRemoveCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.sendMessageCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelParticipantsCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.participantChannelsCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.messageHistoryCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelAccessRightsChangeCallback] ||
            [response.callbackMethod hasPrefix:PNServiceResponseCallbacks.channelAccessRightsAuditCallback] ||
            [response.callbackMethod hasPrefix:@"0"]);
}

- (void)processResponse:(PNResponse *)response forRequest:(PNBaseRequest *)request {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] LATENCY METER MESSAGE HAS BEEN PROCESSED", self];
        }];

        [(PNLatencyMeasureRequest *)request markEndTime];

        // Notify delegate that network metrics gathered
        [self.serviceDelegate serviceChannel:self
                    didReceiveNetworkLatency:[(PNLatencyMeasureRequest *)request latency]
                         andNetworkBandwidth:[(PNLatencyMeasureRequest *)request bandwidthToLoadResponse:response]];
    }
    else {

        if ([request isKindOfClass:[PNHereNowRequest class]]) {

            PNChannel *channel = ((PNHereNowRequest *)request).channel;
            response.additionalData = channel;
        }
        else if ([request isKindOfClass:[PNWhereNowRequest class]]) {

            NSString *identifier = ((PNWhereNowRequest *)request).identifier;
            response.additionalData = identifier;
        }
        else if ([request isKindOfClass:[PNClientStateRequest class]] ||
                [request isKindOfClass:[PNClientStateUpdateRequest class]]) {

            NSString *identifier = [request valueForKey:@"clientIdentifier"];
            PNChannel *channel = [request valueForKey:@"channel"];
            response.additionalData = [PNClient clientForIdentifier:identifier channel:channel andData:nil];
        }

        PNResponseParser *parser = [PNResponseParser parserForResponse:response];
        id parsedData = [parser parsedData];

        // Check whether request is 'Time token' request or not
        if ([request isKindOfClass:[PNTimeTokenRequest class]]){

            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] TIME TOKEN MESSAGE HAS BEEN PROCESSED", self];
                }];

                [self.serviceDelegate serviceChannel:self didReceiveTimeToken:[parser parsedData]];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] TIME TOKEN MESSAGE PROCESSING HAS BEEN FAILED: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:parsedData];
            }
        }
        // Check whether request was sent for state retrieval
        else if ([request isKindOfClass:[PNClientStateRequest class]]) {

            // Check whether there is no error while loading participants list
            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] CLIENT STATE DOWNLOADED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didReceiveClientState:parsedData];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] CLIENT STATE DOWNLOAD FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                ((PNError *)parsedData).associatedObject = response.additionalData;
                [self.serviceDelegate serviceChannel:self clientStateReceiveDidFailWithError:parsedData];
            }
        }
        // Check whether request was sent for state update
        else if ([request isKindOfClass:[PNClientStateUpdateRequest class]]) {

            // Check whether there is no error while loading participants list
            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] CLIENT STATE UPDATED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didUpdateClientState:parsedData];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] CLIENT STATE UPDATE FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                ((PNError *)parsedData).associatedObject = response.additionalData;
                [self.serviceDelegate serviceChannel:self clientStateUpdateDidFailWithError:parsedData];
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

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] MESSAGE SENDING FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didFailMessageSend:message withError:parsedData];
            }
            else {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] MESSAGE HAS BEEN SENT. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                // Storing message sent date.
                if ([parsedData isKindOfClass:[PNOperationStatus class]]) {

                    message.date = [PNDate dateWithToken:((PNOperationStatus *)parsedData).timeToken];
                }
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

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] HISTORY HAS BEEN DOWNLOADED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didReceiveMessagesHistory:parsedData];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] HISTORY DOWNLOAD FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didFailHisoryDownloadForChannel:channel withError:parsedData];
            }
        }
        // Check whether request was sent for participants list or not
        else if ([request isKindOfClass:[PNHereNowRequest class]]) {

            PNChannel *channel = ((PNHereNowRequest *)request).channel;

            // Check whether there is no error while loading participants list
            if (![parsedData isKindOfClass:[PNError class]]) {

                ((PNHereNow *)parsedData).channel = channel;
                [channel updateWithParticipantsList:parsedData];

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PARTICIPANTS LIST DOWNLOADED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didReceiveParticipantsList:parsedData];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PARTICIPANTS LIST DOWNLOAD FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didFailParticipantsListLoadForChannel:channel withError:parsedData];
            }
        }
        // Check whether request was sent for participant channels list or not
        else if ([request isKindOfClass:[PNWhereNowRequest class]]) {

            NSString *identifier = ((PNWhereNowRequest *)request).identifier;

            // Check whether there is no error while loading channels
            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PARTICIPANT CHANNELS LIST DOWNLOADED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didReceiveParticipantChannelsList:parsedData];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PARTICIPANT CHANNELS LIST DOWNLOAD FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self didFailParticipantChannelsListLoadForIdentifier:identifier
                                           withError:parsedData];
            }
        }
        else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {

            SEL selector;
            NSArray *parameters;
            NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
            NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;
            PNLogLevel logLevel = PNLogCommunicationChannelLayerInfoLevel;
            NSString *message = @"[CHANNEL::%@] PUSH NOTIFICATIONS ENABLED. SERVICE RESPONSE: %@";

            // Check whether there is no error while processed push notifications state change
            if (![parsedData isKindOfClass:[PNError class]]) {

                selector = @selector(serviceChannel:didEnablePushNotificationsOnChannels:);
                if ([targetState isEqualToString:PNPushNotificationsState.disable]) {

                    message = @"[CHANNEL::%@] PUSH NOTIFICATIONS DISABLED. SERVICE RESPONSE: %@";
                    selector = @selector(serviceChannel:didDisablePushNotificationsOnChannels:);
                }

                parameters = @[self, channels];
            }
            else {
                
                logLevel = PNLogCommunicationChannelLayerErrorLevel;
                message = @"[CHANNEL::%@] PUSH NOTIFICATIONS ENABLING FAILED WITH ERROR: %@";
                selector = @selector(serviceChannel:didFailPushNotificationEnableForChannels:withError:);
                if ([targetState isEqualToString:PNPushNotificationsState.disable]) {

                    message = @"[CHANNEL::%@] PUSH NOTIFICATIONS DISABLING FAILED WITH ERROR: %@";
                    selector = @selector(serviceChannel:didFailPushNotificationDisableForChannels:withError:);
                }

                parameters = @[self, channels, parsedData];
            }
            [PNLogger logFrom:self forLevel:logLevel message:^NSString * {

                return [NSString stringWithFormat:message, self, parsedData];
            }];

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

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATIONS REMOVED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannelDidRemovePushNotifications:self];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATIONS REMOVE FAILED WITH ERROR: %@",
                            self, parsedData];
                }];
                
                [self.serviceDelegate serviceChannel:self didFailPushNotificationsRemoveWithError:parsedData];
            }
        }
        else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {

            // Check whether there is no error while retrieved list of channels on which push notifications was enabled
            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATIONS ENABLED CHANNELS LIST RECEIVED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self
          didReceivePushNotificationsEnabledChannels:[PNChannel channelsWithNames:parsedData]];
            }
            else {

                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATION ENABLED CHANNELS LIST RECEIVE FAILED WITH ERROR: %@",
                            self, parsedData];
                }];
                
                [self.serviceDelegate serviceChannel:self didFailPushNotificationEnabledChannelsReceiveWithError:parsedData];
            }
        }
        else if ([request isKindOfClass:[PNChangeAccessRightsRequest class]]) {

            PNAccessRightOptions *options = ((PNChangeAccessRightsRequest *)request).accessRightOptions;
            
            // Check whether there is no error while tried to change access rights.
            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] ACCESS RIGHTS SUCCESSFULLY CHANGED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [(PNAccessRightsCollection *)parsedData correlateAccessRightsWithOptions:options];
                [self.serviceDelegate serviceChannel:self didChangeAccessRights:parsedData];
            }
            else {

                ((PNError *)parsedData).associatedObject = options;
                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] ACCESS RIGHTS CHANGE FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self accessRightsChangeDidFailWithError:parsedData];
            }
        }
        else if ([request isKindOfClass:[PNAccessRightsAuditRequest class]]) {

            PNAccessRightOptions *options = ((PNAccessRightsAuditRequest *)request).accessRightOptions;

            // Check whether there is no error while tried to audit access rights.
            if (![parsedData isKindOfClass:[PNError class]]) {

                [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] ACCESS RIGHTS SUCCESSFULLY AUDITED. SERVICE RESPONSE: %@",
                            self, parsedData];
                }];

                [(PNAccessRightsCollection *)parsedData correlateAccessRightsWithOptions:options];
                [self.serviceDelegate serviceChannel:self didAuditAccessRights:parsedData];
            }
            else {

                ((PNError *)parsedData).associatedObject = options;
                [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

                    return [NSString stringWithFormat:@"[CHANNEL::%@] ACCESS RIGHTS AUDIT FAILED WITH ERROR: %@",
                            self, parsedData];
                }];

                [self.serviceDelegate serviceChannel:self accessRightsAuditDidFailWithError:parsedData];
            }
        }
        else {

            [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"[CHANNEL::%@] PARSED DATA: %@",
                        self, parser];
            }];
            [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"[CHANNEL::%@] OBSERVED REQUEST COMPLETED: %@",
                        self, request];
            }];
        }
    }
}

- (void)handleRequestProcessingDidFail:(PNBaseRequest *)request withError:(PNError *)error {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] LATENCY METER REQUEST SENDING FAILED", self];
        }];
    }
    // Check whether request is 'Time token' request or not
    else if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] TIME TOKEN MESSAGE PROCESSING HAS BEEN FAILED: %@", self, error];
        }];

        [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:error];
    }
    // Check whether request was sent for state retrieval / update
    else if ([request isKindOfClass:[PNClientStateRequest class]] ||
            [request isKindOfClass:[PNClientStateUpdateRequest class]]) {

        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            NSDictionary *clientData = ([request isKindOfClass:[PNClientStateUpdateRequest class]] ? [request valueForKey:@"state"] : nil);
            error.associatedObject = [PNClient clientForIdentifier:[request valueForKey:@"clientIdentifier"]
                                                           channel:[request valueForKey:@"channel"] andData:clientData];
        }

        NSString *message = [NSString stringWithFormat:@"[CHANNEL::%@] CLIENT STATE REVIEW FAILED WITH ERROR: %@", self, error];
        SEL errorSelector = @selector(serviceChannel:clientStateReceiveDidFailWithError:);
        if ([request isKindOfClass:[PNClientStateUpdateRequest class]]) {

            message = [NSString stringWithFormat:@"[CHANNEL::%@] CLIENT STATE UPDATE FAILED WITH ERROR: %@", self, error];
            errorSelector = @selector(serviceChannel:clientStateUpdateDidFailWithError:);
        }

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * { return message; }];

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:errorSelector withObject:self withObject:error];
        #pragma clang diagnostic pop
    }
    // Check whether this is 'Post message' request or not
    else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message can't be send
        [self.serviceDelegate serviceChannel:self didFailMessageSend:((PNMessagePostRequest *)request).message
                                   withError:error];
    }
    // Check whether this is 'Message history' request or not
    else if ([request isKindOfClass:[PNMessageHistoryRequest class]]) {
        
        PNMessageHistoryRequest *historyRequest = (PNMessageHistoryRequest *)request;
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{
                                               @"limit":@(historyRequest.limit), @"revertMessages":@(historyRequest.shouldRevertMessages),
                                               @"includeTimeToken":@(historyRequest.shouldIncludeTimeToken)}];
            if (historyRequest.startDate) {
                
                [options setValue:historyRequest.startDate forKey:@"startDate"];
            }
            
            if (historyRequest.endDate) {
                
                [options setValue:historyRequest.endDate forKey:@"endDate"];
            }
            error.associatedObject = options;
        }
        
        // Notify delegate about message history download failed
        [self.serviceDelegate serviceChannel:self
             didFailHisoryDownloadForChannel:historyRequest.channel withError:error];
    }
    // Check whether this is 'Here now' request or not
    else if ([request isKindOfClass:[PNHereNowRequest class]]) {
        
        PNHereNowRequest *hereNowRequest = (PNHereNowRequest *)request;
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = @{@"clientIdentifiersRequired":@(hereNowRequest.isClientIdentifiersRequired),
                                       @"fetchClientState":@(hereNowRequest.shouldFetchClientState)};
        }

        // Notify delegate about participants list can't be downloaded
        [self.serviceDelegate serviceChannel:self
       didFailParticipantsListLoadForChannel:hereNowRequest.channel withError:error];
    }
    // Check whether this is 'Where now' request or not
    else if ([request isKindOfClass:[PNWhereNowRequest class]]) {

        // Notify delegate about participant channels list can't be downloaded.
        [self.serviceDelegate serviceChannel:self
                didFailParticipantChannelsListLoadForIdentifier:((PNWhereNowRequest *)request).identifier withError:error];
    }
    // Check whether this is 'Push notification state change' request or not
    else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {

        NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
        NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATION [%@] REQUEST HAS BEEN FAILED: %@", self,
                    [targetState uppercaseString], error];
        }];
        
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNPushNotificationsStateChangeRequest *)request).devicePushToken;
        }
        if ([targetState isEqualToString:PNPushNotificationsState.enable]) {

            [self.serviceDelegate serviceChannel:self didFailPushNotificationEnableForChannels:channels
                                       withError:error];
        }
        else {

            [self.serviceDelegate serviceChannel:self didFailPushNotificationDisableForChannels:channels
                                       withError:error];
        }
    }
    // Check whether this is 'Push notification remove' request or not
    else if ([request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATION REMOVE REQUEST HAS BEEN FAILED: %@",
                    self, error];
        }];
        
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNPushNotificationsRemoveRequest *)request).devicePushToken;
        }
        [self.serviceDelegate serviceChannel:self didFailPushNotificationsRemoveWithError:error];
    }
    // Check whether this is 'Push notification enabled channels' request or not
    else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] PUSH NOTIFICATION ENABLED CHANNELS REQUEST HAS BEEN FAILED: %@",
                    self, error];
        }];
        
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNPushNotificationsEnabledChannelsRequest *)request).devicePushToken;
        }
        [self.serviceDelegate serviceChannel:self didFailPushNotificationEnabledChannelsReceiveWithError:error];
    }
    // Check whether this is 'Access rights change' request or not
    else if ([request isKindOfClass:[PNChangeAccessRightsRequest class]]) {

        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNChangeAccessRightsRequest *)request).accessRightOptions;
        }
        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] ACCESS RIGHTS CHANGE FAILED WITH ERROR: %@", self, error];
        }];

        [self.serviceDelegate serviceChannel:self accessRightsChangeDidFailWithError:error];
    }
    // Check whether this is 'Access rights audit' request or not
    else if ([request isKindOfClass:[PNAccessRightsAuditRequest class]]) {

        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNAccessRightsAuditRequest *)request).accessRightOptions;
        }
        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] ACCESS RIGHTS AUDIT FAILED WITH ERROR: %@", self, error];
        }];

        [self.serviceDelegate serviceChannel:self accessRightsAuditDidFailWithError:error];
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

- (void)rescheduleStoredRequests:(NSArray *)requestsList resetRetryCount:(BOOL)shouldResetRequestsRetryCount {

    if ([requestsList count] > 0) {

        [requestsList enumerateObjectsWithOptions:NSEnumerationReverse
                                       usingBlock:^(id requestIdentifier, NSUInteger requestIdentifierIdx,
                                                    BOOL *requestIdentifierEnumeratorStop) {

               PNBaseRequest *request = [self storedRequestWithIdentifier:requestIdentifier];

               [request resetWithRetryCount:shouldResetRequestsRetryCount];
               request.closeConnection = NO;

               // Clean up query (if request has been stored in it)
               [self destroyRequest:request];
                                  
               [self requestsQueue:nil didFailRequestSend:request
                         withError:[PNError errorWithCode:kPNRequestCantBeProcessedWithOutRescheduleError]];
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

- (PNMessage *)sendMessage:(id)object toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {

    // Create object instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:object forChannel:channel compressed:shouldCompressMessage error:&error];

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
        [self sendMessage:message.message toChannel:message.channel compressed:message.shouldCompressMessage];
    }
}


#pragma mark - PAM manipulation methods

- (void)changeAccessRightsForChannels:(NSArray *)channels accessRights:(PNAccessRights)accessRights
                                                     authorizationKeys:(NSArray *)authorizationKeys
                                                             forPeriod:(NSInteger)accessPeriod {

    [self scheduleRequest:[PNChangeAccessRightsRequest changeAccessRightsRequestForChannels:channels
                                                                               accessRights:accessRights
                                                                                    clients:authorizationKeys
                                                                                  forPeriod:accessPeriod]
  shouldObserveProcessing:YES];
}
- (void)auditAccessRightsForChannels:(NSArray *)channels clients:(NSArray *)clientsAuthorizationKeys {

    [self scheduleRequest:[PNAccessRightsAuditRequest accessRightsAuditRequestForChannels:channels
                                                                               andClients:clientsAuthorizationKeys]
  shouldObserveProcessing:YES];
}


#pragma mark - Handler methods

- (void)handleTimeoutTimer:(NSTimer *)timer {

    PNBaseRequest *request = (PNBaseRequest *)timer.userInfo;
    NSInteger errorCode = kPNRequestExecutionFailedByTimeoutError;
    NSString *errorMessage = @"Channel's message history download failed by timeout";
    if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

        errorMessage = @"Time token request failed by timeout";

        [self.serviceDelegate serviceChannel:self
            receiveTimeTokenDidFailWithError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    // Check whether request was sent for state retrieval / update
    else if ([request isKindOfClass:[PNClientStateRequest class]] ||
            [request isKindOfClass:[PNClientStateUpdateRequest class]]) {

        errorMessage = @"Client state request failed by timeout";

        SEL errorSelector = @selector(serviceChannel:clientStateReceiveDidFailWithError:);
        if ([request isKindOfClass:[PNClientStateUpdateRequest class]]) {

            errorMessage = @"Client state update failed by timeout";
            errorSelector = @selector(serviceChannel:clientStateUpdateDidFailWithError:);
        }
        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        error.associatedObject = [PNClient clientForIdentifier:[request valueForKey:@"clientIdentifier"]
                                                       channel:[request valueForKey:@"channel"]
                                                       andData:nil];

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:errorSelector withObject:self withObject:error];
        #pragma clang diagnostic pop
    }
    // Check whether this is 'Post message' request or not
    else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        errorMessage = @"Message post failed by timeout";

        [self.serviceDelegate serviceChannel:self didFailMessageSend:((PNMessagePostRequest *)request).message
                                   withError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else if ([request isKindOfClass:[PNHereNowRequest class]]) {

        errorMessage = @"\"Here now\" request failed by timeout";

        [self.serviceDelegate serviceChannel:self
       didFailParticipantsListLoadForChannel:((PNHereNowRequest *)request).channel
                                   withError:[PNError errorWithMessage:errorMessage code:errorCode]];
    }
    else if ([request isKindOfClass:[PNWhereNowRequest class]]) {

        errorMessage = @"\"Where now\" request failed by timeout";

        [self.serviceDelegate serviceChannel:self
                didFailParticipantChannelsListLoadForIdentifier:((PNWhereNowRequest *)request).identifier
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
    else if ([request isKindOfClass:[PNChangeAccessRightsRequest class]]) {

        errorMessage = @"Access rights change failed by timeout";

        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        error.associatedObject = ((PNChangeAccessRightsRequest *)request).accessRightOptions;

        [self.serviceDelegate serviceChannel:self accessRightsChangeDidFailWithError:error];
    }
    else if ([request isKindOfClass:[PNAccessRightsAuditRequest class]]) {

        errorMessage = @"Access rights audit failed by timeout";

        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        error.associatedObject = ((PNAccessRightsAuditRequest *)request).accessRightOptions;

        [self.serviceDelegate serviceChannel:self accessRightsAuditDidFailWithError:error];
    }
    else {
        
        [self.serviceDelegate serviceChannel:self didFailHisoryDownloadForChannel:((PNMessageHistoryRequest *)request).channel
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
    [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"[CHANNEL::%@] WILL START REQUEST PROCESSING: %@ [BODY: %@]", self, request, request.debugResourcePath];
    }];


    // Check whether this is 'Message post' request or not
    if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message post request will be sent now
        [self.serviceDelegate serviceChannel:self willSendMessage:((PNMessagePostRequest *)request).message];
    }
}

- (void)requestsQueue:(PNRequestsQueue *)queue didSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue didSendRequest:request];
    [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"[CHANNEL::%@] DID SEND REQUEST: %@ [BODY: %@]", self, request, request.debugResourcePath];
    }];


    // If we are not waiting for request completion, inform delegate
    // immediately
    if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Checking whether request was sent to measure network latency or not
        if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"[CHANNEL::%@] LATENCY METER MESSAGE SENT", self];
            }];
            [(PNLatencyMeasureRequest *)request markStartTime];
        }
    }
    else {

        // Check whether this is 'Post message' request or not
        if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

                return [NSString stringWithFormat:@"[CHANNEL::%@] DID SEND MESSAGE REQUEST", self];
            }];

            // Notify delegate about that message post request will be sent now
            [self.serviceDelegate serviceChannel:self didSendMessage:((PNMessagePostRequest *)request).message];
        }
        // In case if this is any other request for which don't expect completion, we should clean it up from stored
        // requests list.
        else {
            
            [self removeStoredRequest:request];
        }
    }


    [self scheduleNextRequest];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didFailRequestSend:(PNBaseRequest *)request withError:(PNError *)error {

    // Forward to the super class
    [super requestsQueue:queue didFailRequestSend:request withError:error];
    [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

        return [NSString stringWithFormat:@"[CHANNEL::%@] DID FAIL TO SEND REQUEST: %@ [BODY: %@]", self, request, request.debugResourcePath];
    }];


    // Check whether request can be rescheduled or not
    if (![request canRetry] || error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] REQUEST WON'T BE SENT: %@ [BODY: %@]",
                    self, request, request.debugResourcePath];
        }];

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

        [PNLogger logCommunicationChannelInfoMessageFrom:self message:^NSString * {

            return [NSString stringWithFormat:@"[CHANNEL::%@] LATENCY METER REQUEST CANCELED", self];
        }];

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
