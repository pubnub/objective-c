#import "PNFilesAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c File \c download \c URL API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0 
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFileDownloadURLAPICallBuilder : PNFilesAPICallBuilder


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c File \c download \c URL generation completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNFileDownloadURLCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
