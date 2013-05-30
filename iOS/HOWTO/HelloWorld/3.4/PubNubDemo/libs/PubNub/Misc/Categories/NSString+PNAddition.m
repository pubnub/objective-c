//
//  NSString+PNAddition.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/13.
//
//

#import "NSString+PNAddition.h"


#pragma mark Private interface implementation

@interface NSString (PNAdditionPrivate)

- (NSString *)ASCIIStringHEXEncodedString:(BOOL)shouldUseHEXCodes;

@end


#pragma mark Public interface implementation

@implementation NSString (PNAddition)


#pragma mark - Instance methods

- (NSString *)percentEscapedString {

    NSString *newlineEscapedString = [self stringByReplacingOccurrencesOfString:@"\n" withString:@"%5Cn"];
    newlineEscapedString = [newlineEscapedString stringByReplacingOccurrencesOfString:@"\r" withString:@"%5Cr"];
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)newlineEscapedString,
                                                                        NULL,
                                                                        (CFStringRef)@":/?#[]@!$&’()*+,;=",
                                                                        kCFStringEncodingUTF8);
    
    
    return CFBridgingRelease(escapedString);
}

- (NSString *)ASCIIString {

    return [self ASCIIStringHEXEncodedString:NO];
}

- (NSString *)ASCIIHEXString {

    return [self ASCIIStringHEXEncodedString:YES];
}

- (NSString *)ASCIIStringHEXEncodedString:(BOOL)shouldUseHEXCodes {

    NSMutableString *asciiString = [NSMutableString stringWithCapacity:([self length]*2.0f)];
    NSUInteger charIdx, charsCount = [self length];
    for (charIdx = 0; charIdx < charsCount; charIdx++) {

        unichar charCode = [self characterAtIndex:charIdx];
        [asciiString appendFormat:(shouldUseHEXCodes?@"%02X":@"%d"), charCode];
    }


    return asciiString;
}


#pragma mark - Cryptography methods

- (NSData *)sha256Data {

    unsigned char hashedData[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA256([data bytes], [data length], hashedData);


    return [NSData dataWithBytes:hashedData length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha256HEXString {

    return [[[self sha256Data] HEXString] lowercaseString];
}

- (NSString *)base64DecodedString {

    return [NSString stringWithUTF8String:[[NSData dataFromBase64String:self] bytes]];
}

#pragma mark -

@end
