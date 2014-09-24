#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNResponse, PNError;


/**
 This class used as factory and used to provide response parser basing on data stored inside \b PNResponse.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNResponseParser : NSObject


#pragma mark - Class methods

/**
 * Returns reference on parser which completed it's job and
 * can provide data for response
 */
/**
 This method allow to find suitable parser for concrete data.

 @param response
 \b PNResponse instance which is used to determine correct parses.

 @return Initialized and ready to used parser which is suitable for concrete response.
 */
+ (PNResponseParser *)parserForResponse:(PNResponse *)response;


#pragma mark - Instance methods

/**
 Template methods which is used by subclasses to provide parsed data.

 @return Parsed data object.
 */
- (id)parsedData;

#pragma mark -


@end
