#import "PNBasePublishRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Publish \c file \c message request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPublishFileMessageRequest : PNBasePublishRequest


#pragma mark - Information

/**
 * @brief Unique identifier provided during file upload.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief Name with which uploaded data has been stored.
 */
@property (nonatomic, readonly, copy) NSString *filename;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c file \c message \c publish  request.
 *
 * @param channel Name of channel to which \c file \c message should be published.
 * @param identifier Unique identifier provided during file upload.
 * @param filename Name with which uploaded data has been stored.
 *
 * @return Configured and ready to use \c publish \c message request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel
                    fileIdentifier:(NSString *)identifier
                              name:(NSString *)filename;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
