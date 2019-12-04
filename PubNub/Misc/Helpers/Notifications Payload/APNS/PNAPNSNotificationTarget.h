#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief APNS notification target .
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
@interface PNAPNSNotificationTarget : NSObject


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure default notification configuration.
 *
 * @discussion Default configuration will be created for single target in \b PNAPNSDevelopment
 * environment and \b NSBundle.mainBundle.bundleIdentifier as topic name.
 *
 * @return Configured and ready to use notification target.
 */
+ (instancetype)defaultTarget;

/**
 * @brief Create and configure notification target for \b PNAPNSDevelopment environment.
 *
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 *     Value will be used in APNs POST request as \a apns-topic header value.
 *
 * @return Configured and ready to use notification target.
 */
+ (instancetype)targetForTopic:(NSString *)topic;

/**
 * @brief Create and configure notification target.
 *
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 *     Value will be used in APNs POST request as \a apns-topic header value. 
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *     registered devices to which notifications should be delivered.
 * @param excludedDevices List of devices (their push tokens) to which this notification shouldn't
 *     be delivered.
 *
 * @return Configured and ready to use notification target.
 */
+ (instancetype)targetForTopic:(NSString *)topic
                 inEnvironment:(PNAPNSEnvironment)environment
           withExcludedDevices:(nullable NSArray<NSData *> *)excludedDevices;

@end

NS_ASSUME_NONNULL_END
