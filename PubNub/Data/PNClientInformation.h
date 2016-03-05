#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b PubNub client information wrapper.
 @discussion This instance provide base information about \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0.5
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNClientInformation : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores current client version number.
 
 @since 4.0.5
 */
@property (nonatomic, readonly) NSString *version;

/**
 @brief  Stores git SHA for commit on which current version is based.
 
 @since 4.0.5
 */
@property (nonatomic, readonly) NSString *commit;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
