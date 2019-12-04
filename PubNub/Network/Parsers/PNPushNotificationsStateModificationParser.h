#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 * @brief Class suitable to handle and process \b PubNub service response on push notifications
 * state manipulation request.
 *
 * @discussion Handle and pre-process provided server data to fetch operation status from it.
 * @discussion Expected input:
 *
 * @code
 * {
 *   "status": @BOOL,
 *   "information": NSString
 * }
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNPushNotificationsStateModificationParser : NSObject <PNParser>


#pragma mark -


@end
