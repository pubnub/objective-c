/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNString.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>


#pragma mark Interface implementation

@implementation PNString


#pragma mark - Encoding

+ (NSString *)percentEscapedString:(NSString *)string {
    
    // Wrapping non-string object (it can be passed from dictionary and compiler at run-time won't
    // notify about different data types.
    if (![string respondsToSelector:@selector(length)]) {
        
        string = [NSString stringWithFormat:@"%@", string];
    }

    // Escape unallowed characters
    NSString *escapedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                (__bridge CFStringRef)string, NULL,
                                                (__bridge CFStringRef)@":/?#[]@!$&’()*+,;=",
                                                kCFStringEncodingUTF8));
    NSString *newlineEscapedString = [escapedString stringByReplacingOccurrencesOfString:@"%0A"
                                                                    withString:@"%5Cn"];
    newlineEscapedString = [newlineEscapedString stringByReplacingOccurrencesOfString:@"%0D"
                                                                           withString:@"%5Cr"];
    
    return [newlineEscapedString copy];
}


#pragma mark - Convertion

+ (NSData *)UTF8DataFrom:(NSString *)string {
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)bas64DataFrom:(NSString *)string {
    
    return [[NSData alloc] initWithBase64EncodedString:string
                                               options:(NSDataBase64DecodingOptions)0];
}


#pragma mark - Hashing

+ (NSData *)SHA256DataFrom:(NSString *)string {
    
    unsigned char hashedData[CC_SHA256_DIGEST_LENGTH];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA256([data bytes], (CC_LONG)[data length], hashedData);
    
    return [[NSData alloc] initWithBytes:hashedData length:CC_SHA256_DIGEST_LENGTH];
}

#pragma mark -


@end
