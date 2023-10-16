#import "PNLegacyCryptor.h"
#import "PNAESCBCCryptor+Private.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>


#pragma mark Contants

/// Null cryptor identifier for legacy cryptors.
extern NSData *kPNCryptorLegacyIdentifier;


#pragma mark - Interface implementation

@implementation PNLegacyCryptor


#pragma mark - Information

- (NSData *)identifier {
    return kPNCryptorLegacyIdentifier;
}


#pragma mark - Initialization and configuration

+ (instancetype)cryptorWithCipherKey:(NSString *)cipherKey
            randomInitializationVector:(BOOL)useRandomInitializationVector {
    return [[self alloc] initWithCipherKey:cipherKey randomInitializationVector:useRandomInitializationVector];
}


#pragma mark - Helpers

- (NSData *)digestForKey:(NSString *)key {
    NSMutableString *stringBuffer = [[NSMutableString alloc] initWithCapacity:CC_SHA256_DIGEST_LENGTH];
    unsigned char *digest = (unsigned char *)[super digestForKey:key].bytes;
    
    for (int i=0; i < CC_SHA256_DIGEST_LENGTH * 0.5f; ++i) {
        [stringBuffer appendFormat:@"%02x", digest[i]];
    }
    
    return [stringBuffer dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -


@end
