/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNSubscribeAPIBuilder.h"
#import "PNSubscribeChannelsOrGroupsAPIBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNSubscribeAPIBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNSubscribeAPIBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNSubscribeChannelsOrGroupsAPIBuilder class]]];
    }
}


#pragma mark - Channels and Channel Groups

- (PNSubscribeChannelsOrGroupsAPIBuilder *(^)(NSArray<NSString *> *channels))channels {
    
    return ^PNSubscribeChannelsOrGroupsAPIBuilder* (NSArray<NSString *> *channels) {
        
        object_setClass(self, [PNSubscribeChannelsOrGroupsAPIBuilder class]);
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        
        return (PNSubscribeChannelsOrGroupsAPIBuilder *)self;
    };
}

- (PNSubscribeChannelsOrGroupsAPIBuilder *(^)(NSArray<NSString *> *channelGroups))channelGroups {
    
    return ^PNSubscribeChannelsOrGroupsAPIBuilder* (NSArray<NSString *> *channelGroups) {
        
        object_setClass(self, [PNSubscribeChannelsOrGroupsAPIBuilder class]);
        [self setValue:channelGroups forParameter:NSStringFromSelector(_cmd)];
        
        return (PNSubscribeChannelsOrGroupsAPIBuilder *)self;
    };
}


#pragma mark - Presence

- (PNSubscribeAPIBuilder *(^)(NSArray<NSString *> *presenceChannels))presenceChannels {
    
    return ^PNSubscribeAPIBuilder* (NSArray<NSString *> *presenceChannels) {
        
        [self setValue:presenceChannels forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(void))perform {
    
    return ^{ [super performWithBlock:nil]; };
}

#pragma mark -


@end
