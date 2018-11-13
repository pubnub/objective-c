#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to APNS enabled channels processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNAPNSEnabledChannelsData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Channels with active push notifications.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *channels;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNAPNSEnabledChannelsResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on APNS enabled channels audit request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNAPNSEnabledChannelsData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
