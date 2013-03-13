//
//  main.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "NSString+PNAddition.h"

NSString* PNEncryptMessage(NSArray *message, NSArray *key, NSArray *initVector) {
    
    return nil;
}

unichar* PNExpandedKey(unichar *key) {
    
    unichar result[4];
    int j = 8;
    int e = 14;
    int f[(j-1)];
    int d;
    for (d = 0; d < j; d++) {
        
        int q[4] = {key[4*d], key[4*d+1], key[4*d+2], key[4*d+3]};
        f[d] = q;
        for (d = j; d < 4*(e+1); d++) {
//            f[d] = [];
        }
    }
    
    return result;
}

int main(int argc, char *argv[])
{
    @autoreleasepool {

        /*
        // plaintext, key and iv as byte arrays
        key = expandKey(key);
        var numBlocks = Math.ceil(plaintext.length / 16),
        blocks = [],
        i,
        cipherBlocks = [];
        for (i = 0; i < numBlocks; i++) {
            blocks[i] = padBlock(plaintext.slice(i * 16, i * 16 + 16));
        }
        if (plaintext.length % 16 === 0) {
            blocks.push([16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16]);
            // CBC OpenSSL padding scheme
            numBlocks++;
        }
        for (i = 0; i < blocks.length; i++) {
            blocks[i] = (i === 0) ? xorBlocks(blocks[i], iv) : xorBlocks(blocks[i], cipherBlocks[i - 1]);
            cipherBlocks[i] = encryptBlock(blocks[i], key);
        }
        return cipherBlocks;
         */

        // Prepare input information
        NSString *inputData = @"\"Pubnub Messaging API 1\"";
//        inputData = [inputData ASCIIHEXString];
        size_t inputDataLength = [inputData length];
        char const *inputDataBuffer = [inputData cStringUsingEncoding:NSASCIIStringEncoding];
        NSLog(@"J (DATA): %s", inputDataBuffer);
        //NSASCIIStringEncoding

        // Prepare output information
        size_t outputDataLength = (inputDataLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
        char outputBuffer[outputDataLength];
        bzero( outputBuffer, sizeof( outputBuffer ) );

//        unichar *expandedKey = PNExpandedKey([[@"enigma" sha256HEXString] ASCIIArray]);
//        NSString *key = [[@"enigma" sha256HEXString] NSASCIIStringEncoding];
        NSString *key = [[@"enigma" sha256HEXString] ASCIIHEXString];
        
        size_t numberOfEncryptedBytes = 0;
        NSLog(@"AES256 KEY: %@", key);
        
        char keyPointer[kCCKeySizeAES256];
        bzero( keyPointer, sizeof( keyPointer ) );
        [@"enigma" getCString:keyPointer maxLength:sizeof( keyPointer ) encoding:NSASCIIStringEncoding];
        NSLog(@"--> %d", sizeof( keyPointer ));
//        char const *keyPointer = [key cStringUsingEncoding:NSUTF8StringEncoding];
//        char const *initVector = [[@"0123456789012345" ASCIIHEXString] cStringUsingEncoding:NSASCIIStringEncoding];
//        char const *initVector = [@"0123456789012345" cStringUsingEncoding:NSASCIIStringEncoding];
        char const *initVector = [[@"0123456789012345" ASCIIString] cStringUsingEncoding:NSASCIIStringEncoding];
        NSLog(@"V (KEY) --> %s (%@)", keyPointer, [[NSString alloc] initWithBytes:keyPointer length:sizeof( keyPointer ) encoding:NSASCIIStringEncoding]);
        NSLog(@"J (IV) --> %s", initVector);

        // 127,141,169,33,7,22,103,220,219,77,177,252,115,34,240,7,32,255,26,203,226,56,77,47,113,17,8,17,83,192,69,29
        
//        CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, <#CCOptions options#>, <#const void *key#>, <#size_t keyLength#>, <#const void *iv#>, <#CCCryptorRef *cryptorRef#>)
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                              kCCAlgorithmAES128,
                                              (CCOptions)kCCOptionPKCS7Padding,
                                              keyPointer,
                                              kCCKeySizeAES256,
                                              initVector,
                                              inputDataBuffer,
                                              inputDataLength,
                                              outputBuffer,
                                              outputDataLength,
                                              &numberOfEncryptedBytes);
        NSLog(@"CRYPT STATUS: %d (encrypted bytes count: %zd)", cryptStatus, numberOfEncryptedBytes);
        NSData *encryptedData = [NSData dataWithBytes:outputBuffer length:numberOfEncryptedBytes];
        NSLog(@"PLAIN --> %s", outputBuffer);
        NSLog(@"DATA --> %@", encryptedData);
        NSLog(@"DATA(HEX) --> %@", [encryptedData HEXString]);
        NSLog(@"DATA(HEX+ASCI) --> %@", [[encryptedData HEXString] ASCIIString]);
        NSLog(@"BASE64 --> %@", [encryptedData base64Encoding]);

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PNAppDelegate class]));
    }
}