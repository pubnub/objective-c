#import <PubNub/PNRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c List \c files request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNListFilesRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/**
 * @brief Name of channel for which list of files should be fetched.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Previously-returned cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, copy) NSString *next;

/**
 * @brief Number of files to return in response.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 */
@property (nonatomic, assign) NSUInteger limit;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c list \c files request.
 *
 * @param channel Name of channel for which files list should be retrieved.
 *
 * @return Configured and ready to use \c list \c files request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
