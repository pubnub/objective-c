/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PNChannelGroup.h"
#import "PNChannel+Protected.h"


#pragma mark Private interface declaration

@interface PNChannelGroup ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *nspace;
@property (nonatomic, strong) NSArray *channels;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChannelGroup


#pragma mark - Class methods

+ (PNChannelGroup *)channelGroupWithName:(NSString *)name {
    
    return [self channelGroupWithName:name shouldObservePresence:NO];
}

+ (PNChannelGroup *)channelGroupWithName:(NSString *)name shouldObservePresence:(BOOL)observePresence {
    
    return [self channelGroupWithName:name inNamespace:nil shouldObservePresence:observePresence];
}

+ (PNChannelGroup *)channelGroupWithName:(NSString *)name inNamespace:(NSString *)nspace {
    
    return [self channelGroupWithName:name inNamespace:nspace shouldObservePresence:NO];
}

+ (PNChannelGroup *)channelGroupWithName:(NSString *)name inNamespace:(NSString *)nspace
                   shouldObservePresence:(BOOL)observePresence {
    
    NSString *channelName = name;
    if (channelName && nspace) {
        
        channelName = [NSString stringWithFormat:@"%@:%@", nspace, channelName];
    }
    if (!channelName && nspace) {
        
        if (![nspace isEqualToString:@":"]) {
            
            channelName = [nspace stringByAppendingString:@":"];
        }
    }
    if (!channelName) {
        
        channelName = @":";
    }
    
    id <PNChannelProtocol> (^channelCreateBlock)(void) = ^{
        
        return [self channelWithName:channelName shouldObservePresence:observePresence];
    };
    PNChannelGroup *channel = channelCreateBlock();
    if (![channel isKindOfClass:self]) {
        
        [self removeChannelFromCache:channel];
        channel = channelCreateBlock();
    }
    channel.channelGroup = YES;
    channel.groupName = name;
    channel.nspace = nspace;
    
    
    return channel;
}


#pragma mark - Instance methods

#pragma mark - Misc methods

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@(%p) %@ in \"%@\" namespace\nChannels: %@", NSStringFromClass([self class]),
                                      self, self.groupName, self.nspace, self.channels];
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@|%@>", (self.groupName ? self.groupName : [NSNull null]),
            (self.nspace ? self.nspace : [NSNull null]),
            ([self.channels count] ? [self.channels performSelector:@selector(logDescription)] : [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
