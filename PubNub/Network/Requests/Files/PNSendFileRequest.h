#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Class forward

@class PNSpaceId, PNMessageType;


#pragma mark - Interface declaration

/**
 * @brief \c Upload \c file request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSendFileRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/**
 * @brief \b NSDictionary with values which should be used by \b PubNub service to filter \c file \c messages.
 */
@property (nonatomic, nullable, strong) NSDictionary *fileMessageMetadata;

/**
 * @brief Key which should be used to encrypt uploaded data.
 *
 * @note Configured \b PubNub instance \c cipherKey will be used if this property not set.
 */
@property (nonatomic, nullable, copy) NSString *cipherKey;

/**
 * @brief How long message should be stored in channel's storage. Pass \b 0 store message according to retention.
 */
@property (nonatomic, assign) NSUInteger fileMessageTTL;

/**
 * @brief Name of channel to which \c data should be uploaded.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Identifier of the space to which message should be published.
 *
 * @since 5.2.0
 */
@property (nonatomic, nullable, strong) PNSpaceId *spaceId;

/**
 * @brief Whether \b PubNub published \c file \c message should be stored in \c channel history.
 */
@property (nonatomic, assign) BOOL fileMessageStore;

/**
 * @brief Message which should be sent along with file to specified \c channel.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 */
@property (nonatomic, nullable, strong) id message;

/**
 * @brief Custom type with which message should be published.
 *
 * @since 5.2.0
 */
@property (nonatomic, nullable, strong) PNMessageType *messageType;

/**
 * @brief Name which should be used to store uploaded data.
 */
@property (nonatomic, copy) NSString *filename;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c file \c upload request.
 *
 * @param channel Name of channel to which file at \c path should be uploaded.
 * @param url URL of file which should be uploaded (on file system).
 *
 * @return Configured and ready to use \c file \c upload request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel fileURL:(NSURL *)url;

/**
 * @brief Create and configure \c data \c upload request.
 *
 * @param channel Name of channel to which \c data should be uploaded.
 * @param name File name which will be used to store uploaded \c data.
 * @param data Binary data which should be uploaded.
 *
 * @return Configured and ready to use \c data \c upload request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                              data:(NSData *)data;

/**
 * @brief Create and configure \c upload from \c stream request.
 *
 * @param channel Name of channel to which \c data should be uploaded.
 * @param name File name which will be used to store uploaded \c data.
 * @param stream Stream to file on local file system or memory which should be uploaded.
 * @param size Size of data which can be read from \c stream.
 *
 * @return Configured and ready to use \c upload from \c stream request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel
                          fileName:(NSString *)name
                            stream:(NSInputStream *)stream
                              size:(NSUInteger)size;

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
