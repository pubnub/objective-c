//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//


#import "NSData+PNAdditions.h"
#include <zlib.h>


#pragma mark Static

static NSUInteger GZIPWindowBits = 47;
static NSUInteger DeflateWindowBits = -15;
static const char encodeCharTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static unsigned char decodeCharTable[256] =
{
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 62, 65, 65, 65, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 65, 65, 65, 65, 65, 65,
    65,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 65, 65, 65, 65, 65,
    65, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
};


#pragma mark - Private interface declaration

@interface NSData (PNAdditionPrivate)


#pragma mark - Instance methods

- (NSData *)inflateWithWindow:(NSUInteger)windowBits;


#pragma mark -

@end


#pragma mark - Public interface methods

@implementation NSData (PNAdditions)


#pragma mark Class methods

+ (NSData *)dataFromBase64String:(NSString *)encodedSting {

    NSData *encodedData = [encodedSting dataUsingEncoding:NSASCIIStringEncoding];
    const char *encodedDataBuffer = [encodedData bytes];
    size_t encodedDataLength = [encodedData length];
    size_t decodedDataLength = ((encodedDataLength + 4 - 1) / 4) * 3;
    unsigned char *decodedDataBuffer = (unsigned char *) malloc(decodedDataLength);

    size_t i = 0;
    size_t j = 0;
    while (i < encodedDataLength) {

        unsigned char decodedChars[4];
        size_t idx = 0;
        while (i < encodedDataLength) {

            unsigned char decodedChar = decodeCharTable[encodedDataBuffer[i++]];
            if (decodedChar != 65) {

                decodedChars[idx] = decodedChar;
                idx++;

                if (idx == 4) {

                    break;
                }
            }
        }

        if (idx >= 2) {

            decodedDataBuffer[j] = (decodedChars[0] << 2) | (decodedChars[1] >> 4);
        }
        if (idx >= 3) {

            decodedDataBuffer[j+1] = (decodedChars[1] << 4) | (decodedChars[2] >> 2);
        }
        if (idx >= 4) {

            decodedDataBuffer[j+2] = (decodedChars[2] << 6) | decodedChars[3];
        }

        j += idx-1;
    }

    decodedDataLength = j;

    NSData *decodedData = [NSData dataWithBytes:decodedDataBuffer length:decodedDataLength];
    free(decodedDataBuffer);


    return decodedData;
}


#pragma mark - Instance methods

- (unsigned long long int)unsignedLongLongFromHEXData {

    return strtoull([self bytes], NULL, 16);
}

- (NSString *)base64Encoding {

    if ([self length] == 0)
    		return @"";

        char *characters = malloc((([self length] + 2) / 3) * 4);
    	if (characters == NULL)
    		return nil;
    	NSUInteger length = 0;

    	NSUInteger i = 0;
    	while (i < [self length])
    	{
    		char buffer[3] = {0,0,0};
    		short bufferLength = 0;
    		while (bufferLength < 3 && i < [self length])
    			buffer[bufferLength++] = ((char *)[self bytes])[i++];

    		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
    		characters[length++] = encodeCharTable[(buffer[0] & 0xFC) >> 2];
    		characters[length++] = encodeCharTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
    		if (bufferLength > 1)
    			characters[length++] = encodeCharTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
    		else characters[length++] = '=';
    		if (bufferLength > 2)
    			characters[length++] = encodeCharTable[buffer[2] & 0x3F];
    		else characters[length++] = '=';
    	}


    	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (NSString *)HEXString {

    NSUInteger capacity = [self length];
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [self bytes];

    // Iterate over the bytes
    for (int i=0; i < [self length]*0.5f; ++i) {

      [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }


    return stringBuffer;
}

- (NSData *)GZIPInflate {

    return [self inflateWithWindow:GZIPWindowBits];
}

- (NSData *)inflate {

    return [self inflateWithWindow:DeflateWindowBits];
}


- (NSData *)inflateWithWindow:(NSUInteger)windowBits {

    NSData *inflatedData = nil;

    if ([self length] == 0) {

        inflatedData = self;
    }
    else {

        unsigned fullLength = [self length];
        unsigned halfLength = [self length] / 2;

        NSMutableData *decompressed = [NSMutableData dataWithLength:fullLength + halfLength];
        BOOL done = NO;
        int status;
        z_stream stream;
        stream.next_in = (Bytef *)[self bytes];
        stream.avail_in = [self length];
        stream.total_out = 0;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        if (inflateInit2(&stream, windowBits) == Z_OK) {

            while (!done) {

                // Make sure we have enough room and reset the lengths.
                if (stream.total_out >= [decompressed length]) {

                    [decompressed increaseLengthBy:halfLength];
                }
                stream.next_out = [decompressed mutableBytes] + stream.total_out;
                stream.avail_out = [decompressed length] - stream.total_out;

                // Inflate another chunk.
                status = inflate(&stream, Z_SYNC_FLUSH);

                if (status == Z_STREAM_END) {
                    done = YES;
                }
                else if (status != Z_OK) {
                    break;
                }
            }
            if (inflateEnd(&stream) == Z_OK) {

                // Set real length.
                if (done) {

                    [decompressed setLength:stream.total_out];
                    inflatedData = [NSData dataWithData:decompressed];
                }
            }
        }
    }


    return inflatedData;
}


#pragma mark - APNS

- (NSString *)HEXPushToken {

    NSUInteger capacity = [self length];
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [self bytes];

    // Iterate over the bytes
    for (int i=0; i < [self length]; i++) {

      [stringBuffer appendFormat:@"%02.2hhX", dataBuffer[i]];
    }


    return stringBuffer;
}

#pragma mark -


@end
