//
//  NSObject+PNAddition.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSObject+PNAddition.h"
#import <objc/runtime.h>


#pragma mark Category methods implementation

@implementation NSObject (PNAddition)


#pragma mark - Class methods

+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector {
    
    method_exchangeImplementations(class_getClassMethod(self, originalSelector), class_getClassMethod(self, replacementSelector));
}

+ (void)temporarilySwizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector duringBlockExecution:(void(^)(void))codeBlock {
    
    [self swizzleMethod:originalSelector with:replacementSelector];
    if (codeBlock) {
        
        codeBlock();
    }
    // Swizzle implementation back on their places
    [self swizzleMethod:originalSelector with:replacementSelector];
}


#pragma mark - Instance methods

- (void)swizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector {
    
    method_exchangeImplementations(class_getInstanceMethod([self class], originalSelector), class_getInstanceMethod([self class], replacementSelector));
}

- (void)temporarilySwizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector duringBlockExecution:(void(^)(void))codeBlock {
    
    [self swizzleMethod:originalSelector with:replacementSelector];
    if (codeBlock) {
        
        codeBlock();
    }
    // Swizzle implementation back on their places
    [self swizzleMethod:originalSelector with:replacementSelector];
}

#pragma mark -


@end
