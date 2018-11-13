#import <Foundation/Foundation.h>
#import "PNTimeAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNErrorStatus, PNTimeResult;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'time' API group.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PubNub (Time)


#pragma mark - API builder support

/**
 * @brief Time API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNTimeAPICallBuilder * (^time)(void);


#pragma mark - Time token request

/**
 * @brief Request current time from \b PubNub service servers.
 *
 * @code
 * [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
 *     if (!status.isError) {
 *         // Handle downloaded server time token using: result.data.timetoken
 *     } else {
 *         // Handle time token download error. Check 'category' property to find out possible
 *         // issue because of which request did fail.
 *         //
 *         // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param block Time request completion block.
 *
 * @since 4.0
 */
- (void)timeWithCompletion:(PNTimeCompletionBlock)block NS_SWIFT_NAME(timeWithCompletion(_:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
