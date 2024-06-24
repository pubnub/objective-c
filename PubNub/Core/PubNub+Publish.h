#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNPublishFileMessageRequest.h>
#import <PubNub/PNPublishRequest.h>
#import <PubNub/PNSignalRequest.h>

// Response
#import <PubNub/PNPublishStatus.h>
#import <PubNub/PNSignalStatus.h>

// Deprecated
#import <PubNub/PNPublishFileMessageAPICallBuilder.h>
#import <PubNub/PNPublishSizeAPICallBuilder.h>
#import <PubNub/PNPublishAPICallBuilder.h>
#import <PubNub/PNSignalAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Publish` APIs.
///
/// Set of API which allow pushing data to PubNub service.
@interface PubNub (Publish)


#pragma mark - Publish API builder interdace (deprecated)

/// Publish File Message API access builder.
@property(strong, nonatomic, readonly) PNPublishFileMessageAPICallBuilder * (^publishFileMessage)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// Publish API access builder.
@property(strong, nonatomic, readonly) PNPublishAPICallBuilder * (^publish)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// Publish API access builder.
///
/// Pre-configured to send messages which won't be stored in `Storage` and won't be replicated.
@property(strong, nonatomic, readonly) PNPublishAPICallBuilder * (^fire)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// Signal API access builder.
@property(strong, nonatomic, readonly) PNSignalAPICallBuilder * (^signal)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// Publish message size calculation builder.
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder * (^size)(void)
DEPRECATED_MSG_ATTRIBUTE("This builder-based interface deprecated. Completion block always will be called with '0' "
                         "size.");


#pragma mark - Files message

/// Publish `file message` to specified `channel`.
///
/// #### Example:
/// ```objc
/// PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:@"channel"
///                                                                         fileIdentifier:@"fileIdentifier"
///                                                                                   name:@"fileName"];
///
/// [self.client publishFileMessageWithRequest:request completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // File message successfully published. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle file message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to publish shared file payload.
///   - block: Shared file payload publish request completion block.
- (void)publishFileMessageWithRequest:(PNPublishFileMessageRequest *)request
                           completion:(nullable PNPublishCompletionBlock)block;


#pragma mark - Publish with request

/// Publish provided object to the **PubNub** service.
///
/// #### Example:
/// ```objc
/// PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"announcement"];
/// request.metadata = @{ @"to": @"John Doe" };
/// request.message = @{ @"Hello": @"world" };
///
/// [self.client publishWithRequest:request completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to publish provided data.
///   - block: Data publish request completion block.
- (void)publishWithRequest:(PNPublishRequest *)request completion:(nullable PNPublishCompletionBlock)block;


#pragma mark - Plain message publish

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - block: Publish completion block.
///
- (void)publish:(id)message
         toChannel:(NSString *)channel
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///         withMetadata:@{ @"to": @"John Doe" }
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(id)message
       toChannel:(NSString *)channel
    withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
      completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///           compressed:NO
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - compressed: Whether message should be compressed before sending or not.
///   - block: Publish completion block.
- (void)publish:(id)message
         toChannel:(NSString *)channel
        compressed:(BOOL)compressed
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:compressed:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///           compressed:NO
///         withMetadata:@{ @"to": @"John Doe" }
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - compressed: Whether message should be compressed before sending or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(id)message
       toChannel:(NSString *)channel
      compressed:(BOOL)compressed
    withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
      completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:compressed:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///       storeInHistory:NO
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - block: Publish completion block.
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///       storeInHistory:NO
///         withMetadata:@{ @"to": @"John Doe" } 
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
      withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
        completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } toChannel:@"announcement"
///       storeInHistory:NO
///           compressed:YES
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - compressed: Whether message should be compressed before sending or not.
///   - block: Publish completion block.
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
        compressed:(BOOL)compressed
    withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:compressed:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement" storeInHistory:NO
///           compressed:YES
///         withMetadata:@{@"to":@"John Doe"}
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - compressed: Whether message should be compressed before sending or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(id)message
         toChannel:(NSString *)channel
    storeInHistory:(BOOL)shouldStore
        compressed:(BOOL)compressed
      withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
        completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:storeInHistory:compressed:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");


#pragma mark - Composite message publish

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and 
///   Google with "gcm").
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///         withMetadata:@{ @"to": @"John Doe" } 
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and
///   Google with "gcm").
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///           compressed:YES
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and
///   Google with "gcm").
///   - compressed: Whether message should be compressed before sending or not.
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
           compressed:(BOOL)compressed
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:compressed:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///           compressed:YES
///         withMetadata:@{ @"to": @"John Doe" }
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and
///   Google with "gcm").
///   - compressed: Whether message should be compressed before sending or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
           compressed:(BOOL)compressed
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:compressed:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///       storeInHistory:YES
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and 
///   Google with "gcm").
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///       storeInHistory:YES
///         withMetadata:@{ @"to": @"John Doe" }
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and
///   Google with "gcm").
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///       storeInHistory:YES
///           compressed:NO
///       withCompletion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads: `NSDictionary` with payloads for different push notification services (Apple with "apns" key and
///   Google with "gcm").
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - compressed: Whether message should be compressed before sending or not.
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
           compressed:(BOOL)compressed
       withCompletion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:compressed:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client publish:@{ @"Hello": @"world" } 
