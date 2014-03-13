<<<<<<< HEAD
=======
//
//  PNChannel.h
//  pubnub
//
//  This class allow to parse response from server
//  into logical units:
//      - update time token
//      - channels on which event occurred in pair with event
//
//
//  Created by moonlight on 1/1/13.
//
//


#import <Foundation/Foundation.h>


>>>>>>> fix-pt65153600
#pragma mark Class forward

@class PNResponse, PNError;


<<<<<<< HEAD
/**
 This class used as factory and used to provide response parser basing on data stored inside \b PNResponse.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
=======
>>>>>>> fix-pt65153600
@interface PNResponseParser : NSObject


#pragma mark - Class methods

/**
 * Returns reference on parser which completed it's job and
 * can provide data for response
 */
<<<<<<< HEAD
/**
 This method allow to find suitable parser for concrete data.

 @param response
 \b PNResponse instance which is used to determine correct parses.

 @return Initialized and ready to used parser which is suitable for concrete response.
 */
=======
>>>>>>> fix-pt65153600
+ (PNResponseParser *)parserForResponse:(PNResponse *)response;


#pragma mark - Instance methods

/**
<<<<<<< HEAD
 Template methods which is used by subclasses to provide parsed data.

 @return Parsed data object.
 */
- (id)parsedData;

#pragma mark -


=======
 * Returns reference on parsed data
 * (template method, actual implementation is in
 * subclasses)
 */
- (id)parsedData;

>>>>>>> fix-pt65153600
@end
