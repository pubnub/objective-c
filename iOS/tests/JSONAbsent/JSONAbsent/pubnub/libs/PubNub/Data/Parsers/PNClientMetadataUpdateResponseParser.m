/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClientMetadataUpdateResponseParser.h"
#import "PNResponse+Protected.h"
#import "PNPrivateImports.h"


#pragma mark Private interface declaration

@interface PNClientMetadataUpdateResponseParser ()


#pragma mark - Properties

/**
 Stores reference on resulting client information (with updated metadata).
 */
@property (nonatomic, strong) PNClient *client;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNClientMetadataUpdateResponseParser


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
