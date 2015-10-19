/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Publish.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Private interface declaration

@interface PubNub (PublishPrivate)


#pragma mark - Misc

/**
 @brief  Compose set of parameters which is required to publish message.
 
 @param message         Reference on message which should be published.
 @param channel         Reference on name of the channel to which message should be published.
 @param compressMessage Whether message should be compressed before publish.
 @param shouldStore     Whether message should be stored in history storage or not.
 
 @return Configured and ready to use request parameters instance.
 
 @since 4.0
 */
- (PNRequestParameters *)requestParametersForMessage:(NSString *)message
                                           toChannel:(NSString *)channel
                                          compressed:(BOOL)compressMessage
                                      storeInHistory:(BOOL)shouldStore;

/**
 @brief      Merge user-specified message with push payloads into single message which will be 
             processed on \b PubNub service.
 @discussion In case if aside from \c message has been passed \c payloads this method will merge
             them into format known by \b PubNub service and will cause further push distribution
             to specified vendors.
 
 @param message  Message which should be merged with \c payloads.
 @param payloads Dictionary with payloads for different vendors (Apple with "apns" key and Google 
                 with "gcm").
 
 @return Merged message or original message if there is no data in \c payloads.
 
 @since 4.0
 */
- (NSDictionary *)mergedMessage:(id)message withMobilePushPayload:(NSDictionary *)payloads;

/**
 @brief  Try perform encryption of data which should be pushed to \b PubNub services.
 
 @param message Reference on data which \b PNAES should try to encrypt.
 @param key     Reference on cipher key which should be used during encryption.
 @param error   Reference on pointer into which data encryption error will be passed.
 
 @return Encrypted Base64-encoded string or original message, if there is no \c key has been passed.
         \c nil will be returned in case if encryption failed.
 
 @since 4.0
 */
- (NSString *)encryptedMessage:(NSString *)message withCipherKey:(NSString *)key
                         error:(NSError **)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Publish)


#pragma mark - Plain message publish

- (void)  publish:(id)message toChannel:(NSString *)channel
   withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel compressed:NO withCompletion:block];
}

- (void)  publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
   withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel storeInHistory:YES compressed:compressed
   withCompletion:block];
}

- (void) publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
  withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel storeInHistory:shouldStore compressed:NO
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:nil storeInHistory:shouldStore
       compressed:compressed withCompletion:block];
}


#pragma mark - Composite message publish

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads withCompletion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads compressed:NO
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel mobilePushPayload:(NSDictionary *)payloads
     compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:YES
       compressed:compressed withCompletion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore
       compressed:NO withCompletion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block {

    // Push further code execution on secondary queue to make service queue responsive during
    // JSON serialization and encryption process.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        BOOL encrypted = NO;
        NSError *publishError = nil;
        NSString *messageForPublish = [PNJSON JSONStringFrom:message withError:&publishError];

        // Encrypt message in case if serialization to JSON was successful.
        if (!publishError) {

            // Try perform user message encryption.
            NSString *encryptedMessage = [self encryptedMessage:messageForPublish
                                                  withCipherKey:self.configuration.cipherKey
                                                          error:&publishError];
            encrypted = ![messageForPublish isEqualToString:encryptedMessage];
            messageForPublish = [encryptedMessage copy];
        }

        // Merge user message with push notification payloads (if provided).
        if (!publishError && [payloads count]) {

            NSDictionary *mergedData = [self mergedMessage:(encrypted ? messageForPublish : message)
                                     withMobilePushPayload:payloads];
            messageForPublish = [PNJSON JSONStringFrom:mergedData withError:&publishError];
        }
        PNRequestParameters *parameters = [self requestParametersForMessage:messageForPublish
                                                                  toChannel:channel
                                                                 compressed:compressed
                                                             storeInHistory:shouldStore];
        NSData *publishData = nil;
        if (compressed) {

            NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];
            NSData *compressedBody = [PNGZIP GZIPDeflatedData:messageData];
            publishData = (compressedBody?: [@"" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        
        DDLogAPICall([[self class] ddLogLevel], @"<PubNub> Publish%@ message to '%@' channel%@%@",
                     (compressed ? @" compressed" : @""), (channel?: @"<error>"),
                     (!shouldStore ? @" which won't be saved in hisotry" : @""),
                     (!compressed ? [NSString stringWithFormat:@": %@",
                                     (messageForPublish?: @"<error>")] : @"."));

        [self processOperation:PNPublishOperation withParameters:parameters data:publishData
               completionBlock:^(PNStatus *status) {
                   
           // Silence static analyzer warnings.
           // Code is aware about this case and at the end will simply call on 'nil' object method.
           // In most cases if referenced object become 'nil' it mean what there is no more need in
           // it and probably whole client instance has been deallocated.
           #pragma clang diagnostic push
           #pragma clang diagnostic ignored "-Wreceiver-is-weak"
           if (status.isError) {
                
               status.retryBlock = ^{
                   
                   [weakSelf publish:message toChannel:channel mobilePushPayload:payloads
                      storeInHistory:shouldStore compressed:compressed withCompletion:block];
               };
           }
           [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
           #pragma clang diagnostic pop
       }];
    });
}


#pragma mark - Message helper

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:NO withCompletion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:compressMessage storeInHistory:YES
         withCompletion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:NO storeInHistory:shouldStore
         withCompletion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    if (block) {
        
        // Push further code execution on secondary queue to make service queue responsive during
        // JSON serialization and encryption process.
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *publishError = nil;
            NSString *messageForPublish = [PNJSON JSONStringFrom:message withError:&publishError];
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object method.
            // In most cases if referenced object become 'nil' it mean what there is no more need in
            // it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            // Encrypt message in case if serialization to JSON was successful.
            if (!publishError) {
                
                // Try perform user message encryption.
                messageForPublish = [self encryptedMessage:messageForPublish
                                             withCipherKey:self.configuration.cipherKey
                                                     error:&publishError];
            }
            PNRequestParameters *parameters = [self requestParametersForMessage:messageForPublish
                                                                      toChannel:channel
                                                                     compressed:compressMessage
                                                                 storeInHistory:shouldStore];
            NSData *publishData = nil;
            if (compressMessage) {
                
                NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];
                NSData *compressedBody = [PNGZIP GZIPDeflatedData:messageData];
                publishData = (compressedBody?: [@"" dataUsingEncoding:NSUTF8StringEncoding]);
            }
            NSInteger size = [weakSelf packetSizeForOperation:PNPublishOperation
                                               withParameters:parameters data:publishData];
            pn_dispatch_async(weakSelf.callbackQueue, ^{
                
                block(size);
            });
            #pragma clang diagnostic pop
        });
    }
}


