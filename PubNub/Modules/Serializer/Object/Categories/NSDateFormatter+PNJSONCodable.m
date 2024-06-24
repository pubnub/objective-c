#import "NSDateFormatter+PNJSONCodable.h"


#pragma mark Interface implementation

@implementation NSDateFormatter (PNJSONCodable)


#pragma mark - Properties

+ (NSDateFormatter *)pnjc_iso8601 {
    static NSDateFormatter *_iso8601Formatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _iso8601Formatter = [NSDateFormatter new];
        _iso8601Formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        _iso8601Formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _iso8601Formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });

    return _iso8601Formatter;
}

#pragma mark -


@end
