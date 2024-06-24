#import "PubNub+Publish.h"
#import "PNBasePublishRequest+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#ifndef PUBNUB_DISABLE_LOGGER
#import "PNLogMacro.h"
#endif // PUBNUB_DISABLE_LOGGER
#import "PNHelpers.h"

// Deprecated
#import "PNAPICallBuilder+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (PublishProtected)


#pragma mark - Composite message publish

/// Send provided Foundation object to the **PubNub** network.
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: Dictionary with payloads for different vendors (Apple with `'apns'` key and Google with `'gcm'`).
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - ttl: How long message should be stored in channel's storage. If **0** it will be stored forever or if
///   `nil` - depends from account configuration.
///   - compressed Whether message should be compressed before sending or not.
///   - replicate: Whether message should be replicated across the **PubNub** network and sent simultaneously to all
///   subscribed clients on a channel.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** network to filter messages.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Publish completion block which.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
                  ttl:(nullable NSNumber *)ttl
           compressed:(BOOL)compressed
      withReplication:(BOOL)replicate
             metadata:(nullable NSDictionary<NSString *, id> *)metadata
      queryParameters:(nullable NSDictionary *)queryParameters
           completion:(nullable PNPublishCompletionBlock)block;


#pragma mark - Signal

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// - Parameters:
///   - message Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be sent with signal.
///   - channel: Name of the channel to which signal should be sent.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Signal completion block.
- (void)signal:(id)message
                channel:(NSString *)channel
    withQueryParameters:(nullable NSDictionary *)queryParameters
             completion:(nullable PNSignalCompletionBlock)block;


#pragma mark - Message helper

/// Helper method which allow to calculate resulting message before it will be sent to the **PubNub** network.
///
/// > Note: Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - compressMessage: Whether message should be compressed before sending or not.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - ttl: How long message should be stored in channel's storage. If **0** it will be stored forever or
///   if `nil` - depends from account configuration.
///   - replicate: Whether message should be replicated across the PubNub network and sent simultaneously to all
///   subscribed clients on a channel.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
                  ttl:(nullable NSNumber *)ttl
      withReplication:(BOOL)replicate
             metadata:(nullable NSDictionary<NSString *, id> *)metadata
      queryParameters:(nullable NSDictionary *)queryParameters
           completion:(PNMessageSizeCalculationCompletionBlock)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");


#pragma mark - Handlers

/// Handle publish builder perform with block call.
///
/// > Note: Logic moved into separate method because it shared between two almost identical API calls (regular publish
/// and fire which doesn't store message in storage and won't replicate it).
///
/// - Parameters:
///   - flags: List of conditional flags which has been generated by builder on user request.
///   - parameters: List of user-provided data which will be consumed by used API endpoint.
- (void)handlePublishBuilderExecutionWithFlags:(NSArray<NSString *> *)flags parameters:(NSDictionary *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Publish)


#pragma mark - Publish API builder interdace (deprecated)

- (PNPublishFileMessageAPICallBuilder * (^)(void))publishFileMessage {
    PNPublishFileMessageAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    
    builder = [PNPublishFileMessageAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                              NSDictionary *parameters) {
        NSString *identifier = parameters[NSStringFromSelector(@selector(fileIdentifier))];
        NSString *filename = parameters[NSStringFromSelector(@selector(fileName))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        NSNumber *shouldStore = parameters[NSStringFromSelector(@selector(shouldStore))];
        NSNumber *ttl = parameters[NSStringFromSelector(@selector(ttl))];
        
        if (shouldStore && !shouldStore.boolValue) ttl = nil;

        PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:channel
                                                                                fileIdentifier:identifier
                                                                                          name:filename];
        request.metadata = parameters[NSStringFromSelector(@selector(metadata))];
        request.message = parameters[NSStringFromSelector(@selector(message))];
        request.arbitraryQueryParameters = parameters[@"queryParam"];
        request.store = shouldStore ? shouldStore.boolValue : YES;
        request.ttl = ttl.unsignedIntegerValue;
        
        [weakSelf publishFileMessageWithRequest:request completion:parameters[@"block"]];
    }];
    
    return ^PNPublishFileMessageAPICallBuilder * {
        return builder;
    };
}

