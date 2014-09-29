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
#import "NSObject+PNAdditions.h"
#import "PNResponse+Protected.h"
#import "PNMessage+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNChannel+Protected.h"
#import "PNClient+Protected.h"
#import "PNError+Protected.h"
#import "PNRequestsImport.h"
#import "PNResponseParser.h"
#import "PNRequestsQueue.h"
#import "PNLoggerSymbols.h"
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
+ (PNServiceChannel *)serviceChannelWithConfiguration:(PNConfiguration *)configuration
                                          andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    return (PNServiceChannel *)[super connectionChannelWithConfiguration:configuration type:PNConnectionChannelService
                                                             andDelegate:delegate];
}


#pragma mark - Instance methods

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

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.latencyMeterRequestCompleted, (self.name ? self.name : self)];
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
            NSDictionary *clientData = ([request isKindOfClass:[PNClientStateUpdateRequest class]] ? [request valueForKey:@"state"] : nil);
            response.additionalData = [PNClient clientForIdentifier:identifier channel:channel andData:clientData];
        }
        
        [self pn_dispatchAsynchronouslyBlock:^{
            
            PNResponseParser *parser = [PNResponseParser parserForResponse:response];
            id parsedData = [parser parsedData];
            
            // Check whether request is 'Time token' request or not
            if ([request isKindOfClass:[PNTimeTokenRequest class]]){
                
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.timeTokenRequestCompleted, (self.name ? self.name : self),
                                 (parser ? [parser parsedData] : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didReceiveTimeToken:[parser parsedData]];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.timeTokenRequestFailed, (self.name ? self.name : self),
                                 (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:parsedData];
                }
            }
            // Check whether request was sent for state retrieval
            else if ([request isKindOfClass:[PNClientStateRequest class]]) {
                
                // Check whether there is no error while loading participants list
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.clientStateAuditRequestCompleted, (self.name ? self.name : self),
                                 (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didReceiveClientState:parsedData];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.clientStateAuditRequestFailed, (self.name ? self.name : self),
                                 (parsedData ? parsedData : [NSNull null]), (response.additionalData ? response.additionalData : [NSNull null])];
                    }];
                    
                    ((PNError *)parsedData).associatedObject = response.additionalData;
                    [self.serviceDelegate serviceChannel:self clientStateReceiveDidFailWithError:parsedData];
                }
            }
            // Check whether request was sent for state update
            else if ([request isKindOfClass:[PNClientStateUpdateRequest class]]) {
                
                // Check whether there is no error while loading participants list
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.clientStateUpdateRequestCompleted, (self.name ? self.name : self),
                                 (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didUpdateClientState:parsedData];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.clientStateUpdateRequestFailed, (self.name ? self.name : self),
                                 (parsedData ? parsedData : [NSNull null]), (response.additionalData ? response.additionalData : [NSNull null])];
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
                        
                        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            return @[PNLoggerSymbols.connectionChannel.service.messageSendRequestFailed, (self.name ? self.name : self),
                                     (message.message ? message.message : [NSNull null]), (message.channel ? message.channel : [NSNull null])];
                        }];
                        
                        [self.serviceDelegate serviceChannel:self didFailMessageSend:message withError:parsedData];
                    }
                else {
                    
                    // Storing message sent date.
                    if ([parsedData isKindOfClass:[PNOperationStatus class]]) {
                        
                        message.date = [PNDate dateWithToken:((PNOperationStatus *)parsedData).timeToken];
                    }
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.messageSendRequestCompleted, (self.name ? self.name : self),
                                 (message.message ? message.message : [NSNull null]), (message.channel ? message.channel : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didSendMessage:message];
                }
            }
            // Check whether request was sent for message history or not
            else if ([request isKindOfClass:[PNMessageHistoryRequest class]]) {
                
                PNMessageHistoryRequest *historyRequest = (PNMessageHistoryRequest *)request;
                
                // Check whether there is no error while loading messages history
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    PNMessagesHistory *history = (PNMessagesHistory *)parsedData;
                    history.channel = historyRequest.channel;
                    [history.messages makeObjectsPerformSelector:@selector(setChannel:) withObject:historyRequest.channel];
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.historyRequestCompleted, (self.name ? self.name : self),
                                 (history.channel ? history.channel : [NSNull null]), (history.startDate ? history.startDate : [NSNull null]),
                                 (history.endDate ? history.endDate : [NSNull null]), @(historyRequest.limit),
                                 @(historyRequest.shouldRevertMessages), @(historyRequest.shouldIncludeTimeToken),
                                 (history.messages ? history.messages : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didReceiveMessagesHistory:parsedData];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.historyRequestFailed, (self.name ? self.name : self),
                                 (historyRequest.channel ? historyRequest.channel : [NSNull null]),
                                 (historyRequest.startDate ? historyRequest.startDate : [NSNull null]),
                                 (historyRequest.endDate ? historyRequest.endDate : [NSNull null]), @(historyRequest.limit),
                                 @(historyRequest.shouldRevertMessages), @(historyRequest.shouldIncludeTimeToken),
                                 (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didFailHisoryDownloadForChannel:historyRequest.channel withError:parsedData];
                }
            }
            // Check whether request was sent for participants list or not
            else if ([request isKindOfClass:[PNHereNowRequest class]]) {
                
                PNHereNowRequest *hereNowRequest = (PNHereNowRequest *)request;
                PNChannel *channel = hereNowRequest.channel;
                
                // Check whether there is no error while loading participants list
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    ((PNHereNow *)parsedData).channel = channel;
                    [channel updateWithParticipantsList:parsedData];
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.participantsListRequestCompleted, (self.name ? self.name : self),
                                 (channel ? channel : [NSNull null]), @(hereNowRequest.isClientIdentifiersRequired),
                                 @(hereNowRequest.shouldFetchClientState), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didReceiveParticipantsList:parsedData];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.participantsListRequestFailed, (self.name ? self.name : self),
                                 (channel ? channel : [NSNull null]), @(hereNowRequest.isClientIdentifiersRequired),
                                 @(hereNowRequest.shouldFetchClientState), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didFailParticipantsListLoadForChannel:channel withError:parsedData];
                }
            }
            // Check whether request was sent for participant channels list or not
            else if ([request isKindOfClass:[PNWhereNowRequest class]]) {
                
                NSString *identifier = ((PNWhereNowRequest *)request).identifier;
                
                // Check whether there is no error while loading channels
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.participantChannelsListRequestCompleted, (self.name ? self.name : self),
                                 (identifier ? identifier : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didReceiveParticipantChannelsList:parsedData];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.participantChannelsListRequestFailed, (self.name ? self.name : self),
                                 (identifier ? identifier : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didFailParticipantChannelsListLoadForIdentifier:identifier
                                               withError:parsedData];
                }
            }
            else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {
                
                SEL selector;
                NSArray *parameters;
                NSData *devicePushToken = ((PNPushNotificationsStateChangeRequest *)request).devicePushToken;
                NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
                NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;
                PNLogLevel logLevel = PNLogCommunicationChannelLayerInfoLevel;
                NSString *symbolCode = PNLoggerSymbols.connectionChannel.service.pushNotificationEnableRequestCompleted;
                
                // Check whether there is no error while processed push notifications state change
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    selector = @selector(serviceChannel:didEnablePushNotificationsOnChannels:);
                    if ([targetState isEqualToString:PNPushNotificationsState.disable]) {
                        
                        symbolCode = PNLoggerSymbols.connectionChannel.service.pushNotificationDisableRequestCompleted;
                        selector = @selector(serviceChannel:didDisablePushNotificationsOnChannels:);
                    }
                    
                    parameters = @[self, channels];
                }
                else {
                    
                    logLevel = PNLogCommunicationChannelLayerErrorLevel;
                    symbolCode = PNLoggerSymbols.connectionChannel.service.pushNotificationEnableRequestFailed;
                    selector = @selector(serviceChannel:didFailPushNotificationEnableForChannels:withError:);
                    if ([targetState isEqualToString:PNPushNotificationsState.disable]) {
                        
                        symbolCode = PNLoggerSymbols.connectionChannel.service.pushNotificationDisableRequestFailed;
                        selector = @selector(serviceChannel:didFailPushNotificationDisableForChannels:withError:);
                    }
                    
                    parameters = @[self, channels, parsedData];
                }
                if (logLevel == PNLogCommunicationChannelLayerInfoLevel) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[symbolCode, (self.name ? self.name : self), (devicePushToken ? devicePushToken : [NSNull null]),
                                 (channels ? channels : [NSNull null])];
                    }];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[symbolCode, (self.name ? self.name : self), (devicePushToken ? devicePushToken : [NSNull null]),
                                 (channels ? channels : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                }
                
                NSInvocation *invocation = [NSInvocation pn_invocationForObject:self.serviceDelegate selector:selector
                                                               retainsArguments:NO parameters:parameters];
                [invocation invoke];
            }
            else if ([request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {
                
                NSData *devicePushToken = ((PNPushNotificationsRemoveRequest *)request).devicePushToken;
                
                // Check whether there is no error while removed push notifications from specified set
                // of channels or not
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.pushNotificationRemoveRequestCompleted, (self.name ? self.name : self),
                                 (devicePushToken ? devicePushToken : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannelDidRemovePushNotifications:self];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.pushNotificationRemoveRequestFailed, (self.name ? self.name : self),
                                 (devicePushToken ? devicePushToken : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didFailPushNotificationsRemoveWithError:parsedData];
                }
            }
            else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {
                
                NSData *devicePushToken = ((PNPushNotificationsEnabledChannelsRequest *)request).devicePushToken;
                
                // Check whether there is no error while retrieved list of channels on which push notifications was enabled
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.pushNotificationsAuditRequestCompleted, (self.name ? self.name : self),
                                 (devicePushToken ? devicePushToken : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self
              didReceivePushNotificationsEnabledChannels:[PNChannel channelsWithNames:parsedData]];
                }
                else {
                    
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.pushNotificationsAuditRequestFailed, (self.name ? self.name : self),
                                 (devicePushToken ? devicePushToken : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self didFailPushNotificationEnabledChannelsReceiveWithError:parsedData];
                }
            }
            else if ([request isKindOfClass:[PNChangeAccessRightsRequest class]]) {
                
                PNAccessRightOptions *options = ((PNChangeAccessRightsRequest *)request).accessRightOptions;
                
                // Check whether there is no error while tried to change access rights.
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.accessRightsChangeRequestCompleted, (self.name ? self.name : self),
                                 (options.clientsAuthorizationKeys ? options.clientsAuthorizationKeys : [NSNull null]),
                                 (options.channels ? options.channels : [NSNull null]), @(options.rights), @(options.accessPeriodDuration),
                                 (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [(PNAccessRightsCollection *)parsedData correlateAccessRightsWithOptions:options];
                    [self.serviceDelegate serviceChannel:self didChangeAccessRights:parsedData];
                }
                else {
                    
                    ((PNError *)parsedData).associatedObject = options;
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.accessRightsChangeRequestFailed, (self.name ? self.name : self),
                                 (options.clientsAuthorizationKeys ? options.clientsAuthorizationKeys : [NSNull null]),
                                 (options.channels ? options.channels : [NSNull null]), @(options.rights), @(options.accessPeriodDuration),
                                 (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self accessRightsChangeDidFailWithError:parsedData];
                }
            }
            else if ([request isKindOfClass:[PNAccessRightsAuditRequest class]]) {
                
                PNAccessRightOptions *options = ((PNAccessRightsAuditRequest *)request).accessRightOptions;
                
                // Check whether there is no error while tried to audit access rights.
                if (![parsedData isKindOfClass:[PNError class]]) {
                    
                    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.accessRightsAuditRequestCompleted, (self.name ? self.name : self),
                                 (options.clientsAuthorizationKeys ? options.clientsAuthorizationKeys : [NSNull null]),
                                 (options.channels ? options.channels : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [(PNAccessRightsCollection *)parsedData correlateAccessRightsWithOptions:options];
                    [self.serviceDelegate serviceChannel:self didAuditAccessRights:parsedData];
                }
                else {
                    
                    ((PNError *)parsedData).associatedObject = options;
                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.connectionChannel.service.accessRightsAuditRequestFailed, (self.name ? self.name : self),
                                 (options.clientsAuthorizationKeys ? options.clientsAuthorizationKeys : [NSNull null]),
                                 (options.channels ? options.channels : [NSNull null]), (parsedData ? parsedData : [NSNull null])];
                    }];
                    
                    [self.serviceDelegate serviceChannel:self accessRightsAuditDidFailWithError:parsedData];
                }
            }
            else {
                
                [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.connectionChannel.service.parsedData, (self.name ? self.name : self),
                             (parsedData ? parsedData : [NSNull null])];
                }];
                [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.connectionChannel.service.observerRequestCompleted, (self.name ? self.name : self),
                             (request ? request : [NSNull null])];
                }];
            }
        }];
    }
}

