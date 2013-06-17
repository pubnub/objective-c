//
//  PNErrorResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNErrorResponseParser.h"
#import "PNErrorResponseParser+Protected.h"
#import "PNResponse.h"
#import "PNError+Protected.h"


#pragma mark - Private interface methods

@interface PNErrorResponseParser ()

#pragma mark - Properties

@property (nonatomic, strong) PNError *error;


@end


#pragma mark - Public interface methods

@implementation PNErrorResponseParser


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

        PNError *error;
        if ([responseData objectForKey:kPNResponseErrorPayloadKey] != nil &&
            (response.statusCode == 401 || response.statusCode == 403)) {

            error = [PNError errorWithHTTPStatusCode:response.statusCode];
            NSString *relatedChannelsKeyPath = [NSString stringWithFormat:@"%@.%@", kPNResponseErrorPayloadKey, kPNResponseErrorChannelsKey];
            if ([responseData valueForKeyPath:relatedChannelsKeyPath]) {

                error.associatedObject = [PNChannel channelsWithNames:[responseData valueForKeyPath:relatedChannelsKeyPath]];
            }
        }
        else {

            error = [PNError errorWithResponseErrorMessage:[responseData valueForKey:kPNResponseErrorMessageKey]];
        }
        self.error = error;
    }


    return self;
}

- (id)parsedData {

    return self.error;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <error: %@>", NSStringFromClass([self class]), self, self.error];
}

#pragma mark -


@end