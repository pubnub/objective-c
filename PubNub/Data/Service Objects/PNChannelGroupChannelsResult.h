#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to channel group's channels list audit processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNChannelGroupChannelsData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Registered channels within channel group.
 @note   In case if status object represent error, this property may contain list of channels to which client 
         doesn't have access.
 
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
@interface PNChannelGroupChannelsResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on channel group's channels list audit request processing information.
 
 @since 4.0
 */
@property (nonatomic, nonnull, readonly, strong) PNChannelGroupChannelsData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
