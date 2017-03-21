/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNAPNSAPICallBuilder.h"
#import "PNAPNSModificationAPICallBuilder.h"
#import "PNAPNSAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNAPNSAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNAPNSAPICallBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNAPNSModificationAPICallBuilder class],
                                       [PNAPNSAuditAPICallBuilder class]]];
    }
}


#pragma mark - APNS state manipulation

- (PNAPNSModificationAPICallBuilder *(^)(void))enable {
    
    return ^PNAPNSModificationAPICallBuilder* {
        
        object_setClass(self, [PNAPNSModificationAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNAPNSModificationAPICallBuilder *)self;
    };
}

- (PNAPNSModificationAPICallBuilder *(^)(void))disable {
    
    return ^PNAPNSModificationAPICallBuilder* {
        
        object_setClass(self, [PNAPNSModificationAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNAPNSModificationAPICallBuilder *)self;
    };
}


#pragma mark - APNS state audition

- (PNAPNSAuditAPICallBuilder *(^)(void))audit {
    
    return ^PNAPNSAuditAPICallBuilder* {
        
        object_setClass(self, [PNAPNSAuditAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNAPNSAuditAPICallBuilder *)self;
    };
}

#pragma mark -


@end
