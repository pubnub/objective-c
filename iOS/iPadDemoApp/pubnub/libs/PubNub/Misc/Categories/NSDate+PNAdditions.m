//
//  NSDate+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/4/13.
//
//


// ARC check
#if !__has_feature(objc_arc)
#error PubNub date category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif

#define DATE_FORMATTER_PUBNUB @"PGDateFormatter3"

#pragma mark Private category interface declaration

@interface NSDate (PNAdditionPrivate)


#pragma mark - Instance methods

#pragma mark - Misc methods

- (NSDateFormatter *)consoleOutputDateFormatter;

#pragma mark -


@end


#pragma mark - Public category interface implementation

@implementation NSDate (PNAdditions)


#pragma mark - Instance methods

- (NSString *)consoleOutputTimestamp {

    return [[self consoleOutputDateFormatter] stringFromDate:self];
}


#pragma mark - Misc methods

- (NSDateFormatter *)consoleOutputDateFormatter {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *dateTimeFormatter = [threadDictionary objectForKey:DATE_FORMATTER_PUBNUB] ;
    if (dateTimeFormatter == nil) {
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
        [threadDictionary setObject:dateTimeFormatter forKey:DATE_FORMATTER_PUBNUB];
    }
    return dateTimeFormatter;
}

#pragma mark -


@end
