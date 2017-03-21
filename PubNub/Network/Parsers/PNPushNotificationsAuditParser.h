#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service response on push notification enabled 
             channgels list audit request.
 @discussion Handle and pre-process provided server data to fetch operation result from it.
 @discussion Expected input:
 
 @code
{
  "channels": [
    NSString,
    ...
  ]
}
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPushNotificationsAuditParser : NSObject <PNParser>


#pragma mark - 


@end
