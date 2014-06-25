//
//  NSString+PNAddition.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/13.
//
//

#import "NSString+PNAddition.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub string category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface implementation

@interface NSString (PNAdditionPrivate)

- (NSString *)percentEscapedStringWithEscapeString:(NSString *)stringWithCharsForEscape;
- (NSString *)ASCIIStringHEXEncodedString:(BOOL)shouldUseHEXCodes;

@end


#pragma mark Public interface implementation

@implementation NSString (PNAddition)


#pragma mark - Instance methods

- (BOOL)isEmpty {
    
    static NSCharacterSet *nonNewlineCharSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        nonNewlineCharSet = [NSCharacterSet newlineCharacterSet];
    });
    
    
    return [[[self stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:nonNewlineCharSet] length] == 0;
}

- (NSString *)percentEscapedString {

    return [self percentEscapedStringWithEscapeString:@":/?#[]@!$&’()*+,;="];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSString *)nonStringPercentEscapedString {

    return [self percentEscapedStringWithEscapeString:@":/?#[]@!$&’()*+;="];
}
#endif

- (NSString *)percentEscapedStringWithEscapeString:(NSString *)stringWithCharsForEscape {

    NSString *newlineEscapedString = [self stringByReplacingOccurrencesOfString:@"\n" withString:@"%5Cn"];
    newlineEscapedString = [newlineEscapedString stringByReplacingOccurrencesOfString:@"\r" withString:@"%5Cr"];
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)newlineEscapedString,
                                                                        NULL,
                                                                        (CFStringRef)stringWithCharsForEscape,
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

- (NSString *)truncatedString:(NSUInteger)length lineBreakMode:(NSLineBreakMode)lineBreakMode {

    NSString *truncatedString = self;
    if (length < self.length) {

        switch (lineBreakMode) {
                
            case NSLineBreakByTruncatingHead:
                {
                    NSUInteger index = (self.length - length);
                    if (index + 1 < self.length) {

                        index++;
                    }
                    truncatedString = [NSString stringWithFormat:@"…%@", [self substringFromIndex:index]];
                }
                break;
                
            case NSLineBreakByTruncatingMiddle:
                {
                    NSUInteger maximumHalfLength = (NSUInteger)ceilf(length * 0.5f);
                    if (maximumHalfLength == (self.length * 0.5f)) {

                        maximumHalfLength = MAX(maximumHalfLength - 2, MAX(maximumHalfLength - 1, 0));
                    }

                    truncatedString = [NSString stringWithFormat:@"%@…%@", [self substringToIndex:maximumHalfLength],
                                       [self substringFromIndex:(self.length - maximumHalfLength)]];
                }
                break;
                
            case NSLineBreakByTruncatingTail:
                {
                    NSUInteger index = length;
                    if (index - 1 > 0) {

                        index--;
                    }
                    truncatedString = [NSString stringWithFormat:@"%@…", [self substringToIndex:index]];
                }
                break;

            default:

                if (lineBreakMode != NSLineBreakByCharWrapping && lineBreakMode != NSLineBreakByWordWrapping) {
                    
                    truncatedString = [self substringToIndex:length];
                }
                break;
        }
    }
    
    
    return truncatedString;
}


#pragma mark - Cryptography methods

- (NSData *)sha256Data {

    unsigned char hashedData[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA256([data bytes], (CC_LONG)[data length], hashedData);


    return [NSData dataWithBytes:hashedData length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha256HEXString {

    return [[[self sha256Data] HEXString] lowercaseString];
}

- (NSString *)base64DecodedString {

    return [NSString stringWithUTF8String:[[NSData dataFromBase64String:self] bytes]];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSData *)md5Data {

    const char *src = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(src, strlen(src), result);


    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}
#endif

#pragma mark -

@end
