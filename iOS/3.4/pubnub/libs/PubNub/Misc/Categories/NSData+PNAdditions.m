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

static const char charTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


#pragma mark - Public interface methods

@implementation NSData (PNAdditions)


#pragma mark - Instance methods

- (unsigned long long int)unsignedLongLongFromHEXData {

    return strtoull([self bytes], NULL, 16);;
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
    		characters[length++] = charTable[(buffer[0] & 0xFC) >> 2];
    		characters[length++] = charTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
    		if (bufferLength > 1)
    			characters[length++] = charTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
    		else characters[length++] = '=';
    		if (bufferLength > 2)
    			characters[length++] = charTable[buffer[2] & 0x3F];
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

      [stringBuffer appendFormat:@"%02X", (NSUInteger)dataBuffer[i]];
    }


    return stringBuffer;
}

- (NSData *)GZIPInflate {

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
        if (inflateInit2(&stream, (15 + 32)) == Z_OK) {

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

#pragma mark -


@end