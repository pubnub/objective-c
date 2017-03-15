/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNStateAPICallBuilder.h"
#import "PNStateModificationAPICallBuilder.h"
#import "PNStateAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNStateAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNStateAPICallBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNStateModificationAPICallBuilder class], 
                                       [PNStateAuditAPICallBuilder class]]];
    }
}


#pragma mark - Presence state manipulation

- (PNStateModificationAPICallBuilder *(^)(void))set {
    
    return ^PNStateModificationAPICallBuilder* {
        
        object_setClass(self, [PNStateModificationAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNStateModificationAPICallBuilder *)self;
    };
}


#pragma mark - Presence state audition

- (PNStateAuditAPICallBuilder *(^)(void))audit {
    
    return ^PNStateAuditAPICallBuilder* {
        
        object_setClass(self, [PNStateAuditAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNStateAuditAPICallBuilder *)self;
    };
}

#pragma mark - 


@end
