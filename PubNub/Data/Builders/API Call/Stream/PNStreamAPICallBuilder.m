/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNStreamAPICallBuilder.h"
#import "PNStreamModificationAPICallBuilder.h"
#import "PNStreamAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNStreamAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    
    if (self == [PNStreamAPICallBuilder class]) {
        
        [self copyMethodsFromClasses:@[[PNStreamModificationAPICallBuilder class], 
                                       [PNStreamAuditAPICallBuilder class]]];
    }
}


#pragma mark - Stream state manipulation

- (PNStreamModificationAPICallBuilder *(^)(void))add {
    
    return ^PNStreamModificationAPICallBuilder* {
        
        object_setClass(self, [PNStreamModificationAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNStreamModificationAPICallBuilder *)self;
    };
}

- (PNStreamModificationAPICallBuilder *(^)(void))remove {
    
    return ^PNStreamModificationAPICallBuilder* {
        
        object_setClass(self, [PNStreamModificationAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNStreamModificationAPICallBuilder *)self;
    };
}


#pragma mark - Stream state audit

- (PNStreamAuditAPICallBuilder *(^)(void))audit {
    
    return ^PNStreamAuditAPICallBuilder* {
        
        object_setClass(self, [PNStreamAuditAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNStreamAuditAPICallBuilder *)self;
    };
}

#pragma mark -


@end
