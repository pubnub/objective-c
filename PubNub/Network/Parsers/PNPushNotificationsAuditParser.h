#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 * @brief Class suitable to handle and process \b PubNub service response on push notification
 * enabled channgels list audit request.
 *
 * @discussion Handle and pre-process provided server data to fetch operation result from it.
 * @discussion Expected input:
 *
 * @code
 * {
 *   "channels": [
 *     NSString,
 *     ...
 *   ]
 * }
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNPushNotificationsAuditParser : NSObject <PNParser>


#pragma mark - 


@end