- (void)handleRequestProcessingDidFail:(PNBaseRequest *)request withError:(PNError *)error {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.latencyMeterRequestDidFail, (self.name ? self.name : self),
                    (error ? error : [NSNull null])];
        }];
    }
    // Check whether request is 'Time token' request or not
    else if ([request isKindOfClass:[PNTimeTokenRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.timeTokenRequestFailed, (self.name ? self.name : self),
                    (error ? error : [NSNull null])];
        }];

        [self.serviceDelegate serviceChannel:self receiveTimeTokenDidFailWithError:error];
    }
    // Check whether request was sent for state retrieval / update
    else if ([request isKindOfClass:[PNClientStateRequest class]] ||
            [request isKindOfClass:[PNClientStateUpdateRequest class]]) {
        
        NSDictionary *clientData = ([request isKindOfClass:[PNClientStateUpdateRequest class]] ? [request valueForKey:@"state"] : nil);
        PNClient *client = [PNClient clientForIdentifier:[request valueForKey:@"clientIdentifier"]
                                                 channel:[request valueForKey:@"channel"] andData:clientData];

        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = client;
        }

        NSString *symbolCode = PNLoggerSymbols.connectionChannel.service.clientStateAuditRequestFailed;
        SEL errorSelector = @selector(serviceChannel:clientStateReceiveDidFailWithError:);
        if ([request isKindOfClass:[PNClientStateUpdateRequest class]]) {

            symbolCode = PNLoggerSymbols.connectionChannel.service.clientStateUpdateRequestFailed;
            errorSelector = @selector(serviceChannel:clientStateUpdateDidFailWithError:);
        }

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[symbolCode, (self.name ? self.name : self), (error ? error : [NSNull null]), (client ? client : [NSNull null])];
        }];

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:errorSelector withObject:self withObject:error];
        #pragma clang diagnostic pop
    }
    // Check whether this is 'Post message' request or not
    else if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
            
            // Retrieve reference on message which has been sent
            PNMessage *message = ((PNMessagePostRequest *)request).message;

            return @[PNLoggerSymbols.connectionChannel.service.messageSendRequestFailed, (self.name ? self.name : self),
                     (message.message ? message.message : [NSNull null]), (message.channel ? message.channel : [NSNull null]),
                     (error ? error : [NSNull null])];
        }];

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

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.historyRequestFailed, (self.name ? self.name : self),
                     (historyRequest.channel ? historyRequest.channel : [NSNull null]),
                     (historyRequest.startDate ? historyRequest.startDate : [NSNull null]),
                     (historyRequest.endDate ? historyRequest.endDate : [NSNull null]), @(historyRequest.limit),
                     @(historyRequest.shouldRevertMessages), @(historyRequest.shouldIncludeTimeToken),
                     (error ? error : [NSNull null])];
        }];
        
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

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.participantsListRequestFailed, (self.name ? self.name : self),
                     (hereNowRequest.channel ? hereNowRequest.channel : [NSNull null]),
                     @(hereNowRequest.isClientIdentifiersRequired), @(hereNowRequest.shouldFetchClientState),
                     (error ? error : [NSNull null])];
        }];

        // Notify delegate about participants list can't be downloaded
        [self.serviceDelegate serviceChannel:self
       didFailParticipantsListLoadForChannel:hereNowRequest.channel withError:error];
    }
    // Check whether this is 'Where now' request or not
    else if ([request isKindOfClass:[PNWhereNowRequest class]]) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.participantChannelsListRequestFailed, (self.name ? self.name : self),
                     (((PNWhereNowRequest *)request).identifier ? ((PNWhereNowRequest *)request).identifier : [NSNull null]),
                     (error ? error : [NSNull null])];
        }];

        // Notify delegate about participant channels list can't be downloaded.
        [self.serviceDelegate serviceChannel:self
                didFailParticipantChannelsListLoadForIdentifier:((PNWhereNowRequest *)request).identifier withError:error];
    }
    // Check whether this is 'Push notification state change' request or not
    else if ([request isKindOfClass:[PNPushNotificationsStateChangeRequest class]]) {

        NSArray *channels = ((PNPushNotificationsStateChangeRequest *)request).channels;
        NSString *targetState = ((PNPushNotificationsStateChangeRequest *)request).targetState;
        
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNPushNotificationsStateChangeRequest *)request).devicePushToken;
        }
        if ([targetState isEqualToString:PNPushNotificationsState.enable]) {

            [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.service.pushNotificationEnableRequestFailed, (self.name ? self.name : self),
                         (error.associatedObject ? error.associatedObject : [NSNull null]), (channels ? channels : [NSNull null]),
                         (error ? error : [NSNull null])];
            }];

            [self.serviceDelegate serviceChannel:self didFailPushNotificationEnableForChannels:channels withError:error];
        }
        else {

            [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.service.pushNotificationDisableRequestFailed, (self.name ? self.name : self),
                         (error.associatedObject ? error.associatedObject : [NSNull null]), (channels ? channels : [NSNull null]),
                         (error ? error : [NSNull null])];
            }];

            [self.serviceDelegate serviceChannel:self didFailPushNotificationDisableForChannels:channels withError:error];
        }
    }
    // Check whether this is 'Push notification remove' request or not
    else if ([request isKindOfClass:[PNPushNotificationsRemoveRequest class]]) {
        
        NSData *devicePushToken = ((PNPushNotificationsRemoveRequest *)request).devicePushToken;

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.pushNotificationRemoveRequestFailed, (self.name ? self.name : self),
                    (devicePushToken ? devicePushToken : [NSNull null]), (error ? error : [NSNull null])];
        }];
        
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNPushNotificationsRemoveRequest *)request).devicePushToken;
        }
        [self.serviceDelegate serviceChannel:self didFailPushNotificationsRemoveWithError:error];
    }
    // Check whether this is 'Push notification enabled channels' request or not
    else if ([request isKindOfClass:[PNPushNotificationsEnabledChannelsRequest class]]) {
        
        NSData *devicePushToken = ((PNPushNotificationsEnabledChannelsRequest *)request).devicePushToken;

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.pushNotificationsAuditRequestFailed, (self.name ? self.name : self),
                    (devicePushToken ? devicePushToken : [NSNull null]), (error ? error : [NSNull null])];
        }];
        
        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNPushNotificationsEnabledChannelsRequest *)request).devicePushToken;
        }
        [self.serviceDelegate serviceChannel:self didFailPushNotificationEnabledChannelsReceiveWithError:error];
    }
    // Check whether this is 'Access rights change' request or not
    else if ([request isKindOfClass:[PNChangeAccessRightsRequest class]]) {
        
        PNAccessRightOptions *options = ((PNChangeAccessRightsRequest *)request).accessRightOptions;

        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = options;
        }
        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.accessRightsChangeRequestFailed, (self.name ? self.name : self),
                     (options.clientsAuthorizationKeys ? options.clientsAuthorizationKeys : [NSNull null]),
                     (options.channels ? options.channels : [NSNull null]), @(options.rights), @(options.accessPeriodDuration),
                     (error ? error : [NSNull null])];
        }];

        [self.serviceDelegate serviceChannel:self accessRightsChangeDidFailWithError:error];
    }
    // Check whether this is 'Access rights audit' request or not
    else if ([request isKindOfClass:[PNAccessRightsAuditRequest class]]) {
        
        PNAccessRightOptions *options = ((PNAccessRightsAuditRequest *)request).accessRightOptions;

        if (error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {
            
            error.associatedObject = ((PNAccessRightsAuditRequest *)request).accessRightOptions;
        }
        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.accessRightsAuditRequestFailed, (self.name ? self.name : self),
                     (options.clientsAuthorizationKeys ? options.clientsAuthorizationKeys : [NSNull null]),
                     (options.channels ? options.channels : [NSNull null]), (error ? error : [NSNull null])];
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

- (PNMessage *)sendMessage:(id)object toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory {

    // Create object instance
    PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:object forChannel:channel compressed:shouldCompressMessage
                                             storeInHistory:shouldStoreInHistory error:&error];

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
        [self sendMessage:message.message toChannel:message.channel compressed:message.shouldCompressMessage
           storeInHistory:message.shouldStoreInHistory];
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
    [self.delegate isPubNubServiceAvailable:YES checkCompletionBlock:^(BOOL available) {
        
        if ([self isConnected] && available) {
            
            // Asking to schedule next request
            [self scheduleNextRequest];
        }
    }];
}


