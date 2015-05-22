/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Publish.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNStatus+Private.h"
#import "PNErrorCodes.h"
#import "PNResponse.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Private interface declaration

@interface PubNub (PublishPrivate)


#pragma mark - Handlers

/**
 @brief  Process message publish request completion and notify observers about results.

 @param request Reference on base request which is used for communication with \b PubNub service.
                Object also contains request processing results.
 @param block   State audition for user on cahnnel processing completion block which pass only one 
                argument - request processing status to report about how data pushing was successful 
                or not.

 @since 4.0
 */
- (void)handlePublishRequest:(PNRequest *)request withCompletion:(PNStatusBlock)block;


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
- (NSDictionary *)mergedMessage:(NSString *)message withMobilePushPayload:(NSDictionary *)payloads;

/**
 @brief  Try perform encryption of data which should be pushed to \b PubNub services.
 
 @param message Referebce on data which \b PNAES should try to encrypt.
 @param key     Reference on cipher key which should be used during encryption.
 @param error   Reference on pointer into which data encryption error will be passed.
 
 @return Encrypted Base64-encoded string or original message, if there is no \c key has been passed.
         \c nil will be returned in case if encrytption failed.
 
 @since 4.0
 */
- (NSString *)encryptedMessage:(NSString *)message withCipherKey:(NSString *)key
                         error:(NSError **)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (Publish)


#pragma mark - Plain message publish

- (void)publish:(id)message toChannel:(NSString *)channel withCompletion:(PNStatusBlock)block {

    [self publish:message toChannel:channel compressed:NO withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
 withCompletion:(PNStatusBlock)block {

    [self publish:message toChannel:channel storeInHistory:YES compressed:compressed
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
 withCompletion:(PNStatusBlock)block {

    [self publish:message toChannel:channel storeInHistory:shouldStore compressed:NO
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(PNStatusBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:nil storeInHistory:shouldStore
       compressed:compressed withCompletion:block];
}


#pragma mark - Composited message publish

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads withCompletion:(PNStatusBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads compressed:NO
   withCompletion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel mobilePushPayload:(NSDictionary *)payloads
     compressed:(BOOL)compressed withCompletion:(PNStatusBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:YES
       compressed:compressed withCompletion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(PNStatusBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore
       compressed:NO withCompletion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(PNStatusBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{

        __strong __typeof(self) strongSelf = weakSelf;
        NSString *publishKey = [PNString percentEscapedString:strongSelf.publishKey];
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *cipherKey = [strongSelf.cipherKey copy];

        // Push further code execution on secondary queue to make service queue responsive during
        // JSON serialization and encryption process.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            __strong __typeof(self) strongSelfForPreparation = weakSelf;
            NSError *publishError = nil;
            NSString *messageForPublish = [PNJSON JSONStringFrom:message withError:&publishError];

            // Encrypt message in case if serialization to JSON was successful.
            if (!publishError) {

                // Try perform user message encryption.
                messageForPublish = [strongSelfForPreparation encryptedMessage:messageForPublish
                                                                 withCipherKey:cipherKey
                                                                         error:&publishError];
            }

            // Merge user message with push notification payloads (if provided).
            if (!publishError && [payloads count]) {

                NSDictionary *mergedData = [self mergedMessage:messageForPublish
                                         withMobilePushPayload:payloads];
                messageForPublish = [PNJSON JSONStringFrom:mergedData withError:&publishError];
            }

            NSDictionary *parameters = (!shouldStore ? @{@"store": @"0"} : nil);
            NSMutableString *path = [NSMutableString stringWithFormat:@"/publish/%@/%@/0/%@/0",
                                     publishKey, subscribeKey,
                                     [PNString percentEscapedString:channel]];
            if (!compressed) {

                [path appendFormat:@"/%@", [PNString percentEscapedString:messageForPublish]];
            }
            PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                               forOperation:PNPublishOperation
                                             withCompletion:^(PNRequest *completedRequest) {

                __strong __typeof(self) strongSelfForResponse = weakSelf;
                [strongSelfForResponse handlePublishRequest:completedRequest
                                             withCompletion:[block copy]];
            }];
            if (compressed) {

                NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];
                NSData *compressedBody = [PNGZIP GZIPDeflatedData:messageData];
                request.body = (compressedBody?: [@"" dataUsingEncoding:NSUTF8StringEncoding]);
            }
            request.parseBlock = ^id(id rawData){

                __strong __typeof(self) strongSelfForProcessing = weakSelf;
                return [strongSelfForProcessing processedPublishResponse:rawData];
            };
            
            DDLogAPICall(@"<PubNub> Publish%@ message to '%@' channel%@%@",
                         (compressed ? @" compressed" : @""), (channel?: @"<error>"),
                         (!shouldStore ? @" which won't be saved in hisotry" : @""),
                         (!compressed ? [NSString stringWithFormat:@": %@",
                                         (messageForPublish?: @"<error>")] : @"."));

            // Ensure what all required fields passed before starting processing.
            if (!publishError && [channel length] && ((!compressed && [messageForPublish length]) ||
                (compressed && [request.body length]))) {

                [strongSelfForPreparation processRequest:request];
            }
            // Notify about incomplete parameters set.
            else {

                NSString *description = @"Channel not specified.";
                if (!compressed && [messageForPublish length]) {

                    description = @"Empty message.";
                }
                else if  (compressed && [request.body length]) {

                    description = @"Message compression failed.";
                }
                NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                     code:kPNAPIUnacceptableParameters
                                                 userInfo:@{NSLocalizedDescriptionKey:description}];
                [strongSelfForPreparation handleRequestFailure:request
                                                     withError:(publishError?: error)];
            }
        });
    });
}


#pragma mark - Handlers

- (void)handlePublishRequest:(PNRequest *)request withCompletion:(PNCompletionBlock)block {
    
    // Construct corresponding data objects which should be delivered through completion block.
    PNStatus *status = [PNStatus statusForRequest:request withError:request.response.error];
    [self callBlock:block status:YES withResult:nil andStatus:status];
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
            
            timeToken = @((unsigned long long)([[NSDate date] timeIntervalSince1970]*10000000));
        }
        
        processedResponse = @{@"status":status, @"information":information, @"tt": timeToken};
    }

    return processedResponse;
}


#pragma mark - Misc

- (NSDictionary *)mergedMessage:(NSString *)message withMobilePushPayload:(NSDictionary *)payloads {

    // Convert passed message to mutable dictionary into which required by push notification
    // delivery service provider data will be added.
    NSMutableDictionary *mergedMessage = [@{@"pn_other":message} mutableCopy];

    for (NSString *pushProviderType in payloads) {

        id payload = payloads[pushProviderType];
        if ([pushProviderType isEqualToString:@"apns"] && payload[@"aps"] == nil) {

            payload = @{@"aps":payload};
        }
        NSString *provideKey = [NSString stringWithFormat:@"pn_%@", pushProviderType];
        [mergedMessage setValue:payload forKey:provideKey];
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
