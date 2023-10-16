#import <PubNub/PNFilesAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Delete \c file API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0 
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDeleteFileAPICallBuilder : PNFilesAPICallBuilder


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c File \c download \c URL generation completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNDeleteFileCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
