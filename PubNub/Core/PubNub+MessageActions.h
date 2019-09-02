#import "PubNub+Core.h"

#import "PNFetchMessageActionsRequest.h"
#import "PNRemoveMessageActionRequest.h"
#import "PNAddMessageActionRequest.h"

#import "PNFetchMessageActionsResult.h"
#import "PNAddMessageActionStatus.h"

#import "PNAddMessageActionAPICallBuilder.h"
#import "PNRemoveMessageActionAPICallBuilder.h"
#import "PNFetchMessagesActionsAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'Message Actions' API group.
 *
 * @discussion Set of API which allow to manage \c actions attached to particular \c message and
 * fetch previous changes.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PubNub (MessageActions)


#pragma mark - Message Actions API builder support

/**
 * @brief \c Add \c message \c action API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNAddMessageActionAPICallBuilder * (^addMessageAction)(void);

/**
 * @brief \c Remove \c message \c action API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNRemoveMessageActionAPICallBuilder * (^removeMessageAction)(void);

/**
 * @brief \c Fetch \c message \c actions API access builder block.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFetchMessagesActionsAPICallBuilder * (^fetchMessageActions)(void);


#pragma mark - Message actions

/**
 * @brief \c Add \c message \c action.
 *
 * @code
 * PNAddMessageActionRequest *request = [PNAddMessageActionRequest requestWithChannel:@"PubNub"
 *                                                                   messageTimetoken:@(1234567890)];
 * request.type = @"reaction";
 * request.value = @"smile";
 *
 * [self.client addMessageActionWithRequest:request completion:^(PNAddMessageActionStatus *status) {
 *     if (!status.isError) {
 *         // Message action successfully added.
 *         // Created message action information available here: status.data.action
 *     } else {
 *         if (status.statusCode == 207) {
 *             // Message action has been added, but event not published.
 *         } else {
 *             // Handle add message action error. Check 'category' property to find out possible
 *             // issue because of which request did fail.
 *             //
 *             // Request can be resent using: [status retry]
 *         }
 *     }
 * }];
 * @endcode
 *
 * @param request \c Add \c message \c action request with all information about new
 *     \c message \c action which will be passed to \b PubNub service.
 * @param block \c Add \c message \c action request completion block.
 */
- (void)addMessageActionWithRequest:(PNAddMessageActionRequest *)request
                         completion:(nullable PNAddMessageActionCompletionBlock)block;

/**
 * @brief \c Remove \c message \c action.
 *
 * @code
 * PNRemoveMessageActionRequest *request = [PNRemoveMessageActionRequest requestWithChannel:@"chat"
 *                                                                         messageTimetoken:@(1234567890)];
 * request.actionTimetoken = @(1234567891);
 *
 * [self.client removeMessageActionWithRequest:request
 *                                  completion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message action successfully removed.
 *     } else {
 *         // Handle remove message action error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Remove \c message \c action request with information about existing
 *     \c message \c action.
 * @param block \c Remove \c message \c action request completion block.
 */
- (void)removeMessageActionWithRequest:(PNRemoveMessageActionRequest *)request
                            completion:(nullable PNRemoveMessageActionCompletionBlock)block;

/**
 * @brief \c Fetch \c message \c actions.
 *
 * @code
 * PNFetchMessageActionsRequest *request = [PNFetchMessageActionsRequest requestWithChannel:@"chat"];
 * request.start = @(1234567891);
 * request.limit = 200;
 *
 * [self.client fetchMessageActionsWithRequest:request
 *                                  completion:^(PNFetchMessageActionsResult *result,
                                                 PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *         // Message actions successfully fetched.
 *         // Result object has following information:
 *         //     result.data.actions - list of message action instances
 *         //     result.data.start - fetched messages actions time range start (oldest message
 *         //         action timetoken).
 *         //     result.data.end - fetched messages actions time range end (newest action timetoken).
 *     } else {
 *         // Handle fetch message actions error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry]
 *     }
 * }];
 * @endcode
 *
 * @param request \c Fetch \c message \c actions request with all information which should be used
 *     to fetch existing \c message \c actions.
 * @param block \c Fetch \c message \c actions request completion block.
 */
- (void)fetchMessageActionsWithRequest:(PNFetchMessageActionsRequest *)request
                            completion:(PNFetchMessageActionsCompletionBlock)block;

#pragma mark -



@end

NS_ASSUME_NONNULL_END
