/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNPresenceHereNowAPICallBuilder.h"
#import "PNPresenceChannelGroupHereNowAPICallBuilder.h"
#import "PNPresenceChannelHereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNPresenceHereNowAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNPresenceHereNowAPICallBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNPresenceChannelGroupHereNowAPICallBuilder class], 
                                       [PNPresenceChannelHereNowAPICallBuilder class]]];
    }
}


#pragma mark - Channel

- (PNPresenceChannelHereNowAPICallBuilder *(^)(NSString *channel))channel {
    
    return ^PNPresenceChannelHereNowAPICallBuilder* (NSString *channel) {
        
        object_setClass(self, [PNPresenceChannelHereNowAPICallBuilder class]);
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Channel Group

- (PNPresenceChannelGroupHereNowAPICallBuilder *(^)(NSString *channelGroup))channelGroup {
    
    return ^PNPresenceChannelGroupHereNowAPICallBuilder* (NSString *channelGroup) {
        
        object_setClass(self, [PNPresenceChannelGroupHereNowAPICallBuilder class]);
        [self setValue:channelGroup forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Global

- (PNPresenceHereNowAPICallBuilder *(^)(PNHereNowVerbosityLevel verbosity))verbosity {
    
    return ^PNPresenceHereNowAPICallBuilder* (PNHereNowVerbosityLevel verbosity) {
        
        [self setValue:@(verbosity) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (void(^)(PNGlobalHereNowCompletionBlock block))performWithCompletion {
    
    return ^(PNGlobalHereNowCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
