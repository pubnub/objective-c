/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNWhereNowResponseParser+Protected.h"
#import "PNResponse+Protected.h"
#import "PNWhereNow+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub where now response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public interface implementation

@implementation PNWhereNowResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSDictionary *responseData = response.response;

        NSArray *channels = @[];
        if ([[responseData objectForKey:kPNResponseChannelsKey] count]) {

            channels = [PNChannel channelsWithNames:[responseData objectForKey:kPNResponseChannelsKey]];
        }
        self.whereNow = [PNWhereNow whereNowForClientIdentifier:response.additionalData andChannels:channels];
    }


    return self;
}

- (id)parsedData {

    return self.whereNow;
}

#pragma mark -


@end
