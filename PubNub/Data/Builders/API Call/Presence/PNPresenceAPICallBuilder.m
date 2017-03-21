/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNPresenceAPICallBuilder.h"
#import "PNPresenceWhereNowAPICallBuilder.h"
#import "PNPresenceHereNowAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNPresenceAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNPresenceAPICallBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNPresenceWhereNowAPICallBuilder class], 
                                       [PNPresenceHereNowAPICallBuilder class]]];
    }
}


#pragma mark - Here Now

- (PNPresenceHereNowAPICallBuilder *(^)(void))hereNow {
    
    return ^PNPresenceHereNowAPICallBuilder* {
        
        object_setClass(self, [PNPresenceHereNowAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNPresenceHereNowAPICallBuilder *)self;
    };
}


#pragma mark - Where Now

- (PNPresenceWhereNowAPICallBuilder *(^)(void))whereNow {
    
    return ^PNPresenceWhereNowAPICallBuilder* {
        
        object_setClass(self, [PNPresenceWhereNowAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNPresenceWhereNowAPICallBuilder *)self;
    };
}

#pragma mark -


@end
