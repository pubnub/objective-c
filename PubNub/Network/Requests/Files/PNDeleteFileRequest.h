#import <PubNub/PNStructures.h>
#import <PubNub/PNRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Delete \c file request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDeleteFileRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c delete \c file request.
 *
 * @param channel Name of channel from which \c file with \c name should be \c deleted.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param name Name under which uploaded \c file is stored for \c channel.
 *
 * @return Configured and ready to use \c delete \c file request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel
                        identifier:(NSString *)identifier
                              name:(NSString *)name;

/**
 * @brief Forbids request initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized request.
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
