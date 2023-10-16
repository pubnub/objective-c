#import <PubNub/PNFilesAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c List \c files API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0 
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNListFilesAPICallBuilder : PNFilesAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Maximum number of files metadata per fetched page.
 *
 * @discussion Number of files metadata to return in response.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNListFilesAPICallBuilder * (^limit)(NSUInteger limit);

/**
 * @brief Cursor value to navigate to next fetched result page.
 *
 * @discussion Previously-returned cursor bookmark for fetching the next page.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNListFilesAPICallBuilder * (^next)(NSString *next);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @discussion \c List \c files completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNListFilesCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @discussion List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
