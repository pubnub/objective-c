/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+Messaging.h"
#import "NSObject+PNAdditions.h"
#import "PNMessage+Protected.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNCryptoHelper.h"
#import "PubNub+Cipher.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"
#import "PNMessagePostRequest.h"
#import "PNStructures.h"
#import "PNChannel.h"


#pragma mark - Category private interface declaration

@interface PubNub (MessagingPrivate)


#pragma mark - Instance methods

/**
 @brief Extension of -sendMessage:toChannel:compressed:storeInHistory:withCompletionBlock: and allow
        specify whether handler block should be replaced or not.

 @param message               Object which should be sent to \b PubNub cloud
 @param channel               \b PNChannel instance into which message should be sent.
 @param shouldCompressMessage \c YES in case if message should be compressed before sending to the
                              PubNub service.
 @param shouldStoreInHistory  \c YES in case if message should be stored on \b PubNub service side
                              and become available with History API.
 @param callbackToken         Reference on callback token under which stored block passed by user on
                              API usage. This block will be reused because of method rescheduling.
 @param success               Handler block which is called by \b PubNub client when message sending
                              process state changes. Block pass two arguments: \c state - one of
                              \b PNMessageState fields which represent current message sending
                              process stage; \c data - depending on current state, there can be
                              stored \b PNMessage instance which represent message payload or
                              \b PNError instance which hold information about why message sending
                              process failed. Always check \a error.code to find out what caused
                              error (check PNErrorCodes header file and use \a -localizedDescription
                              / \a -localizedFailureReason and \a -localizedRecoverySuggestion to
                              get human readable description for error).
 */
- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
          alreadyEncrypted:(BOOL)alreadyEncrypted compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory
  rescheduledCallbackToken:(NSString *)callbackToken
       withCompletionBlock:(PNClientMessageProcessingBlock)success;

/**
 @brief Postpone message sending user request so it will be executed in future.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param message               Object which should be sent to \b PubNub cloud
 @param channel               \b PNChannel instance into which message should be sent.
 @param shouldCompressMessage \c YES in case if message should be compressed before sending to the
                              PubNub service.
 @param shouldStoreInHistory  \c YES in case if message should be stored on \b PubNub service side
                              and become available with History API.
 @param callbackToken         Reference on callback token under which stored block passed by user on
                              API usage. This block will be reused because of method rescheduling.
 @param success               Handler block which is called by \b PubNub client when message sending
                              process state changes. Block pass two arguments: \c state - one of
                              \b PNMessageState fields which represent current message sending
                              process stage; \c data - depending on current state, there can be
                              stored \b PNMessage instance which represent message payload or
                              \b PNError instance which hold information about why message sending
                              process failed. Always check \a error.code to find out what caused
                              error (check PNErrorCodes header file and use \a -localizedDescription
                              / \a -localizedFailureReason and \a -localizedRecoverySuggestion to
                              get human readable description for error).
 */
- (void)postponeSendMessage:(id)message toChannel:(PNChannel *)channel
           alreadyEncrypted:(BOOL)alreadyEncrypted compressed:(BOOL)shouldCompressMessage
             storeInHistory:(BOOL)shouldStoreInHistory
   rescheduledCallbackToken:(NSString *)callbackToken
        withCompletionBlock:(PNClientMessageProcessingBlock)success;


#pragma mark - Misc methods

/**
 @brief This method will notify delegate about that message sending failed because of error
 
 @note  Always check \a error.code to find out what caused error (check PNErrorCodes header file and
        use \a -localizedDescription / \a -localizedFailureReason and
        \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error         Instance of \b PNError which describes what exactly happened and why this
                      error occurred.
 @param callbackToken Reference on callback token under which stored block passed by user on API
                      usage. This block will be reused because of method rescheduling.
 */
- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error
                                        andCallbackToken:(NSString *)callbackToken;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (Messaging)


