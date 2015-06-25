/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNClass.h"
#import <objc/runtime.h>


#pragma mark Private interface declaration

@interface PNClass ()


#pragma mark - Misc

/**
 @brief  Registered classes.
 
 @return List of PubNub SDK classes which has been loaded to the memory.
 
 @since 4.0
 */
+ (NSArray *)classes;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNClass


#pragma mark - Class filtering

+ (NSArray *)classesConformingToProtocol:(Protocol *)protocol {
    
    NSMutableArray *classesList = [NSMutableArray new];
    for (Class class in [self classes]) {
        
        if (class_conformsToProtocol(class, protocol)) {
            
            [classesList addObject:class];
        }
    }
    
    return ([classesList count] ? [classesList copy] : nil);
}

+ (NSArray *)classesRespondingToSelector:(SEL)selector {
    
    NSMutableArray *classesList = [NSMutableArray new];
    for (Class class in [self classes]) {
        
        if (class_getClassMethod(class, selector) || class_getInstanceMethod(class, selector)) {
            
            [classesList addObject:class];
        }
    }
    
    return ([classesList count] ? [classesList copy] : nil);
}


#pragma mark - Misc

+ (NSArray *)classes {
    
    NSMutableArray *classesList = [NSMutableArray new];
    unsigned int visibleClassesCount;
    Class *classes = objc_copyClassList(&visibleClassesCount);
    for (unsigned int classIdx = 0; classIdx < visibleClassesCount; classIdx++) {
        
        if ([NSStringFromClass(classes[classIdx]) hasPrefix:@"PN"] ||
            [NSStringFromClass(classes[classIdx]) isEqualToString:@"PubNub"]) {
            
            [classesList addObject:classes[classIdx]];
        }
    }
    free(classes);
    
    return ([classesList count] ? [classesList copy] : nil);
}

#pragma mark -


@end
