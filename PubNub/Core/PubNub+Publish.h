#import <PubNub/PubNub+Core.h>

#import <PubNub/PNPublishFileMessageRequest.h>
#import <PubNub/PNPublishRequest.h>

#import <PubNub/PNPublishFileMessageAPICallBuilder.h>
#import <PubNub/PNPublishSizeAPICallBuilder.h>
#import <PubNub/PNPublishAPICallBuilder.h>
#import <PubNub/PNSignalAPICallBuilder.h>


#pragma mark Class forward

@class PNPublishStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'publish' API group.
 *
 * @discussion Set of API which allow to push data to \b PubNub service. Data pushed to remote data
 * objects called 'channels' and then delivered on their live feeds to all subscribers.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PubNub (Publish)


#pragma mark - API builder support

/**
 * @brief Publish File Message API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.15.0
 */
@property (nonatomic, readonly, strong) PNPublishFileMessageAPICallBuilder * (^publishFileMessage)(void);

/**
 * @brief Publish API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^publish)(void);

/**
 * @brief Publish API access builder.
 *
 * @note Builder is pre-configured to send messages which won't be stored in \c Storage and won't be replicated.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishAPICallBuilder * (^fire)(void);

/**
 * @brief Signal API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.9.0
 */
@property (nonatomic, readonly, strong) PNSignalAPICallBuilder * (^signal)(void);

/**
 * @brief Publish message size calculation builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^size)(void);


#pragma mark - Files message

/**
 * @brief Publish \c file \c message to specified \c channel.
 *
 * @code
 * PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:@"channel"
 *                                                                         fileIdentifier:@"fileIdentifier"
 *                                                                                   name:@"fileName"];
 *
 * [self.client publishFileMessageWithRequest:request completion:^(PNPublishStatus *status) {
 *     if (!status.isError) {
 *         // File message successfully published.
 *     } else {
 *         // Handle file message publish error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param request \c File \c message \c publish request with all information about uploaded file.
 * @param block \c File \c message \c publish request completion block.
 *
 * @since 4.15.0
 */
- (void)publishFileMessageWithRequest:(PNPublishFileMessageRequest *)request
                           completion:(nullable PNPublishCompletionBlock)block;


#pragma mark - Publish with request

/**
 * @brief \c Publish provided Foundation object to \b PubNub service.
 *
 * @code
 * PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"announcement"];
 * request.metadata = @{ @"to": @"John Doe" };
 * request.message = @{ @"Hello": @"world" };
 *
 * [self.client publishWithRequest:request completion:^(PNPublishStatus *status) {
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param request \c Publish \c message request with all information required to deliver message.
 * @param block \c Publish \c message request completion block.
 *
 * @since 4.15.0
 */
- (void)publishWithRequest:(PNPublishRequest *)request
                completion:(nullable PNPublishCompletionBlock)block;


#pragma mark - Plain message publish

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *       withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param block Publish completion block.
 */
- (void)publish:(id)message
         toChannel:(NSString *)channel
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *         withMetadata:@{ @"to": @"John Doe" } completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter
 *     messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(id)message
       toChannel:(NSString *)channel
    withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
      completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:withMetadata:completion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement" compressed:NO
 *       withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param compressed Whether message should be compressed before sending or not.
 * @param block Publish completion block.
 */
- (void)publish:(id)message
         toChannel:(NSString *)channel
        compressed:(BOOL)compressed
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:compressed:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement" compressed:NO
 *         withMetadata:@{ @"to": @"John Doe" } completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param compressed Whether message should be compressed before sending or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(id)message
       toChannel:(NSString *)channel
      compressed:(BOOL)compressed
    withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
      completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:compressed:withMetadata:completion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement" storeInHistory:NO
 *       withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param block Publish completion block.
 */
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement" storeInHistory:NO
 *         withMetadata:@{ @"to": @"John Doe" } completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
      withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
        completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:withMetadata:completion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement" storeInHistory:NO
 *           compressed:YES withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param compressed Whether message should be compressed before sending or not.
 * @param block Publish completion block.
 */
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
        compressed:(BOOL)compressed
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:compressed:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement" storeInHistory:NO
 *           compressed:YES withMetadata:@{@"to":@"John Doe"}
 *           completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param compressed Whether message should be compressed before sending or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
        compressed:(BOOL)compressed
      withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
        completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:compressed:withMetadata:completion:));


