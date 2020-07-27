/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNXML+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNXML ()


#pragma mark - Information

/**
 * @brief Serialized XML data.
 */
@property (nonatomic, copy) NSDictionary *parsedData;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize parser XML representation model.
 *
 * @param data Dictionary with information which has been parsed by \a NSXMLParser.
 *
 * @return Initialized and ready to use XML representation model.
 */
- (instancetype)initWithDictionary:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END


@implementation PNXML


#pragma mark - Initialization & Configuration

+ (instancetype)xmlWithDictionary:(NSDictionary *)data {
    return [[self alloc] initWithDictionary:data];
}

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if ((self = [super init])) {
        _parsedData = [data copy];
    }
    
    return self;
}


#pragma mark - Reading

- (id)valueForKey:(NSString *)key {
    return self.parsedData[key][@"value"];
}

- (id)valueForKeyPath:(NSString *)keyPath {
    NSMutableArray<NSString *> *pathComponents = [[keyPath componentsSeparatedByString:@"."] mutableCopy];
    NSString *attributeName = nil;
    NSDictionary *element = nil;
    id value = nil;
    
    if ([pathComponents.lastObject hasPrefix:@"@"]) {
        attributeName = [pathComponents.lastObject substringFromIndex:1];
        [pathComponents removeLastObject];
        keyPath = [pathComponents componentsJoinedByString:@"."];
    }
    
    element = [self.parsedData valueForKeyPath:keyPath];
    
    if (!attributeName) {
        value = element[@"value"];
    } else {
        value = element[@"attributes"][attributeName];
    }
    
    return value;
}

#pragma mark -


@end
