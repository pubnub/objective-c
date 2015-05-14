/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+APNS.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNStatus+Private.h"
#import "PNErrorCodes.h"
#import "PNResponse.h"
#import "PNHelpers.h"


#pragma mark Protected interface declaration

@interface PubNub (APNSProtected)


#pragma mark - Push notifications state manipulation 

/**
 @brief  Final designated method which allow to modify push notifications state on set of channels
         for device specified by \c pushToken.
 
 @param shouldEnabled Whether push notification should be enabled or disabled on \c channels.
 @param channels      List of channels for which notification state should be changed.
 @param pushToken     Reference on device push token for which on specified \c channels push
                      notifications will be enabled or disabled.
 @param block         Push notifications state modification on channels processing completion 
                      block which pass only one argument - request processing status to report about
                      how data pushing was successful or not.
 
 @since 4.0
 */
- (void)enablePushNotification:(BOOL)shouldEnabled onChannels:(NSArray *)channels
           withDevicePushToken:(NSData *)pushToken andCompletion:(PNStatusBlock)block;


#pragma mark - Handlers

/**
 @brief  Process push notifications modification request completion and notify observers about 
         results.

 @param request   Reference on base request which is used for communication with \b PubNub service.
                  Object also contains request processing results.
 @param pushToken Reference on device push token for which on specified \c channels push
                  notifications will be enabled or disabled.
 @param block     Push notifications addition on channels processing completion block which pass 
                  only one argument - request processing status to report about how data pushing
                  was successful or not.

 @since 4.0
 */
- (void)handlePushNotificationModificationRequest:(PNRequest *)request
                               forDevicePushToken:(NSData *)pushToken
                                    andCompletion:(PNStatusBlock)block;


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'APNS state
         modification' API.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'APNS state modification' API.
 
 @since 4.0
 */
- (NSDictionary *)processedPushNotificationsStateModificationResponse:(id)response;

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'APNS state
         audit' API.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'APNS state audit' API.
 
 @since 4.0
 */
- (NSDictionary *)processedPushNotificationsAuditResponse:(id)response;

#pragma mark - 


@end


#pragma mark - Interface implementation

@implementation PubNub (APNS)


#pragma mark - Push notifications state manipulation

- (void)addPushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                         andCompletion:(PNStatusBlock)block {
    
    [self enablePushNotification:YES onChannels:channels withDevicePushToken:pushToken
                   andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray *)channels
                        withDevicePushToken:(NSData *)pushToken
                              andCompletion:(PNStatusBlock)block {
    
    [self enablePushNotification:NO onChannels:channels withDevicePushToken:pushToken
                   andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                                            andCompletion:(PNStatusBlock)block {
    
    [self enablePushNotification:NO onChannels:nil withDevicePushToken:pushToken
                   andCompletion:block];
}

- (void)enablePushNotification:(BOOL)shouldEnabled onChannels:(NSArray *)channels
           withDevicePushToken:(NSData *)pushToken andCompletion:(PNStatusBlock)block {

    // Dispatching async on private serial queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        BOOL removeAllChannels = (!shouldEnabled && channels == nil);
        PNOperationType operationType = PNRemoveAllPushNotificationsOperation;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *channelsList = [PNChannel namesForRequest:channels];
        NSDictionary *parameters = nil;
        if (!removeAllChannels){
            
            operationType = (shouldEnabled ? PNAddPushNotificationsOnChannelsOperation :
                             PNRemovePushNotificationsFromChannelsOperation);
            parameters = @{(shouldEnabled ? @"add":@"remove"): channelsList};
        }
        NSString *format = [@"/v1/push/sub-key/%@/devices/%@"
                            stringByAppendingString:(removeAllChannels ? @"/remove" : @"")];
        NSString *path = [NSString stringWithFormat:format, subscribeKey,
                          [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]];
        __block __weak PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                                          forOperation:operationType
                                                        withCompletion:^{

            __strong __typeof(self) strongSelfForResponse = weakSelf;
            [strongSelfForResponse handlePushNotificationModificationRequest:request
                                                          forDevicePushToken:pushToken
                                                               andCompletion:[block copy]];
        }];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedPushNotificationsStateModificationResponse:rawData];
        };
        
        if (removeAllChannels) {
            
            DDLogAPICall(@"<PubNub> Disable push notifications for device '%@'.",
                         [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]);
        }
        else {
            
            DDLogAPICall(@"<PubNub> %@ push notifications for device '%@': %@.",
                         (shouldEnabled ? @"Enable" : @"Disable"),
                         [[PNData HEXFromDevicePushToken:pushToken] lowercaseString],
                         channelsList);
        }

        // Ensure what all required fields passed before starting processing.
        if ([pushToken length] > 0) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Empty device push token.";
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}


#pragma mark - Push notifications state audit

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                                andCompletion:(PNCompletionBlock)block {

    // Dispatching async on private serial queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *path = [NSString stringWithFormat:@"/v1/push/sub-key/%@/devices/%@", subscribeKey,
                          [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]];
        __block __weak PNRequest *request = [PNRequest requestWithPath:path parameters:nil
                                                          forOperation:PNPushNotificationEnabledChannelsOperation
                                                        withCompletion:nil];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedPushNotificationsAuditResponse:rawData];
        };
        request.reportBlock = block;
        
        DDLogAPICall(@"<PubNub> Push notification enabled channels for device '%@'.",
                     [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]);

        // Ensure what all required fields passed before starting processing.
        if ([pushToken length] > 0) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Empty device push token.";
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}


#pragma mark - Handlers

- (void)handlePushNotificationModificationRequest:(PNRequest *)request
                               forDevicePushToken:(NSData *)pushToken
                                    andCompletion:(PNStatusBlock)block {
    
    // Construct corresponding data objects which should be delivered through completion block.
    PNStatus *status = [PNStatus statusForRequest:request withError:request.response.error];
    [self callBlock:block status:YES withResult:nil andStatus:status];
}


#pragma mark - Processing

- (NSDictionary *)processedPushNotificationsStateModificationResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for device removal from APNS request.
    if ([response isKindOfClass:[NSArray class]] && [(NSArray *)response count] == 2) {
        
        processedResponse = @{@"status":@([response[0] integerValue] == 1),
                              @"information":response[1]};
    }
    
    return [processedResponse copy];
}

- (NSDictionary *)processedPushNotificationsAuditResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for device removal from APNS request.
    if ([response isKindOfClass:[NSArray class]]) {
        
        processedResponse = @{@"channels": response};
    }
    
    return [processedResponse copy];
}

#pragma mark -


@end
