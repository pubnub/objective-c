/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNData.h"


#pragma mark Interface implementation

@implementation PNData


#pragma mark - Convertion

+ (NSString *)HEXFrom:(NSData *)data {
    
    NSMutableString *stringBuffer = [[NSMutableString alloc] initWithCapacity:data.length];
    const unsigned char *dataBuffer = data.bytes;
    
    // Iterate over the bytes
    for (int i=0; i < data.length * 0.5f; ++i) {
        
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    
    return [stringBuffer copy];
}

+ (NSString *)HEXFromDevicePushToken:(NSData *)data {
    
    NSUInteger capacity = data.length;
    NSMutableString *stringBuffer = [[NSMutableString alloc] initWithCapacity:capacity];
    const unsigned char *dataBuffer = data.bytes;
    
    // Iterate over the bytes
    for (NSUInteger i=0; i < data.length; i++) {
        
        [stringBuffer appendFormat:@"%02.2hhX", dataBuffer[i]];
    }
    
    return [stringBuffer copy];
}

+ (NSString *)base64StringFrom:(NSData *)data {
    
    return [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
}

#pragma mark -


@end
