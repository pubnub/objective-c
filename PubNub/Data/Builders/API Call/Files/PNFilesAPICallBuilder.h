#import <PubNub/PNAPICallBuilder.h>
#import <PubNub/PNStructures.h>


#pragma mark Class forward

@class PNFileDownloadURLAPICallBuilder, PNDownloadFileAPICallBuilder, PNDeleteFileAPICallBuilder;
@class PNListFilesAPICallBuilder, PNSendFileAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief \c Files API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFilesAPICallBuilder : PNAPICallBuilder


#pragma mark - Send file

/**
 * @brief \c Upload \c file API access builder block.
 *
 * @param channel Name of channel to which \c file should be uploaded.
 * @param name Name under which \c file should be stored and available for future download.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNSendFileAPICallBuilder * (^sendFile)(NSString *channel,
                                                                               NSString *name);


#pragma mark - List files

/**
 * @brief \c List uploaded \c files API access builder block.
 *
 * @param channel Name of channel for which all uploaded \c files should be listed.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNListFilesAPICallBuilder * (^listFiles)(NSString *channel);


#pragma mark - Download file

/**
 * @brief \c File download URL API access builder block.
 *
 * @param channel Name of channel within which \c file with \c name has been uploaded.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param name Name under which uploaded \c file is stored for \c channel.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNFileDownloadURLAPICallBuilder * (^fileURL)(NSString *channel,
                                                                                     NSString *identifier,
                                                                                     NSString *name);

/**
 * @brief \c Download \c file API access builder block.
 *
 * @param channel Name of channel within which \c file with \c name has been uploaded.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param name Name under which uploaded \c file is stored for \c channel.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDownloadFileAPICallBuilder * (^downloadFile)(NSString *channel,
                                                                                       NSString *identifier,
                                                                                       NSString *name);


#pragma mark - Delete file

/**
 * @brief \c Delete \c file API access builder block.
 *
 * @param channel Name of channel within which \c file with \c name should be deleted.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param name Name under which uploaded \c file is stored for \c channel.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDeleteFileAPICallBuilder * (^deleteFile)(NSString *channel,
                                                                                   NSString *identifier,
                                                                                   NSString *name);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
