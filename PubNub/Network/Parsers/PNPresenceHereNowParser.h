#import <Foundation/Foundation.h>
#import "PNParser.h"


/**
 @brief      Class suitable to handle and process \b PubNub service response on here now global and here now 
             channel request.
 @discussion Handle and pre-process provided server data to fetch operation result from it.
 @discussion Expected input for channel group and global here now with client identifier only:
 
 @code
{
  "total_channels": NSNumber,
  "total_occupancy": NSNumber,
  "channels": {
    NSString: {
      "occupancy": NSNumber,
      "uuids": [
        NSString,
        ...
      ]
    },
    ...
  }
}
 @endcode
 @discussion Expected input for channel group and global here now with client state information:
 
 @code
{
  "total_channels": NSNumber,
  "total_occupancy": NSNumber,
  "channels": {
    NSString: {
      "occupancy": NSNumber,
      "uuids": [
        NSString: {
          "uuid": NSString,
          "state": NSDictionary
        },
        ...
      ]
    },
    ...
  }
}
 @endcode
 @discussion Expected input for channel here now with client identifier only:
 
 @code
{
  "occupancy": NSNumber,
  "uuids": [
    NSString,
    ...
  ]
}
 @endcode
 @discussion Expected input for channel here now with client state information:
 
 @code
{
  "occupancy": NSNumber,
  "uuids": [
    NSString: {
      "uuid": NSString,
      "state": NSDictionary
    },
    ...
  ]
}
 @endcode
 @discussion Expected input for occupancy only:
 
 @code
{
  "occupancy": NSNumber
}
 @endcode
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPresenceHereNowParser : NSObject <PNParser>


#pragma mark -


@end
