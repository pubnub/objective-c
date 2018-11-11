#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to client presence processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPresenceWhereNowData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  List of channels on which client subscribed.
 
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
@interface PNPresenceWhereNowResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on client presence request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNPresenceWhereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