#pragma mark - Class (singleton) methods

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message toChannel:channel withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel storeInHistory:YES
         withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message toChannel:channel storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel compressed:NO
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
              storeInHistory:YES withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:NO storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
              storeInHistory:YES withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:NO storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel storeInHistory:YES
         withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel compressed:NO
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage
              storeInHistory:YES withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [[self sharedInstance] sendMessage:message toChannel:channel
                                   compressed:shouldCompressMessage
                               storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:shouldCompressMessage withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:YES withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload googleCloudNotification:nil
                   toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:YES withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:nil googleCloudNotification:gcmPayload
                   toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel compressed:shouldCompressMessage
         withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:YES withCompletionBlock:success];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [[self sharedInstance] sendMessage:message applePushNotification:apnsPayload
                      googleCloudNotification:gcmPayload toChannel:channel
                                   compressed:shouldCompressMessage
                               storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

+ (void)sendMessage:(PNMessage *)message {
    
    [self sendMessage:message withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message.message storeInHistory:YES withCompletionBlock:success];
}

+ (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory {
    
    [self sendMessage:message.message storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory
withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message.message compressed:NO storeInHistory:shouldStoreInHistory
  withCompletionBlock:success];
}

+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage {
    
    [self sendMessage:message.message compressed:shouldCompressMessage withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage
withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message compressed:shouldCompressMessage storeInHistory:YES
  withCompletionBlock:success];
}

+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage
     storeInHistory:(BOOL)shouldStoreInHistory {
    
    [self sendMessage:message compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
  withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage
     storeInHistory:(BOOL)shouldStoreInHistory
withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message.message toChannel:message.channel compressed:shouldCompressMessage
       storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}


#pragma mark - Instance methods

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message toChannel:channel withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel storeInHistory:YES
         withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message toChannel:channel storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel compressed:NO
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
              storeInHistory:YES withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:NO storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
              storeInHistory:YES withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:NO storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel storeInHistory:YES
         withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel compressed:NO
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage
              storeInHistory:YES withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {

    return [self sendMessage:message toChannel:channel alreadyEncrypted:NO
                  compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
    rescheduledCallbackToken:nil withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel
          alreadyEncrypted:(BOOL)alreadyEncrypted compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory
  rescheduledCallbackToken:(NSString *)callbackToken
       withCompletionBlock:(PNClientMessageProcessingBlock)success {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.api.messageSendAttempt, (message ? message : [NSNull null]),
                 (channel ? channel : [NSNull null]), @(shouldCompressMessage),
                 @(shouldStoreInHistory), [self humanReadableStateFrom:self.state]];
    }];

    __block PNError *error = nil;
    PNMessage *messageObject = [PNMessage messageWithObject:message forChannel:channel
                                                 compressed:shouldCompressMessage
                                             storeInHistory:shouldStoreInHistory error:&error];

    [self   performAsyncLockingBlock:^{

        if (self.cryptoHelper.ready) {

            // Try apply message encoding if required and possible
            id messageForSending = message;
            BOOL encrypted = NO;

            if (!alreadyEncrypted) {

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
                if ([messageForSending isKindOfClass:[NSNumber class]]) {

                    messageForSending = [(NSNumber *) message stringValue];
                }
#endif

                PNError *encryptionError;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
                messageForSending = [PNJSONSerialization stringFromJSONObject:messageForSending];
#endif
                messageForSending = [self AESEncrypt:messageForSending error:&encryptionError];

                if (encryptionError != nil) {

                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray * {

                        return @[PNLoggerSymbols.requests.messagePost.messageBodyEncryptionError,
                                (encryptionError ? encryptionError : [NSNull null])];
                    }];
                    messageForSending = message;
                    error = encryptionError;
                }
                encrypted = (encryptionError == nil);
                if (encrypted) {

                    messageObject.encryptedMessage = messageForSending;
                }
            }
            else {

                encrypted = alreadyEncrypted;
            }
            messageObject.contentEncrypted = encrypted;
        }
        // Even w/o encryption message should be translated to string for further processinf with
        // PubNub API.
        else {

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            messageObject.encryptedMessage = [PNJSONSerialization stringFromJSONObject:message];
#endif
        }

        // Check whether client is able to send request or not
        NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
        if (statusCode == 0 && error == nil) {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.sendingMessage,
                        [self humanReadableStateFrom:self.state]];
            }];

            PNMessagePostRequest *request = [PNMessagePostRequest postMessageRequestWithMessage:messageObject];
            if (success && !callbackToken) {

                [self.observationCenter addClientAsMessageProcessingObserverWithToken:request.shortIdentifier
                                                                             andBlock:success];
            }
            else if (callbackToken) {

                [self.observationCenter changeClientCallbackToken:callbackToken
                                                               to:request.shortIdentifier];
            }

            [self sendRequest:request shouldObserveProcessing:YES];
        }
            // Looks like client can't send request because of some reasons
        else {

            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

                return @[PNLoggerSymbols.api.messageSendImpossible,
                        [self humanReadableStateFrom:self.state]];
            }];

            PNError *sendingError = (error ? error : [PNError errorWithCode:statusCode]);
            sendingError.associatedObject = messageObject;

            [self notifyDelegateAboutMessageSendingFailedWithError:sendingError
                                                  andCallbackToken:callbackToken];


            if (success && !callbackToken) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    success(PNMessageSendingError, sendingError);
                });
            }
        }
    }        postponedExecutionBlock:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.postponeMessageSending,
                    [self humanReadableStateFrom:self.state]];
        }];

        [self postponeSendMessage:message toChannel:channel alreadyEncrypted:alreadyEncrypted
                       compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
         rescheduledCallbackToken:callbackToken withCompletionBlock:success];
    } burstExecutionLockingOperation:NO];


    return messageObject;
}

