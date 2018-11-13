#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service response on channel group and channel
             group channels manipulation request.
 @discussion Handle and pre-process provided server data to fetch operation status from it.
 @discussion Expected input:
 
 @code
{
  "error": @BOOL,
  "status": @BOOL,
  "information": NSString
}
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNChannelGroupModificationParser : NSObject <PNParser>


#pragma mark -


@end