#pragma mark - Misc

- (PNRequestParameters *)requestParametersForMessage:(NSString *)message
                                           toChannel:(NSString *)channel
                                          compressed:(BOOL)compressMessage
                                      storeInHistory:(BOOL)shouldStore {
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    if ([channel length]) {
        
        [parameters addPathComponent:[PNString percentEscapedString:channel]
                      forPlaceholder:@"{channel}"];
    }
    if (!shouldStore) {
        
        [parameters addQueryParameter:@"0" forFieldName:@"store"];
    }
    if (([message isKindOfClass:[NSString class]] && [message length]) || message) {
        
        [parameters addPathComponent:(!compressMessage ? [PNString percentEscapedString:message] :
                                      @"")
                      forPlaceholder:@"{message}"];
    }
    
    return parameters;
}

- (NSDictionary *)mergedMessage:(id)message withMobilePushPayload:(NSDictionary *)payloads {

    // Convert passed message to mutable dictionary into which required by push notification
    // delivery service provider data will be added.
    NSDictionary *originalMessage =  (!message ? @{} : ([message isKindOfClass:[NSDictionary class]] ?
                                                        message : @{@"pn_other":message}));
    NSMutableDictionary *mergedMessage = [originalMessage mutableCopy];
    for (NSString *pushProviderType in payloads) {

        id payload = payloads[pushProviderType];
        NSString *providerKey = pushProviderType;
        if (![pushProviderType hasPrefix:@"pn_"]) {
            
            providerKey = [NSString stringWithFormat:@"pn_%@", pushProviderType];
            if ([pushProviderType isEqualToString:@"aps"]) {
                
                payload = @{pushProviderType:payload};
                providerKey = @"pn_apns";
            }
        }
        [mergedMessage setValue:payload forKey:providerKey];
    }
    
    return [mergedMessage copy];
}

- (NSString *)encryptedMessage:(NSString *)message withCipherKey:(NSString *)key
                         error:(NSError *__autoreleasing *)error {
    
    NSString *encryptedMessage = message;
    if ([key length]) {
        
        NSData *JSONData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSString *JSONString = [PNAES encrypt:JSONData withKey:key andError:error];
        if (*error == nil) {
            
            // PNAES encryption output is NSString which is valid JSON object from PubNub
            // service perspective, but it should be decorated with " (this done internally
            // by helper when it need to create JSON string).
            encryptedMessage = [PNJSON JSONStringFrom:JSONString withError:error];
        }
        else {

            encryptedMessage = nil;
        }
    }
    
    return encryptedMessage;
}

#pragma mark -


@end
