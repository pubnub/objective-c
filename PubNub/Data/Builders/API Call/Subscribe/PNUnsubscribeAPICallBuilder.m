/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNUnsubscribeAPICallBuilder.h"
#import "PNUnsubscribeChannelsOrGroupsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNUnsubscribeAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNUnsubscribeAPICallBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNUnsubscribeChannelsOrGroupsAPICallBuilder class]]];
    }
}


#pragma mark - Channels and Channel Groups

- (PNUnsubscribeChannelsOrGroupsAPICallBuilder *(^)(NSArray<NSString *> *channels))channels {
    
    return ^PNUnsubscribeChannelsOrGroupsAPICallBuilder* (NSArray<NSString *> *channels) {
        
        object_setClass(self, [PNUnsubscribeChannelsOrGroupsAPICallBuilder class]);
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        
        return (PNUnsubscribeChannelsOrGroupsAPICallBuilder *)self;
    };
}

- (PNUnsubscribeChannelsOrGroupsAPICallBuilder *(^)(NSArray<NSString *> *channelGroups))channelGroups {
    
    return ^PNUnsubscribeChannelsOrGroupsAPICallBuilder* (NSArray<NSString *> *channelGroups) {
        
        object_setClass(self, [PNUnsubscribeChannelsOrGroupsAPICallBuilder class]);
        [self setValue:channelGroups forParameter:NSStringFromSelector(_cmd)];
        
        return (PNUnsubscribeChannelsOrGroupsAPICallBuilder *)self;
    };
}


#pragma mark - Presence

- (PNUnsubscribeAPICallBuilder *(^)(NSArray<NSString *> *presenceChannels))presenceChannels {
    
    return ^PNUnsubscribeAPICallBuilder* (NSArray<NSString *> *presenceChannels) {
        
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