- (PNPublishAPICallBuilder * (^)(void))publish {
    PNPublishAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;

    builder = [PNPublishAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *parameters) {
        [weakSelf handlePublishBuilderExecutionWithFlags:flags parameters:parameters];
    }];
    
    return ^PNPublishAPICallBuilder * {
        return builder;
    };
}

- (PNPublishAPICallBuilder * (^)(void))fire {
    PNPublishAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;

    builder = [PNPublishAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                   NSDictionary *parameters) {
        [weakSelf handlePublishBuilderExecutionWithFlags:flags parameters:parameters];
    }];

    [builder setValue:@NO forParameter:NSStringFromSelector(@selector(shouldStore))];
    [builder setValue:@NO forParameter:NSStringFromSelector(@selector(replicate))];
    
    return ^PNPublishAPICallBuilder * {
        return builder;
    };
}

- (PNSignalAPICallBuilder * (^)(void))signal {
    PNSignalAPICallBuilder * builder = nil;
    __weak __typeof(self) weakSelf = self;
    builder = [PNSignalAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                  NSDictionary *parameters) {
        id message = parameters[NSStringFromSelector(@selector(message))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];
        
        [weakSelf signal:message channel:channel withQueryParameters:queryParam completion:block];
    }];
    
    return ^PNSignalAPICallBuilder * {
        return builder;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(void))size {
    PNPublishSizeAPICallBuilder *builder = nil;
    builder = [PNPublishSizeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *parameters) {
        id message = parameters[NSStringFromSelector(@selector(message))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        NSNumber *shouldStore = parameters[NSStringFromSelector(@selector(shouldStore))];
        NSNumber *ttl = parameters[NSStringFromSelector(@selector(ttl))];
        NSNumber *compressed = parameters[NSStringFromSelector(@selector(compress))];
        NSNumber *replicate = parameters[NSStringFromSelector(@selector(replicate))];
        NSDictionary *metadata = parameters[NSStringFromSelector(@selector(metadata))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        id block = parameters[@"block"];

        if (shouldStore && !shouldStore.boolValue) ttl = nil;
        [self sizeOfMessage:message
                  toChannel:channel
                 compressed:compressed.boolValue
             storeInHistory:(shouldStore ? shouldStore.boolValue : YES)
                        ttl:ttl
            withReplication:(replicate ? replicate.boolValue : YES)
                   metadata:metadata
            queryParameters:queryParam
                 completion:block];
    }];
    
    return ^PNPublishSizeAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Files message

- (void)publishFileMessageWithRequest:(PNPublishFileMessageRequest *)userRequest
                           completion:(PNPublishCompletionBlock)block {
    if (!userRequest.retried) userRequest.sequenceNumber = [self.sequenceManager nextSequenceNumber:YES];
    if (!userRequest.cryptoModule) userRequest.cryptoModule = self.configuration.cryptoModule;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNPublishStatus class]];
    PNParsedRequestCompletionBlock handler;

#ifndef PUBNUB_DISABLE_LOGGER
    PNLogAPICall(self.logger, @"<PubNub::API> Publish '%@' file message to '%@' channel%@%@%@",
                 (userRequest.identifier ?: @"<error>"),
                 (userRequest.channel ?: @"<error>"),
                 (userRequest.metadata ? [NSString stringWithFormat:@" with metadata (%@)", userRequest.metadata] : @""),
                 (!userRequest.shouldStore ? @" which won't be saved in history" : @""),
                 [NSString stringWithFormat:@": %@", (userRequest.preFormattedMessage ?: @"<error>")]);
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNPublishStatus *, PNPublishStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self publishFileMessageWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}


#pragma mark - Plain message publish

- (void)publishWithRequest:(PNPublishRequest *)userRequest completion:(PNPublishCompletionBlock)block {
    if (!userRequest.retried) userRequest.sequenceNumber = [self.sequenceManager nextSequenceNumber:YES];
    if (!userRequest.cryptoModule) userRequest.cryptoModule = self.configuration.cryptoModule;
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNPublishStatus class]];
    PNParsedRequestCompletionBlock handler;

