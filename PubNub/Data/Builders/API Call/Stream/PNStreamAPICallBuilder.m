/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
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
        
        return self;
    };
}

- (PNStreamModificationAPICallBuilder *(^)(void))remove {
    
    return ^PNStreamModificationAPICallBuilder* {
        
        object_setClass(self, [PNStreamModificationAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Stream state audit

- (PNStreamAuditAPICallBuilder *(^)(void))audit {
    
    return ^PNStreamAuditAPICallBuilder* {
        
        object_setClass(self, [PNStreamAuditAPICallBuilder class]);
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

#pragma mark -


@end
