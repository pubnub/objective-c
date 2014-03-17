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


// ARC check
#if !__has_feature(objc_arc)
#error PubNub error response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


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

        id responseData = response.response;

        PNError *error;
        
        if ([response.response isKindOfClass:[NSDictionary class]]) {
            
            NSString *errorMessage = [responseData valueForKey:kPNResponseErrorMessageKey];
            if (!errorMessage) {
                
                errorMessage = response.message;
            }
            NSArray *associatedChannels = nil;
            if (![[responseData valueForKey:kPNResponseErrorMessageKey] isKindOfClass:[NSString class]]) {
                
                if ([responseData valueForKey:kPNResponseErrorAdditionalMessageKey]) {
                    
                    errorMessage = [responseData valueForKey:kPNResponseErrorAdditionalMessageKey];
                }
            }
            
            if ([responseData valueForKeyPath:kPNResponseErrorChannelsKey]) {
                
                associatedChannels = [PNChannel channelsWithNames:[responseData valueForKeyPath:kPNResponseErrorChannelsKey]];
            }
            
            
            if (response.statusCode != 200 && errorMessage == nil) {
                
                error = [PNError errorWithHTTPStatusCode:response.statusCode];
            }
            else {
                
                error = [PNError errorWithResponseErrorMessage:errorMessage];
            }
            
            if (associatedChannels) {
                
                error.associatedObject = associatedChannels;
            }
        }
        else {
            
            error = [PNError errorWithCode:kPNResponseMalformedJSONError];
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
