/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNPresenceAPICallBuilder.h"
#import "PNPresenceHeartbeatAPICallBuilder.h"
#import "PNPresenceWhereNowAPICallBuilder.h"
#import "PNPresenceHereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNPresenceAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNPresenceAPICallBuilder class]) {
        [self copyMethodsFromClasses:@[[PNPresenceHeartbeatAPICallBuilder class],
                                       [PNPresenceWhereNowAPICallBuilder class],
                                       [PNPresenceHereNowAPICallBuilder class]]];
    }
}


#pragma mark - Here Now

- (PNPresenceHereNowAPICallBuilder * (^)(void))hereNow {
    
    return ^PNPresenceHereNowAPICallBuilder * {
        object_setClass(self, [PNPresenceHereNowAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNPresenceHereNowAPICallBuilder *)self;
    };
}


#pragma mark - Where Now

- (PNPresenceWhereNowAPICallBuilder * (^)(void))whereNow {
    
    return ^PNPresenceWhereNowAPICallBuilder * {
        object_setClass(self, [PNPresenceWhereNowAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNPresenceWhereNowAPICallBuilder *)self;
    };
}


#pragma mark - Heartbeat

- (PNPresenceHeartbeatAPICallBuilder * (^)(BOOL connected))connected {

    return ^PNPresenceHeartbeatAPICallBuilder * (BOOL connected) {
        object_setClass(self, [PNPresenceHeartbeatAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        [self setValue:@(connected) forParameter:NSStringFromSelector(_cmd)];
        return (PNPresenceHeartbeatAPICallBuilder *)self;
    };
}

#pragma mark -


@end