#pragma mark - Requests queue delegate methods

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];
    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.connectionChannel.service.willStartRequestProcessing, (self.name ? self.name : self),
                (request ? request : [NSNull null])];
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
    [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.connectionChannel.service.didSendRequest, (self.name ? self.name : self),
                (request ? request : [NSNull null])];
    }];


    // If we are not waiting for request completion, inform delegate
    // immediately
    if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

        // Checking whether request was sent to measure network latency or not
        if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.service.latencyMeterRequestSent, (self.name ? self.name : self)];
            }];
            [(PNLatencyMeasureRequest *)request markStartTime];
        }
    }
    else {

        // Check whether this is 'Post message' request or not
        if ([request isKindOfClass:[PNMessagePostRequest class]]) {

            [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                return @[PNLoggerSymbols.connectionChannel.service.messagePostRequestSent, (self.name ? self.name : self)];
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
    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.connectionChannel.service.requestSendingDidFail, (self.name ? self.name : self),
                (request ? request : [NSNull null])];
    }];


    // Check whether request can be rescheduled or not
    if (![request canRetry] || error.code == kPNRequestCantBeProcessedWithOutRescheduleError) {

        [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.requestWontBeSent, (self.name ? self.name : self),
                    (request ? request : [NSNull null])];
        }];

        // Removing failed request from queue
        [self destroyRequest:request];

        [self handleRequestProcessingDidFail:request withError:error];
    }


    // Check whether connection available or not
    [self.delegate isPubNubServiceAvailable:NO checkCompletionBlock:^(BOOL available) {
        
        if ([self isConnected] && available) {
            
            [self scheduleNextRequest];
        }
    }];
}

- (void)requestsQueue:(PNRequestsQueue *)queue didCancelRequest:(PNBaseRequest *)request {

    // Check whether request is 'Latency meter' request or not
    if ([request isKindOfClass:[PNLatencyMeasureRequest class]]) {

        [PNLogger logCommunicationChannelInfoMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.connectionChannel.service.latencyMeterRequestSendingCanceled, (self.name ? self.name : self)];
        }];

        // Removing 'Latency meter' request because PubNub client is not interested in delayed response on network
        // measurements
        [self destroyRequest:request];
    }

    // Forward to the super class
    [super requestsQueue:queue didCancelRequest:request];
}

- (void)shouldRequestsQueue:(PNRequestsQueue *)queue removeCompletedRequest:(PNBaseRequest *)request
            checkCompletion:(void(^)(BOOL))checkCompletionBlock {

    [self pn_dispatchAsynchronouslyBlock:^{

        BOOL shouldRemoveRequest = YES;

        // Check whether leave request has been sent to PubNub
        // services or not
        if ([self isWaitingRequestCompletion:request.shortIdentifier]) {

            shouldRemoveRequest = NO;
        }

        checkCompletionBlock(shouldRemoveRequest);
    }];
}

#pragma mark -


@end
