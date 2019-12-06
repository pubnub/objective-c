/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNDate.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNDate ()


#pragma mark - Information

/**
 * @brief Shared date formatter configured according to RFC3339 requirements.
 */
@property (class, nonatomic, readonly, strong) NSDateFormatter *rfc3339Formatter;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNDate


#pragma mark - Information

+ (NSDateFormatter *)rfc3339Formatter {
    static NSDateFormatter *_sharedRFC3339Formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedRFC3339Formatter = [NSDateFormatter new];
        _sharedRFC3339Formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _sharedRFC3339Formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _sharedRFC3339Formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
    });
    
    return _sharedRFC3339Formatter;
}


#pragma mark - Conversion

+ (NSString *)RFC3339StringFromDate:(NSDate *)date {
    return [[self rfc3339Formatter] stringFromDate:date];
}

#pragma mark -


@end
