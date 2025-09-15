#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNFetchMessageActionsRequest.h>
#import <PubNub/PNRemoveMessageActionRequest.h>
#import <PubNub/PNAddMessageActionRequest.h>

// Response
#import <PubNub/PNFetchMessageActionsResult.h>
#import <PubNub/PNAddMessageActionStatus.h>
#import <PubNub/PNMessageActionFetchData.h>

// Deprecated
#import <PubNub/PNFetchMessagesActionsAPICallBuilder.h>
#import <PubNub/PNRemoveMessageActionAPICallBuilder.h>
#import <PubNub/PNAddMessageActionAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Message Reaction` APIs.
///
/// Set of API which allow managing reactions attached to particular message and fetch previous changes.
@interface PubNub (MessageActions)


#pragma mark - Message Actions API builder interface (deprecated)

/// `Add message action` API access builder block.
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^addMessageAction)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// `Remove message action` API access builder block.
@property (nonatomic, readonly, strong) PNRemoveMessageActionAPICallBuilder * (^removeMessageAction)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// `Fetch message actions` API access builder block.
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^fetchMessageActions)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Message actions

/// Add an action on a published `message`.
///
/// #### Example:
/// ```objc
/// PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"PubNub"
///                                                                   messageTimetoken:@(1234567890)];
/// request.type = @"reaction";
/// request.value = @"smile";
///
/// [self.client addMessageActionWithRequest:request completion:^(PNAddMessageActionStatus *status) {
///     if (!status.isError) {
///         // Message action successfully added.
///         // Created message action information available here: `status.data.action`
///     } else {
///         if (status.statusCode == 207) {
///             // Message action has been added, but event not published.
///         } else {
///             // Handle add message action error. Check `category` property to find out possible issue because of
///             // which request did fail.
///         }
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Add message action` request with all information about new `message action` which will be passed to
///   **PubNub** service.
///   - block: `Add message action` request completion `block`.
- (void)addMessageActionWithRequest:(PNAddMessageActionRequest *)request
                         completion:(nullable PNAddMessageActionCompletionBlock)block;

/// Remove a previously added action on a published `message`.
///
/// #### Example:
/// ```objc
/// PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@"chat"
///                                                                         messageTimetoken:@(1234567890)];
/// request.actionTimetoken = @(1234567891);
///
/// [self.client removeMessageActionWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Message action successfully removed.
///     } else {
///         // Handle remove message action error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Remove message action` request with information about existing `message action`.
///   - block: `Remove message action` request completion block.
- (void)removeMessageActionWithRequest:(PNRemoveMessageActionRequest *)request
                            completion:(nullable PNRemoveMessageActionCompletionBlock)block;

/// `Fetch message actions`.
///
/// #### Example:
/// ```objc
/// PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"chat"];
/// request.start = @(1234567891);
/// request.limit = 200;
///
/// [self.client fetchMessageActionsWithRequest:request
///                                  completion:^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Message actions successfully fetched.
///         // Result object has following information:
///         //     `result.data.actions` - list of message action instances
///         //     `result.data.start` - fetched messages actions time range start (oldest message action timetoken).
///         //     `result.data.end` - fetched messages actions time range end (newest action timetoken).
///     } else {
///         // Handle fetch message actions error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: `Fetch message actions` request with all information which should be used to fetch existing
///   `message actions`.
///   - block: `Fetch message actions` request completion block.
- (void)fetchMessageActionsWithRequest:(PNFetchMessageActionsRequest *)request
                            completion:(PNFetchMessageActionsCompletionBlock)block;

#pragma mark -



@end

NS_ASSUME_NONNULL_END
