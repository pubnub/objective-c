/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSString+PNTest.h"


#pragma mark Category interface implementation

@implementation NSString (PNTest)


#pragma mark - Initialization & Configuration

- (NSString *)pnt_stringWithLength:(NSUInteger)length {
    NSUInteger iterationsCount = (NSUInteger)ceilf((float)length/(float)self.length);
    NSMutableString *targetString = [NSMutableString new];
    NSUInteger receiverLength = self.length;
    NSUInteger targetStringLength = 0;
    
    if (length > self.length) {
        for (NSUInteger iteration = 0; iteration < iterationsCount; iteration++) {
            if (targetStringLength + receiverLength < length) {
                targetStringLength += receiverLength;
                [targetString appendString:self];
            } else {
                NSUInteger restLength = length - targetStringLength;
                [targetString appendString:[self substringWithRange:NSMakeRange(0, restLength)]];
            }
        }
    } else {
        [targetString setString:[self substringWithRange:NSMakeRange(0, length)]];
    }
    
    return targetString;
}

- (NSData *)pnt_dataFromHex {
    NSString *string = [self lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    NSUInteger length = string.length;
    NSUInteger i = 0;
    
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        
        if (c < '0' || (c > '9' && c < 'a') || c > 'f') {
            continue;
        }
        
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    return data;
}


#pragma mark - Check helpers

- (BOOL)pnt_includesString:(NSString *)string {
    if (!string || !string.length) {
        return NO;
    }
    
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)pnt_includesAnyString:(NSArray<NSString *> *)strings {
    for (NSString *string in strings) {
        if ([self pnt_includesString:string]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -


@end
