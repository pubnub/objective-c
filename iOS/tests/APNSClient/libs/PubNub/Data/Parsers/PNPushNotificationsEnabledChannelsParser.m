//
//  PNPushNotificationsEnabledChannelsParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 05/15/13.
//
//

#import "PNPushNotificationsEnabledChannelsParser.h"
#import "PNResponse.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub push notification enabled channel response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface declaration

@interface PNPushNotificationsEnabledChannelsParser ()


#pragma mark - Properties

// Stores reference on list of channels for which push notifications
// was enabled before
@property (nonatomic, strong) NSArray *channels;


#pragma mark - Instance methods

/**
 * Returns reference on initialized parser for concrete
 * response
 */
- (id)initWithResponse:(PNResponse *)response;

@end


#pragma mark - Public intterface implementation

@implementation PNPushNotificationsEnabledChannelsParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    return [response.response isKindOfClass:[NSArray class]];
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.channels = (NSArray *)response.response;
    }


    return self;
}

- (id)parsedData {

    return self.channels;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <channels: %@>",
                    NSStringFromClass([self class]),
                    self,
                    self.channels];
}

#pragma mark -


@end