- (void)postponeSendMessage:(id)message toChannel:(PNChannel *)channel
           alreadyEncrypted:(BOOL)alreadyEncrypted compressed:(BOOL)shouldCompressMessage
             storeInHistory:(BOOL)shouldStoreInHistory
   rescheduledCallbackToken:(NSString *)callbackToken
        withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    id successCopy = (success ? [success copy] : nil);
    [self postponeSelector:@selector(sendMessage:toChannel:alreadyEncrypted:compressed:storeInHistory:rescheduledCallbackToken:withCompletionBlock:)
                 forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:message],
                             [PNHelper nilifyIfNotSet:channel], @(alreadyEncrypted),
                             @(shouldCompressMessage), @(shouldStoreInHistory),
                             [PNHelper nilifyIfNotSet:callbackToken],
                             [PNHelper nilifyIfNotSet:successCopy]]
                outOfOrder:(callbackToken != nil) burstExecutionLock:NO];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:shouldCompressMessage withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:YES withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload googleCloudNotification:nil
                   toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:YES withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message googleCloudNotification:gcmPayload toChannel:channel
                  compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
         withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message googleCloudNotification:(NSDictionary *)gcmPayload
                 toChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
            storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:nil googleCloudNotification:gcmPayload
                   toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel compressed:shouldCompressMessage withCompletionBlock:nil];
}


- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel compressed:shouldCompressMessage
              storeInHistory:YES withCompletionBlock:success];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory {
    
    return [self sendMessage:message applePushNotification:apnsPayload
     googleCloudNotification:gcmPayload toChannel:channel compressed:shouldCompressMessage
              storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

- (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload
   googleCloudNotification:(NSDictionary *)gcmPayload toChannel:(PNChannel *)channel
                compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    PNMessage *messageObject = nil;
    NSMutableDictionary *messageForSending = (!message ? [NSMutableDictionary dictionary] : nil);
    if (message) {
        
        if ([message isKindOfClass:[NSDictionary class]]) {
            
            // Checking whether user already provided valid APNS payload or not (for backward compatibiliy)
            if ([(NSDictionary *)message valueForKey:@"aps"]) {
                
                // Recompose APNS payload to use newer JSON format.
                messageForSending = [NSMutableDictionary dictionaryWithDictionary:@{@"pn_apns":message}];
            }
            else if (apnsPayload || gcmPayload) {
                
                // Looks like user provided dictionary with data into which we will be able to put notification payloads
                // if required.
                messageForSending = [(NSDictionary *)message mutableCopy];
            }
            else {
                
                // Looks like there is no push notification data which can be used.
                messageObject = [self sendMessage:message toChannel:channel
                                       compressed:shouldCompressMessage
                                   storeInHistory:shouldStoreInHistory
                              withCompletionBlock:success];
            }
        }
        else if (apnsPayload || gcmPayload) {
            
            messageForSending = [NSMutableDictionary dictionaryWithDictionary:@{@"pn_other":message}];
        }
        else {
            
            // Looks like there is no push notification data which can be used.
            messageObject = [self sendMessage:message toChannel:channel
                                   compressed:shouldCompressMessage
                               storeInHistory:shouldStoreInHistory
                          withCompletionBlock:success];
        }
    }
    
    if (apnsPayload) {
        
        [messageForSending setValue:apnsPayload forKeyPath:@"pn_apns"];
    }
    
    if (gcmPayload) {
        
        [messageForSending setValue:gcmPayload forKeyPath:@"pn_gcm"];
    }
    
    
    return (messageObject ? messageObject :
            [self sendMessage:messageForSending toChannel:channel compressed:shouldCompressMessage
               storeInHistory:shouldStoreInHistory withCompletionBlock:success]);
}

- (void)sendMessage:(PNMessage *)message {
    
    [self sendMessage:message withCompletionBlock:nil];
}

- (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message storeInHistory:YES withCompletionBlock:success];
}

- (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory {
    
    [self sendMessage:message storeInHistory:shouldStoreInHistory withCompletionBlock:nil];
}

- (void)sendMessage:(PNMessage *)message storeInHistory:(BOOL)shouldStoreInHistory
withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message compressed:NO storeInHistory:shouldStoreInHistory
  withCompletionBlock:success];
}

- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage {
    
    [self sendMessage:message compressed:shouldCompressMessage withCompletionBlock:nil];
}

- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage
withCompletionBlock:(PNClientMessageProcessingBlock)success {
    
    [self sendMessage:message compressed:shouldCompressMessage storeInHistory:YES
  withCompletionBlock:success];
}

- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage
     storeInHistory:(BOOL)shouldStoreInHistory {
    
    [self sendMessage:message compressed:shouldCompressMessage storeInHistory:shouldStoreInHistory
  withCompletionBlock:nil];
}

- (void)sendMessage:(PNMessage *)message compressed:(BOOL)shouldCompressMessage
     storeInHistory:(BOOL)shouldStoreInHistory
withCompletionBlock:(PNClientMessageProcessingBlock)success {

    [self sendMessage:message.message toChannel:message.channel
     alreadyEncrypted:message.isContentEncrypted compressed:shouldCompressMessage
       storeInHistory:shouldStoreInHistory rescheduledCallbackToken:nil
  withCompletionBlock:success];
}


#pragma mark - Misc methods

- (void)sizeOfMessage:(id)message toChannel:(PNChannel *)channel
  withCompletionBlock:(void (^)(NSUInteger size))calculationCompletionBlock {

    [self sizeOfMessage:message toChannel:channel compressed:NO
    withCompletionBlock:calculationCompletionBlock];
}

- (void)sizeOfMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)compressedMessage
  withCompletionBlock:(void (^)(NSUInteger size))calculationCompletionBlock {

    [self sizeOfMessage:message toChannel:channel compressed:compressedMessage storeInHistory:YES
    withCompletionBlock:calculationCompletionBlock];
}

- (void)sizeOfMessage:(id)message toChannel:(PNChannel *)channel
       storeInHistory:(BOOL)shouldStoreInHistory
  withCompletionBlock:(void (^)(NSUInteger size))calculationCompletionBlock {

    [self sizeOfMessage:message toChannel:channel compressed:NO storeInHistory:shouldStoreInHistory
    withCompletionBlock:calculationCompletionBlock];
}

