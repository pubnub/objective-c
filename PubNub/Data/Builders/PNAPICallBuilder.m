/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark - Protected interface declaration

@interface PNAPICallBuilder ()


#pragma mark - Properties

/**
 @brief      Stores reference on list of user-configured API call flags.
 @discussion Usually stores flahs which allow to identify API type (if there is group of API available for 
             single endpoint). Flags also used in cased when default state should be adjusted. 
 
 @since 4.5.4
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *flags;

/**
 @brief      Stores reference on API call parameter-values dictionary.
 @discussion Parameters allow to configure particular API call with values which should be passed to \b PubNub
             service.
 
 @since 4.5.4
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *parameters;

/**
 @brief Stores reference on block which will be called in response \c -performWithBlock: method call.
 
 @since 4.5.4
 */
@property (nonatomic, copy) PNAPICallCompletionBlock executionBlock;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize builder which will be able to handle API \c parotocol and accept user provided argument
         values.
 
 @since 4.5.4
 
 @param block Reference on block which will be called in response \c -performWithBlock: method call. Block 
              pass two arguments: \c flags - list of user-configured API flags; \c parameters - list of API 
              request query and URI parameter-value pairs.
 
 @return Initialized and ready to use API call builder instance.
 */
- (instancetype)initWithExecutionBlock:(PNAPICallCompletionBlock)block;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNAPICallBuilder


#pragma mark - Initialization and Configuration

+ (void)copyMethodsFromClasses:(NSArray<Class> *)classes {
    
    unsigned int methodsCount = 0;
    for (NSUInteger classIdx = 0; classIdx < classes.count; classIdx++) {
        
        Method *methods = class_copyMethodList(classes[classIdx], &methodsCount);
        for (unsigned int methodIdx = 0; methodIdx < methodsCount; methodIdx++) {
            
            Method method = methods[methodIdx];
            SEL selector = method_getName(method);
            if (!class_getInstanceMethod(self, selector)) {
                
                IMP implementation = method_getImplementation(method);
                class_addMethod(self, selector, implementation, method_getTypeEncoding(method));
            }
        }
        free(methods);
    }
}

+ (instancetype)builderWithExecutionBlock:(PNAPICallCompletionBlock)block {
    
    return [[self alloc] initWithExecutionBlock:block];
}

- (instancetype)initWithExecutionBlock:(PNAPICallCompletionBlock)block {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        _flags = [NSMutableArray new];
        _parameters = [NSMutableDictionary new];
        _executionBlock = [block copy];
    }
    
    return self;
}

- (void)setFlag:(NSString *)flag {
    
    [self.flags addObject:flag];
}

- (void)setValue:(nullable id)value forParameter:(NSString *)parameter {
    
    self.parameters[parameter] = value;
}

- (void)performWithBlock:(id)block {
    
    self.parameters[@"block"] = block;
    self.executionBlock(self.flags, self.parameters);
}

#pragma mark -


@end
