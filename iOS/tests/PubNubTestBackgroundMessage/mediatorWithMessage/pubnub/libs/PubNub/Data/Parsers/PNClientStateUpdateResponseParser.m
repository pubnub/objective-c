/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClientStateUpdateResponseParser.h"
#import "PNResponse+Protected.h"
#import "PNPrivateImports.h"


#pragma mark Private interface declaration

@interface PNClientStateUpdateResponseParser ()


#pragma mark - Properties

/**
 Stores reference on resulting client information (with updated state).
 */
@property (nonatomic, strong) PNClient *client;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNClientStateUpdateResponseParser


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
        [self.client addClientData:responseData forChannel:self.client.channel];
    }


    return self;
}

- (id)parsedData {

    return self.client;
}

#pragma mark -


@end
