#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service response on message publish request.
 @discussion Handle and pre-process provided server data to fetch operation result from it.
 @discussion Expected input:
 
 @code
{
  "status": @BOOL,
  "information": NSString,
  "timetoken": NSNumber
}
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNMessagePublishParser : NSObject <PNParser>


#pragma mark -


@end
