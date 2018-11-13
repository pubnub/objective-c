#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to channel history processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNHistoryData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief      Channel history messages.
 @discussion \b Important: for \c PNHistoryForChannelsOperation operation this property always will be 
             \c empty array.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSArray *messages;

/**
 @brief      Channels history.
 @discussion Each key represent name of channel for which messages has been received and valus is list of 
             messages from channel's storage.
 @discussion \b Important: for  \c PNHistoryOperation operation this property always will be \c empty 
             dictionary.
 
 @since 4.5.6
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSArray *> *channels;

/**
 @brief      History time frame start time.
 @discussion \b Important: for \c PNHistoryForChannelsOperation operation this property always will be \b 0.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *start;

/**
 @brief      History time frame end time.
 @discussion \b Important: for \c PNHistoryForChannelsOperation operation this property always will be \b 0.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *end;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNHistoryResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on channel history request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNHistoryData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
