/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
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
+ (NSArray<Class> *)classes;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNClass


#pragma mark - Class filtering

+ (nullable NSArray<Class> *)classesConformingToProtocol:(Protocol *)protocol {
    
    NSMutableArray *classesList = [NSMutableArray new];
    for (Class class in [self classes]) {
        
        if (class_conformsToProtocol(class, protocol)) { [classesList addObject:class]; }
    }
    
    return (classesList.count ? [classesList copy] : nil);
}

+ (nullable NSArray<Class> *)classesRespondingToSelector:(SEL)selector {
    
    NSMutableArray *classesList = [NSMutableArray new];
    for (Class class in [self classes]) {
        
        if (class_getClassMethod(class, selector) || class_getInstanceMethod(class, selector)) {
            
            [classesList addObject:class];
        }
    }
    
    return (classesList.count ? [classesList copy] : nil);
}


#pragma mark - Misc

+ (nullable NSArray<Class> *)classes {
    
    NSMutableArray *classesList = [NSMutableArray new];
    unsigned int visibleClassesCount;
    Class *classes = objc_copyClassList(&visibleClassesCount);
    for (unsigned int classIdx = 0; classIdx < visibleClassesCount; classIdx++) {
        
        NSString *className = NSStringFromClass(classes[classIdx]);
        if ([className hasPrefix:@"PN"] || [className isEqualToString:@"PubNub"]) {
            
            [classesList addObject:classes[classIdx]];
        }
    }
    free(classes);
    
    return (classesList.count ? [classesList copy] : nil);
}

#pragma mark -


@end
