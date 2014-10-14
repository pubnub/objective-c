/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClientStateResponseParser+Protected.h"
#import "PNResponse+Protected.h"
#import "PNClient+Protected.h"
#import "PNChannel.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub client state request response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public interface implementation

@implementation PNClientStateResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];
    conforms = (conforms ? (response.additionalData && [response.additionalData isKindOfClass:[PNClient class]]) : conforms);
    if (conforms && [response.response objectForKey:kPNResponseChannelsKey]) {
        
        conforms = [[response.response valueForKey:kPNResponseChannelsKey] isKindOfClass:[NSDictionary class]];
    }


    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        PNClient *client = response.additionalData;
        NSDictionary *responseData = response.response;
        if ([responseData objectForKey:kPNResponseChannelsKey]) {
            
            responseData = [responseData valueForKey:kPNResponseChannelsKey];
            [responseData enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *clienOnChannelData,
                                                              BOOL *channelEnumeratorStop) {
                
                [client addClientData:clienOnChannelData forChannel:[PNChannel channelWithName:channelName]];
            }];
        }
        else {
            
            [client addClientData:responseData forChannel:client.channel];
        }
        self.client = client;
    }


    return self;
}

- (id)parsedData {

    return self.client;
}

#pragma mark -


@end
