/**
 * @author Serhii Mamontov
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface NSDateFormatter (PNCacheablePrivate)


#pragma mark - Information

/**
 * @brief Cached list of formatters where keys are \c dateFormat strings used for configuration.
 */
+ (NSMutableDictionary<NSString *, NSDateFormatter *> *)formattersByString;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


@implementation NSDateFormatter (PNCacheable)


#pragma mark - Information

+ (NSMutableDictionary<NSString *, NSDateFormatter *> *)formattersByString {
    static NSMutableDictionary *_formattersByString;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _formattersByString = [NSMutableDictionary new];
    });
    
    return _formattersByString;
}


#pragma mark - Simple formatter

+ (NSDateFormatter *)pn_formatterWithString:(NSString *)dateFormat {
    NSDateFormatter *formatter = [self formattersByString][dateFormat];
    
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = dateFormat;
        
        [self formattersByString][dateFormat] = formatter;
    }
    
    return formatter;
}


#pragma mark - Service based formatter

+ (NSDateFormatter *)pn_objectsDateFormatter {
    return [self pn_formatterWithString:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
}

#pragma mark -


@end
