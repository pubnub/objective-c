#import <PubNub/PNFilesAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

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
 * @discussion \c stream is in \a NSInputStream which can provide data for sending buffer.
 * @discussion \c size Size of data which can be read from \c stream.
 *
 * @note Only one type of input will be used: \b stream, \c data or \c path.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^stream)(NSInputStream *stream, NSUInteger size);

/**
 * @brief \c File \c message metadata..
 *
 * @discussion \b NSDictionary with values which should be used by \b PubNub service to filter
 * \c file \c messages.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^fileMessageMetadata)(NSDictionary *metadata);

/**
 * @brief Message maximum storage presence time.
 *
 * @discussion How long message should be stored in channel's storage. Pass \b 0 store message according to
 * retention.
 *
 * @note Will be ignored if \c fileMessageStore is set to \c NO.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^fileMessageTTL)(NSUInteger ttl);

/**
 * @brief Keep \c file \c message in \c channel history.
 *
 * @discussion Whether \b PubNub published \c file \c message should be stored in \c channel history.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^fileMessageStore)(BOOL store);

/**
 * @brief Key which is used to encrypt uploaded file so it will be protected both in motion and at rest.
 *
 * @discussion Data encryption key.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^cipherKey)(NSString *key);

/**
 * @brief Message which should be sent along with file to specified \c channel.
 *
 * @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If client has been
 * configured with cipher key message will be encrypted as well.
 *
 * @discussion Object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) which will be published.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^message)(id message);

/**
 * @brief In-memory binary data which should be uploaded and available in target channel.
 *
 * @discussion Binary data which should be uploaded.
 *
 * @note Only one type of input will be used: \b stream, \c data or \c path.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^data)(NSData *data);

/**
 * @brief URL to location of file for upload.
 *
 * @discussion URL on local file system.
 *
 * @note Only one type of input will be used: \b stream, \c data or \c url.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^url)(NSURL *url);



#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @discussion \c File \c send completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNSendFileCompletionBlock block);


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