#ifndef PUBNUB_DISABLE_LOGGER
    PNLogAPICall(self.logger, @"<PubNub::API> Publish%@ message to '%@' channel%@%@%@",
                 (userRequest.shouldCompress ? @" compressed" : @""),
                 (userRequest.channel ?: @"<error>"),
                 (userRequest.metadata ? [NSString stringWithFormat:@" with metadata (%@)", userRequest.metadata] : @""),
                 (!userRequest.shouldStore ? @" which won't be saved in history" : @""),
                 (!userRequest.shouldCompress ? [NSString stringWithFormat:@": %@",
                                                 (userRequest.message ?: @"<error>")] : @"."));
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNPublishStatus *, PNPublishStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self publishWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)publish:(id)message toChannel:(NSString *)channel withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message toChannel:channel withMetadata:nil completion:block];
}

- (void)publish:(id)message
       toChannel:(NSString *)channel
    withMetadata:(NSDictionary<NSString *, id> *)metadata
      completion:(PNPublishCompletionBlock)block {
    [self publish:message toChannel:channel compressed:NO withMetadata:metadata completion:block];
}

- (void)publish:(id)message
         toChannel:(NSString *)channel
        compressed:(BOOL)compressed
    withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message toChannel:channel compressed:compressed withMetadata:nil completion:block];
}

- (void)publish:(id)message
       toChannel:(NSString *)channel
      compressed:(BOOL)compressed
    withMetadata:(NSDictionary<NSString *, id> *)metadata
      completion:(PNPublishCompletionBlock)block {
    [self publish:message
         toChannel:channel
    storeInHistory:YES
        compressed:compressed
      withMetadata:metadata
        completion:block];
}

- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
    withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message toChannel:channel storeInHistory:shouldStore withMetadata:nil completion:block];
}

- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
      withMetadata:(NSDictionary<NSString *, id> *)metadata
        completion:(PNPublishCompletionBlock)block {
    [self publish:message
         toChannel:channel
    storeInHistory:shouldStore
        compressed:NO
      withMetadata:metadata
        completion:block];
}

- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
        compressed:(BOOL)compressed
    withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message
         toChannel:channel
    storeInHistory:shouldStore
        compressed:compressed
      withMetadata:nil
        completion:block];
}

- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
        compressed:(BOOL)compressed
      withMetadata:(NSDictionary<NSString *, id> *)metadata
        completion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:nil
       storeInHistory:shouldStore
           compressed:compressed
         withMetadata:metadata
           completion:block];
}


#pragma mark - Composite message publish

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
       withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message toChannel:channel mobilePushPayload:payloads withMetadata:nil completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
           compressed:NO
         withMetadata:metadata
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
           compressed:(BOOL)compressed
       withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
           compressed:compressed
         withMetadata:nil
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
           compressed:(BOOL)compressed
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
       storeInHistory:YES
           compressed:compressed
         withMetadata:metadata
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
       storeInHistory:shouldStore
         withMetadata:nil
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
       storeInHistory:shouldStore
           compressed:NO
         withMetadata:metadata
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
           compressed:(BOOL)compressed
       withCompletion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
       storeInHistory:shouldStore
           compressed:compressed
         withMetadata:nil
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
           compressed:(BOOL)compressed
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNPublishCompletionBlock)block {
    [self publish:message
            toChannel:channel
    mobilePushPayload:payloads
       storeInHistory:shouldStore
                  ttl:nil
           compressed:compressed
      withReplication:YES
             metadata:metadata
      queryParameters:nil
           completion:block];
}

- (void)publish:(id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
                  ttl:(NSNumber *)ttl
           compressed:(BOOL)compressed
      withReplication:(BOOL)replicate
             metadata:(NSDictionary<NSString *, id> *)metadata
      queryParameters:(NSDictionary *)queryParameters
           completion:(PNPublishCompletionBlock)block {

    PNPublishRequest *request = [PNPublishRequest requestWithChannel:channel];
    request.arbitraryQueryParameters = queryParameters;
    request.replicate = replicate;
    request.compress = compressed;
    request.metadata = metadata;
    request.payloads = payloads;
    request.store = shouldStore;
    request.message = message;

    if (ttl) request.ttl = ttl.unsignedIntegerValue;

    [self publishWithRequest:request completion:block];
}


#pragma mark - Signal

- (void)sendSignalWithRequest:(PNSignalRequest *)userRequest completion:(PNSignalCompletionBlock)handlerBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNSignalStatus class]];
    PNSignalCompletionBlock block = [handlerBlock copy];
    PNParsedRequestCompletionBlock handler;

