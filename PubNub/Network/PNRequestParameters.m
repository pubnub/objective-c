/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNRequestParameters.h"


#pragma mark Protected interface declaration

@interface PNRequestParameters ()


#pragma mark - Properties

/**
 @brief  Stores reference on key/value pairs which should be expanded in remote resource path.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *resourcePathComponents;

/**
 @brief  Stores reference on key/value pairs which should be expanded in query string.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *queryFields;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNRequestParameters


#pragma mark - Information

- (NSDictionary<NSString *, NSString *> *)pathComponents {
    
    return (self.resourcePathComponents.count ? [self.resourcePathComponents copy] : nil);
}

- (NSDictionary<NSString *, NSString *> *)query {
    
    return (self.queryFields.count ? [self.queryFields copy] : nil);
}


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _resourcePathComponents = [NSMutableDictionary new];
        _queryFields = [NSMutableDictionary new];
    }
    
    return self;
}


#pragma mark - Path components manipulation

- (void)addPathComponent:(NSString *)component forPlaceholder:(NSString *)componentPlaceholder {
    
    NSParameterAssert(component);
    NSParameterAssert(componentPlaceholder);
    [self.resourcePathComponents setValue:component forKey:componentPlaceholder];
}

- (void)removePathComponentForPlaceholder:(NSString *)componentPlaceholder {
    
    NSParameterAssert(componentPlaceholder);
    [self.resourcePathComponents removeObjectForKey:componentPlaceholder];
}

- (void)addPathComponents:(NSDictionary *)components {
    
    NSParameterAssert(components);
    [self.resourcePathComponents addEntriesFromDictionary:components];
}

- (void)removePathComponents:(NSArray *)components {
    
    NSParameterAssert(components);
    [self.resourcePathComponents removeObjectsForKeys:components];
}


#pragma mark - Query fields manipulation

- (void)addQueryParameter:(NSString *)parameter forFieldName:(NSString *)parameterFieldName {
    
    NSParameterAssert(parameter);
    NSParameterAssert(parameterFieldName);
    [self.queryFields setValue:parameter forKey:parameterFieldName];
}

- (void)removeQueryParameterWithFieldName:(NSString *)parameterFieldName {
    
    NSParameterAssert(parameterFieldName);
    [self.queryFields removeObjectForKey:parameterFieldName];
}

- (void)addQueryParameters:(NSDictionary *)parameters {
    
    NSParameterAssert(parameters);
    [self.queryFields addEntriesFromDictionary:parameters];
}

- (void)removeQueryParameters:(NSArray *)parameters {
    
    NSParameterAssert(parameters);
    [self.queryFields removeObjectsForKeys:parameters];
}

#pragma mark - 


@end
