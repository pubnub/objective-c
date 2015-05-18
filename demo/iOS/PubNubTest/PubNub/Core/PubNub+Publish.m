/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Publish.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Private interface declaration

@interface PubNub (PublishPrivate)


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'publish' API
         group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'publish' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedPublishResponse:(id)response;


#pragma mark - Misc

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
- (id)mergedMessage:(id)message withMobilePushPayload:(NSDictionary *)payloads;

/**
 @brief  Try perform encryption of data which should be pushed to \b PubNub services.
 
 @param message Referebce on data which \b PNAES should try to encrypt.
 @param key     Reference on cipher key which should be used during encryption.
 @param error   Reference on pointer into which data encryption error will be passed.
 
 @return Encrypted Base64-encoded string or original message, if there is no \c key has been passed.
         \c nil will be returned in case if encrytption failed.
 
 @since 4.0
 */
- (NSString *)encryptedMessag:(NSString *)message withCipherKey:(NSString *)key
                        error:(NSError **)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Publish)


#pragma mark - Plain message publish

- (void)publish:(id)message toChannel:(NSString *)channel
 withCompletion:(PNCompletionBlock)block {

    [self publish:message toChannel:channel compressed:NO withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
 withCompletion:(PNCompletionBlock)block {

    [self publish:message toChannel:channel storeInHistory:YES compressed:compressed
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
 withCompletion:(PNCompletionBlock)block {

    [self publish:message toChannel:channel storeInHistory:shouldStore compressed:NO
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(PNCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:nil storeInHistory:shouldStore
       compressed:compressed withCompletion:block];
}


#pragma mark - Composited message publish

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads withCompletion:(PNCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads compressed:NO
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel mobilePushPayload:(NSDictionary *)payloads
     compressed:(BOOL)compressed withCompletion:(PNCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:YES
       compressed:compressed withCompletion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(PNCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore
       compressed:NO withCompletion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(PNCompletionBlock)block {

    if (message || [payloads count]) {

        __weak __typeof(self) weakSelf = self;

        // Dispatching async on private queue which is able to serialize access with client
        // configuration data.
        dispatch_async(self.serviceQueue, ^{

            __strong __typeof(self) strongSelf = weakSelf;
            NSString *publishKey = [PNString percentEscapedString:strongSelf.publishKey];
            NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
            NSString *cipherKey = [strongSelf.cipherKey copy];

            // Push further code execution on secondary queue to make main queue responsive during
            // JSON serialization and encryption process.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                __strong __typeof(self) strongSelfForPreparation = weakSelf;
                NSError *publishError = nil;
                id messageForPublish = [PNJSON JSONStringFrom:message withError:&publishError];
                
                if (!publishError) {

                    // Append to encrypted message push payloads (if provided).
                    messageForPublish = [self mergedMessage:messageForPublish
                                      withMobilePushPayload:payloads];
                    messageForPublish = [strongSelfForPreparation encryptedMessag:messageForPublish
                                                                    withCipherKey:cipherKey
                                                                            error:&publishError];
                }

                if (!publishError) {

                    NSDictionary *parameters = (!shouldStore ? @{@"store": @"0"} : nil);
                    NSMutableString *path = [NSMutableString stringWithFormat:@"/publish/%@/%@/0/%@"
                                                                               "/0",
                                             publishKey, subscribeKey,
                                             [PNString percentEscapedString:channel]];
                    if (!compressed) {

                        [path appendFormat:@"/%@", [PNString percentEscapedString:messageForPublish]];
                    }
                    PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                                       forOperation:PNPublishOperation
                                                     withCompletion:block];
                    if (compressed) {

                        NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];
                        NSData *compressedBody = [PNGZIP GZIPDeflatedData:messageData];
                        request.body = (compressedBody?: [@"" dataUsingEncoding:NSUTF8StringEncoding]);
                    }
                    request.parseBlock = ^id(id rawData){

                        __strong __typeof(self) strongSelfForProcessing = weakSelf;
                        return [strongSelfForProcessing processedPublishResponse:rawData];
                    };

                    [strongSelfForPreparation processRequest:request];
                }
                else {

                    PNRequest *failedRequest = [PNRequest requestWithPath:nil parameters:nil
                                                             forOperation:PNPublishOperation
                                                           withCompletion:block];
                    [strongSelfForPreparation handleRequestFailure:failedRequest withTask:nil
                                                          andError:publishError];
                }
            });
        });
    }
    else {
        
        NSString *description = @"Tried to send empty message";
        NSError *publishError = [NSError errorWithDomain:kPNPublishErrorDomain
                                                    code:kPNEmptyMessageError
                                                userInfo:@{NSLocalizedDescriptionKey:description}];
        PNRequest *failedRequest = [PNRequest requestWithPath:nil parameters:nil
                                                 forOperation:PNPublishOperation
                                               withCompletion:block];
        [self handleRequestFailure:failedRequest withTask:nil andError:publishError];
    }
}


#pragma mark - Processing

- (NSDictionary *)processedPublishResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;

    // Response in form of array arrive in two cases: publish successful and failed.
    // In case if no valid Foundation object has been passed it is possible what service returned
    // HTML and it should be treated as data publish error.
    if ([response isKindOfClass:[NSArray class]] || !response) {
        
        NSNumber *status = @(NO);
        NSString *information = @"Message Not Published";
        NSNumber *timeToken = nil;
        if ([(NSArray *)response count] == 3) {
            
            status = @([response[0] integerValue] == 1);
            information = response[1];
            timeToken = response[2];
        }
        else {
            
            timeToken = @(((NSUInteger)[[NSDate date] timeIntervalSince1970])*10000000);
        }
        
        processedResponse = @{@"status":status, @"information":information, @"tt": timeToken};
    }

    return processedResponse;
}


#pragma mark - Misc

- (id)mergedMessage:(id)message withMobilePushPayload:(NSDictionary *)payloads {
    
    id mergedMessage = (message ?: ([payloads count] ? @{} : nil));
    
    // Make composed message which is able to deliver notification using one of specified provider.
    if ([payloads count]) {
        
        // Convert passed message to mutable dictionary into which required by push notification
        // delivery service provider data will be added.
        mergedMessage = [([message isKindOfClass:[NSDictionary class]] ?
                         message : @{@"pn_other":message}) mutableCopy];
        
        for (NSString *pushProviderType in payloads) {
            
            [mergedMessage setValue:payloads[pushProviderType]
                                 forKey:[NSString stringWithFormat:@"pn_%@", pushProviderType]];
        }
    }
    
    return [mergedMessage copy];
}

- (NSString *)encryptedMessag:(NSString *)message withCipherKey:(NSString *)key
                        error:(NSError **)error {
    
    NSString *encryptedMessag = message;
    if ([key length]) {
        
        NSData *JSONData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSString *JSONString = [PNAES encrypt:JSONData withKey:key andError:error];
        if (*error == nil) {
            
            // \b PNAES encryption output is \a NSString which is valid JSON object from \b PubNub
            // service perspective, but it should be decorated with " (this done internally
            // by helper when it need to create JSON string).
            encryptedMessag = [PNJSON JSONStringFrom:JSONString withError:error];
        }
        else {
            
            encryptedMessag = nil;
        }
    }
    
    return encryptedMessag;
}

#pragma mark -


@end
