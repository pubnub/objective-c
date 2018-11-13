#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service response on channels for group and channel
             groups list audit request.
 @discussion Handle and pre-process provided server data to fetch operation result from it.
 @discussion Expected input for channel groups list audit:
 
 @code
{
  "channel-groups": [
    NSString,
    ...
  ]
}
 @endcode
 @discussion Expected input for group channels list audit:
 
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
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNChannelGroupAuditionParser : NSObject <PNParser>


#pragma mark - 


@end
