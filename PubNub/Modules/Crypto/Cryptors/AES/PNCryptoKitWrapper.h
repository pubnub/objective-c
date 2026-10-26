// Stable Objective-C declaration for the Swift CryptoKit implementation.
// Keep the selector synchronized with @objc(...) in PNCryptoKitWrapper.swift.
// Unlike a generated -Swift.h, this header is available to SwiftPM C-family targets.
#ifndef PN_CRYPTO_KIT_WRAPPER_H
#define PN_CRYPTO_KIT_WRAPPER_H
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface PNCryptoKitWrapper : NSObject
+ (nullable NSData *)decryptWithKey:(NSData *)key
                              nonce:(NSData *)nonce
                                tag:(NSData *)tag
                         ciphertext:(NSData *)ciphertext
                              error:(NSError * _Nullable * _Nullable)error;
@end
NS_ASSUME_NONNULL_END
#endif
