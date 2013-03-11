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

- (NSString *)ASCIIStringHEXEncoded:(BOOL)shouldUseHEXCodes;

@end


#pragma mark Public interface implementation

@implementation NSString (PNAddition)


#pragma mark - Instance methods

- (NSString *)percentEscapedString {
    
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)self,
                                                                        NULL,
                                                                        (CFStringRef)@":/?#[]@!$&’()*+,;=",
                                                                        kCFStringEncodingUTF8);
    
    
    return CFBridgingRelease(escapedString);
}

- (NSString *)ASCIIString {

    return [self ASCIIStringHEXEncoded:NO];
}

- (NSString *)ASCIIHEXString {

    return [self ASCIIStringHEXEncoded:YES];
}

- (NSString *)ASCIIStringHEXEncoded:(BOOL)shouldUseHEXCodes {

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

#pragma mark -

@end