///            toChannel:@"announcement"
///    mobilePushPayload:@{ @"apns": @{ @"alert": @"Hello from PubNub" } }
///       storeInHistory:YES
///           compressed:NO
///         withMetadata:@{ @"to": @"John Doe" }
///           completion:^(PNPublishStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be published.
///   - channel: Name of the channel to which message should be published.
///   - payloads:`NSDictionary` with payloads for different push notification services (Apple with "apns" key and Google
///   with "gcm").
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - compressed: Whether message should be compressed before sending or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Publish completion block.
- (void)publish:(nullable id)message
            toChannel:(NSString *)channel
    mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads
       storeInHistory:(BOOL)shouldStore
           compressed:(BOOL)compressed
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(nullable PNPublishCompletionBlock)block
    NS_SWIFT_NAME(publish(_:toChannel:mobilePushPayload:storeInHistory:compressed:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-publishWithRequest:completion:' method instead.");



#pragma mark - Signal

/// Send signal with provided object to the **PubNub** service.
///
/// #### Example:
/// ```objc
/// PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"announcement" signal:@{ @"status": @"online" }];
///
/// [self.client sendSignalWithRequest:request completion:^(PNSignalStatus *status) {
///     if (!status.isError) {
///         // Message successfully published to specified channel. Signal time stored in: `result.data.timetoken`.
///     } else {
///         // Handle message publish error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to send signal with procided data.
///   - block: Signal data send request completion block.
- (void)sendSignalWithRequest:(PNSignalRequest *)request completion:(nullable PNSignalCompletionBlock)block;

/// Send provided Foundation object to **PubNub** service.
///
/// Provided object will be serialized into JSON string before pushing to **PubNub** service. If client has been
/// configured with cipher key message will be encrypted as well.
///
/// #### Example:
/// ```objc
/// [self.client signal:@{ @"Hello": @"world" }
///             channel:@"announcement"
///      withCompletion:^(PNSignalStatus *status) {
///     if (!status.isError) {
///         // Signal successfully sent to specified channel. Publish time stored in: `result.data.timetoken`.
///     } else {
///         // Handle signal sending error. Check `category` property to find out possible issue because of which 
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - message: Object (`NSString`, `NSNumber`, `NSArray`, `NSDictionary`) which will be sent with signal.
///   - channel: Name of the channel to which signal should be sent.
///   - block: Signal completion block.
- (void)signal:(id)message
           channel:(NSString *)channel
    withCompletion:(nullable PNSignalCompletionBlock)block
    NS_SWIFT_NAME(signal(_:channel:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-sendSignalWithRequest:completion:' method instead.");


#pragma mark - Message helper

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" } toChannel:@"announcement" withCompletion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" } 
///                  toChannel:@"announcement"
///               withMetadata:@{ @"to": @"John Doe" }
///                 completion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - metadata:`NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" } 
///                  toChannel:@"announcement" 
///                 compressed:YES
///             withCompletion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - compressMessage: Whether message should be compressed before sending or not.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" } 
///                  toChannel:@"announcement" compressed:YES
///               withMetadata:@{ @"to": @"John Doe" }
///                 completion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - compressMessage: Whether message should be compressed before sending or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" } 
///                  toChannel:@"announcement"
///             storeInHistory:NO
///             withCompletion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:storeInHistory:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" } 
///                  toChannel:@"announcement"
///             storeInHistory:NO
///               withMetadata:@{ @"to": @"John Doe" }
///                 completion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
       storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata 
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:storeInHistory:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" }
///                  toChannel:@"announcement"
///                 compressed:NO
///             storeInHistory:NO
///             withCompletion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - compressMessage: Whether message should be compressed before sending or not.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:storeInHistory:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

/// Helper method which allow to calculate resulting message before it will be sent to **PubNub** network.
///
/// Size calculation use percent-escaped `message` and all added headers to get full size.
///
/// #### Example:
/// ```objc
/// [self.client sizeOfMessage:@{ @"Hello": @"world" }
///                  toChannel:@"announcement" 
///                 compressed:NO
///             storeInHistory:NO
///               withMetadata:@{ @"to": @"John Doe" }
///                 completion:^(NSInteger size) {
///     // Actual message size is: size
/// }];
/// ```
///
/// - Parameters:
///   - message: Message for which size should be calculated.
///   - channel: Name of the channel to which message should be published.
///   - compressMessage: Whether message should be compressed before sending or not.
///   - shouldStore: Whether message should be stored and available with history API or not.
///   - metadata: `NSDictionary` with values which should be used by **PubNub** service to filter messages.
///   - block: Message size calculation completion block.
- (void)sizeOfMessage:(id)message
            toChannel:(NSString *)channel
           compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore
         withMetadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block
    NS_SWIFT_NAME(sizeOfMessage(_:toChannel:compressed:storeInHistory:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Completion block"
                             " always will be called with '0' size.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
