/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClientStateResponseParser.h"
#import "PNResponse+Protected.h"
#import "PNClient+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub client state request response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface declaration

@interface PNClientStateResponseParser ()


#pragma mark - Properties

/**
 Refrence on \b PNClient instance which will store client information.
 */
@property (nonatomic, strong) PNClient *client;

#pragma mark -


@end


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


    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSDictionary *responseData = response.response;
        self.client = response.additionalData;
        self.client.data = responseData;
    }


    return self;
}

- (id)parsedData {

    return self.client;
}

#pragma mark -


@end
