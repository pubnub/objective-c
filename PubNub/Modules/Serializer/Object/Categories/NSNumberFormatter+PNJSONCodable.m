#import "NSNumberFormatter+PNJSONCodable.h"


#pragma mark Interface implementation

@implementation NSNumberFormatter (PNJSONCodable)


#pragma mark - Properties

+ (NSNumberFormatter *)pnjc_number {
    static NSNumberFormatter * _numberFormatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _numberFormatter = [NSNumberFormatter new];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.usesGroupingSeparator = NO;
        _numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });

    return _numberFormatter;
}

#pragma mark -


@end
