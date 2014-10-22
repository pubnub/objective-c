//
//  PNActionResponseParser.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import "PNActionResponseParser.h"
#import "PNActionResponseParser+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNStructures.h"
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub action response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNActionResponseParser ()


#pragma mark - Properties

// Stores reference on action type
@property (nonatomic, assign) PNOperationResultEvent actionType;


@end


#pragma mark - Public interface methods

@implementation PNActionResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];

    // Checking base components
    if (conforms) {

        id actionName = [response.response objectForKey:kPNResponseActionKey];
        conforms = (actionName && [actionName isKindOfClass:[NSString class]]);
    }


    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.actionType = PNOperationResultUnknown;

        NSString *action = [response.response objectForKey:kPNResponseActionKey];
        if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.leaveChannelCallback] ||
            [action isEqualToString:@"leave"]) {

            self.actionType = PNOperationResultLeave;
        }
    }


    return self;
}

- (id)parsedData {

    return [NSNumber numberWithInt:self.actionType];
}

- (NSString *)description {

    NSString *action = @"unknown";
    switch (self.actionType) {

        case PNOperationResultLeave:

            action = @"leave";
            break;
        default:
            break;
    }


    return [NSString stringWithFormat:@"%@ (%p): <action: %@>", NSStringFromClass([self class]), self, action];
}


#pragma mark -


@end