- (void)sizeOfMessage:(id)message toChannel:(PNChannel *)channel compressed:(BOOL)compressedMessage
       storeInHistory:(BOOL)shouldStoreInHistory
  withCompletionBlock:(void (^)(NSUInteger size))calculationCompletionBlock {

    [self pn_dispatchBlock:^{

        NSUInteger sizeOfMessage = 0;
        if (self.clientConfiguration) {

            __block PNError *error = nil;
            PNMessage *messageObject = [PNMessage messageWithObject:message forChannel:channel
                                                         compressed:compressedMessage
                                                     storeInHistory:shouldStoreInHistory error:&error];

            if (self.cryptoHelper.ready) {

                // Try apply message encoding if required and possible
                id messageForSending = message;
                if ([messageForSending isKindOfClass:[NSNumber class]]) {

                    messageForSending = [(NSNumber *) message stringValue];
                }

                PNError *encryptionError;
                messageForSending = [PNJSONSerialization stringFromJSONObject:messageForSending];
                messageForSending = [self AESEncrypt:messageForSending error:&encryptionError];

                if (encryptionError != nil) {

                    [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray * {

                        return @[PNLoggerSymbols.requests.messagePost.messageBodyEncryptionError,
                                (encryptionError ? encryptionError : [NSNull null])];
                    }];
                    messageForSending = message;
                    error = encryptionError;
                }
                if (encryptionError == nil) {

                    messageObject.encryptedMessage = messageForSending;
                }
            }
                // Even w/o encryption message should be translated to string for further processinf with
                // PubNub API.
            else {

                messageObject.encryptedMessage = [PNJSONSerialization stringFromJSONObject:message];
            }

            if (error == nil) {

                PNMessagePostRequest *request = [PNMessagePostRequest postMessageRequestWithMessage:messageObject];
                [request finalizeWithConfiguration:self.clientConfiguration
                                  clientIdentifier:self.uniqueClientIdentifier];
                sizeOfMessage = [[request HTTPPayload] length];
            }
        }

        if (calculationCompletionBlock) {

            dispatch_async(dispatch_get_main_queue(), ^{

                calculationCompletionBlock(sizeOfMessage);
            });
        }
    }];
}

- (void)notifyDelegateAboutMessageSendingFailedWithError:(PNError *)error
                                        andCallbackToken:(NSString *)callbackToken {
    
    [self handleLockingOperationBlockCompletion:^{

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {

            return @[PNLoggerSymbols.api.messageSendingFailed,
                    [self humanReadableStateFrom:self.state]];
        }];

        // Check whether delegate is able to handle message sending error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didFailMessageSend:withError:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.clientDelegate pubnubClient:self didFailMessageSend:error.associatedObject
                                        withError:error];
            });
        }

        [self sendNotification:kPNClientMessageSendingDidFailNotification withObject:error
              andCallbackToken:callbackToken];
    }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
}


#pragma mark - Service channel delegate methods


- (void)serviceChannel:(PNServiceChannel *)channel willSendMessage:(PNMessage *)message
             onRequest:(PNBaseRequest *)request {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.api.willSendMessage,
                 (message.message ? message.message : [NSNull null]),
                 (message.channel ? message.channel : [NSNull null]),
                 [self humanReadableStateFrom:self.state]];
    }];

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        if (shouldNotify) {

            // Check whether delegate can handle message sending event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:willSendMessage:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:willSendMessage:)
                                              withObject:self withObject:message];
                });
            }

            [self sendNotification:kPNClientWillSendMessageNotification withObject:message
                  andCallbackToken:request.shortIdentifier];
        }
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel didSendMessage:(PNMessage *)message
             onRequest:(PNBaseRequest *)request {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didSendMessage,
                     [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // Check whether delegate can handle message sent event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate performSelector:@selector(pubnubClient:didSendMessage:)
                                              withObject:self withObject:message];
                });
            }

            [self sendNotification:kPNClientDidSendMessageNotification withObject:message
                  andCallbackToken:request.shortIdentifier];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }                           shouldStartNext:YES burstExecutionLockingOperation:NO];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)channel didFailMessageSend:(PNMessage *)message
             withError:(PNError *)error forRequest:(PNBaseRequest *)request {

    NSString *callbackToken = request.shortIdentifier;
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:message];
        [self notifyDelegateAboutMessageSendingFailedWithError:error
                                              andCallbackToken:callbackToken];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleMessageSending,
                         [self humanReadableStateFrom:self.state]];
            }];

            [self sendMessage:message.message toChannel:message.channel
             alreadyEncrypted:message.isContentEncrypted
                   compressed:message.shouldCompressMessage
               storeInHistory:message.shouldStoreInHistory rescheduledCallbackToken:callbackToken
          withCompletionBlock:nil];
        }];
    }
}

#pragma mark -


@end
