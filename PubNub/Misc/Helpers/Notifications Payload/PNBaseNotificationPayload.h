#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base platform specific notification payload builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
@interface PNBaseNotificationPayload : NSObject


#pragma mark - Information

/**
 * @brief Platform specific notification payload.
 *
 * @discussion In addition to data required to make notification visual presentation it can be used
 * to pass additional information which should be sent to remote device.
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *payload;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
