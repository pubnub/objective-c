#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service response on push notifications state 
             manipulation request.
 @discussion Handle and pre-process provided server data to fetch operation status from it.
 @discussion Expected input:
 
 @code
{
  "status": @BOOL,
  "information": NSString
}
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPushNotificationsStateModificationParser : NSObject <PNParser>


#pragma mark -


@end
