#import "PNFilesAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Class forward

@class PNSpaceId, PNMessageType;


#pragma mark - Interface declaration

/**
 * @brief \c Send \c file API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0 
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSendFileAPICallBuilder : PNFilesAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Stream from which data will be use for upload body.
 *
 * @discussion This approach allow to lower pressure on memory and load only required portion of
 * data which can be sent at this moment.
 *
 * @note Only one type of input will be used: \b stream, \c data or \c path.
 *
 * @param stream \a NSInputStream which can provide data for sending buffer.
 * @param size Size of data which can be read from \c stream.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^stream)(NSInputStream *stream, NSUInteger size);

/**
 * @brief \c File \c message metadata..
 *
 * @param fileMessageMetadata \b NSDictionary with values which should be used by \b PubNub service to filter
 * \c file \c messages.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^fileMessageMetadata)(NSDictionary *metadata);

/**
 * @brief Message maximum storage presence time.
 *
 * @note Will be ignored if \c fileMessageStore is set to \c NO.
 *
 * @param fileMessageTTL How long message should be stored in channel's storage. Pass \b 0 store message according to
 * retention.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^fileMessageTTL)(NSUInteger ttl);

/**
 * @brief Keep \c file \c message in \c channel history.
 *
 * @param fileMessageStore Whether \b PubNub published \c file \c message should be stored in \c channel history.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^fileMessageStore)(BOOL store);

/**
 * @brief Key which is used to encrypt uploaded file so it will be protected both in motion and at rest.
 *
 * @param cipherKey Data encryption key.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^cipherKey)(NSString *key);

/**
 * @brief Target space identifier name.
 *
 * @param spaceId Identifier of the space to which message should be published.
 *
 * @return API call configuration builder.
 *
 * @version 5.2.0
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^spaceId)(PNSpaceId *spaceId);

/**
 * @brief Message which should be sent along with file to specified \c channel.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @param message Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^message)(id message);

/**
 * @brief Type of message which will be published.
 *
 * @param type User-provided type for published message.
 *
 * @return API call configuration builder.
 *
 * @version 5.2.0
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^type)(NSString *type);

/**
 * @brief In-memory binary data which should be uploaded and available in target channel.
 *
 * @note Only one type of input will be used: \b stream, \c data or \c path.
 *
 * @param data Binary data which should be uploaded.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^data)(NSData *data);

/**
 * @brief URL to location of file for upload.
 *
 * @note Only one type of input will be used: \b stream, \c data or \c url.
 *
 * @param url URL on local file system.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^url)(NSURL *url);



#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c File \c send completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSendFileCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^queryParam)(NSDictionary *params);


#pragma mark -


@end

NS_ASSUME_NONNULL_END