#pragma mark - Composite message publish

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
 *       withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param block Publish completion block.
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
 *         withMetadata:@{ @"to": @"John Doe" } completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:withMetadata:completion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } } compressed:YES
 *       withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param compressed Whether message should be compressed before sending or not.
 * @param block Publish completion block.
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
           compressed:(BOOL)compressed
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:compressed:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } } compressed:YES
 *         withMetadata:@{ @"to": @"John Doe" } completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param compressed Whether message should be compressed before sending or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
           compressed:(BOOL)compressed
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:compressed:withMetadata:completion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } } storeInHistory:YES
 *       withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param block Publish completion block.
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } } storeInHistory:YES
 *         withMetadata:@{ @"to": @"John Doe" } completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:withMetadata:completion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } } storeInHistory:YES
 *           compressed:NO withCompletion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param compressed Whether message should be compressed before sending or not.
 * @param block Publish completion block.
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
           compressed:(BOOL)compressed
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:compressed:withCompletion:));

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
 *    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } } storeInHistory:YES
 *           compressed:NO withMetadata:@{ @"to": @"John Doe" }
 *           completion:^(PNPublishStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message successfully published to specified channel.
 *     } else {
 *         // Handle message publish error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 * @param channel Name of the channel to which message should be published.
 * @param payloads \b NSDictionary with payloads for different push notification services (Apple with "apns" key and Google
 *   with "gcm").
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param compressed Whether message should be compressed before sending or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Publish completion block.
 *
 * @since 4.3.0
 */
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
           compressed:(BOOL)compressed
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:compressed:withMetadata:completion:));



#pragma mark - Signal

/**
 * @brief Send provided Foundation object to \b PubNub service.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @code
 * [self.client signal:@{ @"Hello": @"world" } channel:@"announcement"
 *      withCompletion:^(PNSignalStatus *status) {
 *
 *     if (!status.isError) {
 *         // Signal successfully sent to specified channel.
 *     } else {
 *         // Handle signal sending error. Check 'category' property to find out possible issue
 *         // because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be sent with signal.
 * @param channel Name of the channel to which signal should be sent.
 * @param block Signal completion block.
 *
 * @since 4.9.0
 */
- (void)signal:(id)message
           channel:(NSString *)channel
    withCompletion:(nullable PNSignalCompletionBlock)block
    NS_SWIFT_NAME(signal(_:channel:withCompletion:));


#pragma mark - Message helper

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement"
 *             withCompletion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param block Message size calculation completion block.
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:withCompletion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement"
 *               withMetadata:@{ @"to": @"John Doe" } completion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Message size calculation completion block.
 *
 * @since 4.3.0
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:withMetadata:completion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" compressed:YES
 *             withCompletion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param compressMessage Whether message should be compressed before sending or not.
 * @param block Message size calculation completion block.
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:withCompletion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" compressed:YES
 *               withMetadata:@{ @"to": @"John Doe" } completion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param compressMessage Whether message should be compressed before sending or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Message size calculation completion block.
 *
 * @since 4.3.0
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:withMetadata:completion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" storeInHistory:NO
 *             withCompletion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param block Message size calculation completion block.
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:storeInHistory:withCompletion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" storeInHistory:NO
 *               withMetadata:@{ @"to": @"John Doe" } completion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Message size calculation completion block.
 *
 * @since 4.3.0
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:storeInHistory:withMetadata:completion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" compressed:NO
 *             storeInHistory:NO withCompletion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param compressMessage Whether message should be compressed before sending or not.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param block Message size calculation completion block.
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:storeInHistory:withCompletion:));

/**
 * @brief Helper method which allow to calculate resulting message before it will be sent to \b PubNub network.
 *
 * @note Size calculation use percent-escaped \c message and all added headers to get full size.
 *
 * @code
 * [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" compressed:NO
 *             storeInHistory:NO withMetadata:@{ @"to": @"John Doe" } completion:^(NSInteger size) {
 *
 *     // Actual message size is: size
 * }];
 * @endcode
 *
 * @param message Message for which size should be calculated.
 * @param channel Name of the channel to which message should be published.
 * @param compressMessage Whether message should be compressed before sending or not.
 * @param shouldStore Whether message should be stored and available with history API or not.
 * @param metadata \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 * @param block Message size calculation completion block.
 *
 * @since 4.3.0
 */
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:storeInHistory:withMetadata:completion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
