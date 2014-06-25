/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClient+Protected.h"
#import "PNConstants.h"
#import "PNChannel.h"


#pragma mark Public interface implementation

@implementation PNClient


#pragma mark - Class methods

+ (PNClient *)anonymousClient {

    return [self clientForIdentifier:nil channel:nil andData:nil ];
}

+ (PNClient *)anonymousClientForChannel:(PNChannel *)channel {

    return [self clientForIdentifier:nil channel:channel andData:nil ];
}

+ (PNClient *)clientForIdentifier:(NSString *)identifier channel:(PNChannel *)channel andData:(NSDictionary *)data {

   return [[self alloc] initWithIdentifier:identifier channel:channel andData:data];
}


#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)identifier channel:(PNChannel *)channel andData:(NSDictionary *)data {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.identifier = identifier ? identifier : kPNAnonymousParticipantIdentifier;
        self.channel = channel;
        self.data = data;
    }


    return self;
}

- (BOOL)isAnonymous {

    return [self.identifier isEqualToString:kPNAnonymousParticipantIdentifier];
}


#pragma mark - Misc methods

- (NSString *)description {

    return [NSString stringWithFormat:@"%@(%p) %@ on \"%@\" channel (%@)", NSStringFromClass([self class]), self,
                    self.identifier, self.channel.name, self.data];
}

#pragma mark -


@end