#ifndef PUBNUB_DISABLE_LOGGER
    PNLogAPICall(self.logger, @"<PubNub::API> Signal to '%@' channel.", (userRequest.channel ?: @"<error>"));
#endif // PUBNUB_DISABLE_LOGGER

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNSignalStatus *, PNSignalStatus *> *result) {
        PNStrongify(self);

        if (result.status.isError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result.status.retryBlock = ^{
                [self sendSignalWithRequest:userRequest completion:block];
            };
#pragma clang diagnostic pop
        }

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)signal:(id)message channel:(NSString *)channel withCompletion:(PNSignalCompletionBlock)block {
    [self signal:message channel:channel withQueryParameters:nil completion:block];
}

- (void)signal:(id)message
                channel:(NSString *)channel
    withQueryParameters:(NSDictionary *)queryParameters
             completion:(PNSignalCompletionBlock)block {

    PNSignalRequest *request = [PNSignalRequest requestWithChannel:channel signal:message];
    request.arbitraryQueryParameters = queryParameters;
    [self sendSignalWithRequest:request completion:block];
}


#pragma mark - Message helper

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message toChannel:channel withMetadata:nil completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message toChannel:channel compressed:NO withMetadata:metadata completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message toChannel:channel compressed:compressMessage withMetadata:nil completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message
              toChannel:channel
             compressed:compressMessage
         storeInHistory:YES
           withMetadata:metadata
             completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message
              toChannel:channel
         storeInHistory:shouldStore
           withMetadata:nil
             completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       storeInHistory:(BOOL)shouldStore
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message
              toChannel:channel
             compressed:NO
         storeInHistory:shouldStore
           withMetadata:metadata
             completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message
              toChannel:channel
             compressed:compressMessage
         storeInHistory:shouldStore
           withMetadata:nil
             completion:block];
}

- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    [self sizeOfMessage:message
              toChannel:channel
             compressed:compressMessage
         storeInHistory:shouldStore
                    ttl:nil
        withReplication:YES
               metadata:metadata
        queryParameters:nil
             completion:block];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)sizeOfMessage:(id)__unused message
            toChannel:(NSString *)__unused channel
           compressed:(BOOL)__unused compressMessage
       storeInHistory:(BOOL)__unused shouldStore
                  ttl:(NSNumber *)__unused ttl
      withReplication:(BOOL)__unused replicate
             metadata:(NSDictionary<NSString *, id> *)__unused metadata
      queryParameters:(NSDictionary *)__unused queryParameters
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    pn_dispatch_async(self.callbackQueue, ^{
        block(0);
    });
}
#pragma clang diagnostic pop


#pragma mark - Handlers

- (void)handlePublishBuilderExecutionWithFlags:(NSArray<NSString *> *)flags parameters:(NSDictionary *)parameters {
    NSNumber *shouldStore = parameters[NSStringFromSelector(@selector(shouldStore))];
    NSNumber *ttl = parameters[NSStringFromSelector(@selector(ttl))];
    NSNumber *compressed = parameters[NSStringFromSelector(@selector(compress))];
    NSNumber *replicate = parameters[NSStringFromSelector(@selector(replicate))];

    if (shouldStore && !shouldStore.boolValue) ttl = nil;
    
    [self publish:parameters[NSStringFromSelector(@selector(message))]
            toChannel:parameters[NSStringFromSelector(@selector(channel))]
    mobilePushPayload:parameters[NSStringFromSelector(@selector(payloads))]
       storeInHistory:(shouldStore ? shouldStore.boolValue : YES)
                  ttl:ttl
           compressed:compressed.boolValue
      withReplication:(replicate ? replicate.boolValue : YES)
             metadata:parameters[NSStringFromSelector(@selector(metadata))]
      queryParameters:parameters[@"queryParam"]
           completion:parameters[@"block"]];
}

#pragma mark -


@end
