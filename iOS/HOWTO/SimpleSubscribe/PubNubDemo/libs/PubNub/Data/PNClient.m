/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClient+Protected.h"
#import "PNChannel+Protected.h"
#import "PNChannelGroup.h"
#import "PNConstants.h"


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
        self.clientData = [NSMutableDictionary dictionary];
        self.channelsWithState = [NSMutableArray array];
        self.channel = channel;
        [self addClientData:data forChannel:channel];
    }


    return self;
}

- (void)setChannel:(PNChannel *)channel {
    
    if (!channel.isChannelGroup) {
        
        _channel = channel;
    }
    else {
        
        _group = (PNChannelGroup *)channel;
    }
    if (self.unboundData) {
        
        [self addClientData:self.unboundData forChannel:channel];
        self.unboundData = nil;
    }
}

- (BOOL)isAnonymous {

    return [self.identifier isEqualToString:kPNAnonymousParticipantIdentifier];
}

- (NSArray *)channels {
    
    return self.channelsWithState;
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {
    
    return (channel ? [self.clientData valueForKey:channel.name] : nil);
}

- (void)addClientData:(NSDictionary *)data forChannel:(PNChannel *)channel {
    
    if (data) {
        
        if (channel) {
            
            if (![self.channelsWithState containsObject:channel]) {
                
                [self.channelsWithState addObject:channel];
            }
            
            [self.clientData setValue:data forKey:channel.name];
        }
        else {
            
            self.unboundData = data;
        }
    }
}


#pragma mark - Misc methods

- (NSString *)description {

    return [NSString stringWithFormat:@"%@(%p) %@ on (%@) channel (%@)", NSStringFromClass([self class]), self,
            self.identifier,
            ([self.channels count] ? [[self.channels valueForKey:@"name"] componentsJoinedByString:@","] : self.channel.name),
            self.clientData];
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@|%@|%@>", (self.identifier ? self.identifier : [NSNull null]),
            (self.channels ? [self.clientData performSelector:@selector(logDescription)] : [NSNull null]),
            (self.group.name ? self.group.name : [NSNull null]),
            (self.clientData ? [self.clientData performSelector:@selector(logDescription)] : [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
