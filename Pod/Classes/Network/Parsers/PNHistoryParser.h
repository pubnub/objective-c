#import <Foundation/Foundation.h>
#import "PNParser.h"

/**
 @brief      Class suitable to handle and process \b PubNub service response on channel history
             request.
 @discussion Handle and pre-process provided server data to fetch operation result from it.
 
 @code
 @endcode
 Expected output:
 
 @code
 {
  "status": @BOOL,
  "state": NSDictionary
 }
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNHistoryParser : NSObject <PNParser>


#pragma mark -


@end
