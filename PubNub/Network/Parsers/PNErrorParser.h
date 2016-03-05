#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service error response for one of
             operation requests.
 @discussion Handle and pre-process provided server data to fetch time token from it.
 @discussion Expected input:
 
 @code
{
  "tt": NSNumber
}
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNErrorParser : NSObject <PNParser>


#pragma mark -


@end
