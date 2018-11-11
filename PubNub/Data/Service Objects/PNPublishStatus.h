#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which is used to provide access to additional data available to describe publish 
         status.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPublishData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Service-provided time stamp at which message has been pushed to remote data object live feed.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *timetoken;

/**
 @brief  Service-provide information about service response message.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSString *information;

#pragma mark -


@end


/**
 @brief  Class which is used to provide information about request processing.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPublishStatus : PNAcknowledgmentStatus


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on publish request processing status information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNPublishData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
