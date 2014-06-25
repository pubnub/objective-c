//
//  NSDate+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/4/13.
//
//

#import <Foundation/Foundation.h>


// ARC check
#if !__has_feature(objc_arc)
#error PubNub date category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


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

    static dispatch_once_t dispatchOnceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&dispatchOnceToken, ^{

        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss.SSS";
    });


    return dateFormatter;
}

#pragma mark -


@end
