/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNDictionary.h"
#import "PNString.h"


#pragma mark Protected interface declaration

@interface PNDictionary ()


#pragma mark - Properties 

/**
 @brief  Reference on dictionary backing storage.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableDictionary *storage;

@end


#pragma mark - Interface implementation

@implementation PNDictionary


#pragma mark - API helper

+ (BOOL)hasFlattenedContent:(NSDictionary *)dictionary {
    
    BOOL flattened = YES;
    for (NSString *key in dictionary) {
        
        flattened = ![dictionary[key] respondsToSelector:@selector(count)];
        if (!flattened) {
            
            break;
        }
    }
    
    return flattened;
}


#pragma mark - URL helper

+ (NSString *)queryStringFrom:(NSDictionary *)dictionary {
    
    NSMutableString *query = [NSMutableString new];
    for (NSString *queryKey in dictionary) {
        
        [query appendFormat:@"%@%@=%@", ([query length] ? @"&" : @""), queryKey,
         dictionary[queryKey]];
    }
    
    return ([query length] > 0 ? [query copy] : nil);
}


- (instancetype)initWithCapacity:(NSUInteger)numItems {
    
    // Check whether intialization successuful or not.
    if ((self = [super init])) {
        
        _storage = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    
    return self;
}

- (instancetype)init {
    
    // Check whether intialization was successful or not.
    if ((self = [super init])) {
        
        _storage = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    [self.storage setObject:anObject forKey:aKey];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    
    [self.storage setObject:obj forKeyedSubscript:key];
}

- (id)valueForKey:(NSString *)key {
    
    return [self.storage valueForKey:key];
}

- (id)objectForKey:(id)aKey {
    
    return [self.storage objectForKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    
    [self.storage removeObjectForKey:aKey];
}

- (NSUInteger)count {
    
    return [self.storage count];
}

- (NSEnumerator *)keyEnumerator {
    
    return [self.storage keyEnumerator];
}

- (id)copy {
    
    return self;
}

- (id)mutableCopy {
    
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    return [self.storage methodSignatureForSelector:@selector(valueForKey:)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSString* key = NSStringFromSelector(anInvocation.selector);
    anInvocation.selector = @selector(objectForKey:);
    [anInvocation setArgument:&key atIndex:2];
    
    [anInvocation invokeWithTarget:self.storage];
}

#pragma mark -


@end
