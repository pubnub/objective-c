//
//  PNTimeTokenResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNTimeTokenResponseParser.h"
#import "PNResponse.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub time token response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNTimeTokenResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) NSNumber *timeToken;


#pragma mark - Instance methods

/**
 * Returns reference on initialized parser for concrete
 * response
 */
- (id)initWithResponse:(PNResponse *)response;


@end


#pragma mark Public interface methods

@implementation PNTimeTokenResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSArray class]];

    // Checking base components
    if (conforms) {

        conforms = ([(NSArray *)response.response count] == 1);
        if (conforms) {

            id timeToken = [(NSArray *)response.response lastObject];
            conforms = ([timeToken isKindOfClass:[NSNumber class]] || [timeToken isKindOfClass:[NSString class]]);
        }
    }


    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        id timeToken = [(NSArray *)response.response lastObject];
        self.timeToken = PNNumberFromUnsignedLongLongString(timeToken);
    }


    return self;
}

- (id)parsedData {

    return self.timeToken;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <time token: %@>",
                    NSStringFromClass([self class]),
                    self,
                    self.timeToken];
}

#pragma mark -


@end
