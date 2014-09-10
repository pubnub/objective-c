//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//


#import "NSData+PNAdditions.h"
#include <zlib.h>


// ARC check
#if !__has_feature(objc_arc)
#error PubNub data category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Structures

/**
 This enumerator represents possible GZIP operation
 */
typedef NS_OPTIONS(NSInteger , GZIPOperations) {
    
    /**
     Decompress \b NSData instance content using GZIP and \c inflate algorithm.
     */
    GZIPDecompressInflateOperation,
    
    /**
     Decompress \b NSData instance content using GZIP and simplified \c inflate algorithm.
     */
    DecompressInflateOperation,
    
    /**
     Compress \b NSData instance content using GZIP and \c deflate algorithm.
     */
    GZIPCompressDeflateOperation
};


#pragma mark - Static

static BOOL GZIPDeflateCompressionAlgorithmEnabled = NO;
static NSUInteger GZIPDeflateChunkSize = 1024;
static NSUInteger GZIPDeflateWindowBits = 31;
static NSUInteger GZIPInflateWindowBits = 47;
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

- (NSData *)pn_dataUsingGZIPOperation:(GZIPOperations)operation;


#pragma mark -

@end


#pragma mark - Public interface methods

@implementation NSData (PNAdditions)


#pragma mark Class methods

+ (NSData *)pn_dataFromBase64String:(NSString *)encodedSting {

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

- (unsigned long long int)pn_unsignedLongLongFromHEXData {

    return strtoull([self bytes], NULL, 16);
}

- (NSString *)pn_base64Encoding {

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

- (NSString *)pn_HEXString {

    NSUInteger capacity = [self length];
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [self bytes];

    // Iterate over the bytes
    for (int i=0; i < [self length]*0.5f; ++i) {

      [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }


    return stringBuffer;
}


#pragma mark - Compression / Decompression methods

- (NSData *)pn_GZIPDeflate {
    
    return [self pn_dataUsingGZIPOperation:GZIPCompressDeflateOperation];
}

- (NSData *)pn_GZIPInflate {
    
    return [self pn_dataUsingGZIPOperation:GZIPDecompressInflateOperation];
}

- (NSData *)pn_inflate {
    
    return [self pn_dataUsingGZIPOperation:DecompressInflateOperation];
}

- (NSData *)pn_dataUsingGZIPOperation:(GZIPOperations)operation {
    
    NSData *processedData = nil;
    NSUInteger window = operation == GZIPDecompressInflateOperation ? GZIPInflateWindowBits : (operation == GZIPCompressDeflateOperation ? GZIPDeflateWindowBits : DeflateWindowBits);
    if ([self length] == 0) {
        
        processedData = self;
    }
    else {
        
        NSMutableData *processedDataStorage = nil;
        BOOL done = NO;
        int status;
        z_stream stream;
        bzero(&stream, sizeof(stream));
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        stream.next_in = (Bytef *)[self bytes];
        stream.avail_in = (uint)[self length];
        stream.total_out = 0;
        
        NSUInteger fullLength = [self length];
        NSUInteger halfLength = fullLength * 0.5f;
        
        if (operation != GZIPCompressDeflateOperation) {
            
            status = inflateInit2(&stream, window);
        }
        else {
            
            if (GZIPDeflateCompressionAlgorithmEnabled) {
                
                status = deflateInit(&stream, Z_DEFAULT_COMPRESSION);
            }
            else {
                
                status = deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, window, 8, Z_DEFAULT_STRATEGY);
            }
        }
        
        if (status == Z_OK) {
            
            BOOL isOperationCompleted = NO;
            processedDataStorage = [NSMutableData dataWithLength:(operation != GZIPCompressDeflateOperation ? fullLength : GZIPDeflateChunkSize)];
            
            while (!isOperationCompleted) {
                
                // Make sure we have enough room and reset the lengths.
                if ((status == Z_BUF_ERROR)  || stream.total_out >= [processedDataStorage length]) {
                    
                    [processedDataStorage increaseLengthBy:(operation != GZIPCompressDeflateOperation ? halfLength : GZIPDeflateChunkSize)];
                }
                stream.next_out = (Bytef*)[processedDataStorage mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)([processedDataStorage length] - stream.total_out);
                
                if (operation != GZIPCompressDeflateOperation) {
                    
                    // Inflate another chunk.
                    status = inflate(&stream, Z_SYNC_FLUSH);
                    isOperationCompleted = (stream.avail_in == 0);
                }
                else {
                    
                    // Deflate another chunk
                    status = deflate(&stream, Z_FINISH);
                    isOperationCompleted = ((status != Z_OK) && (status != Z_BUF_ERROR));
                }
            }
            
            if (operation != GZIPCompressDeflateOperation) {
                
                done = (status == Z_STREAM_END);
                status = inflateEnd(&stream);
            }
            else {
                
                status = deflateEnd(&stream);
                done = (status == Z_OK || status == Z_STREAM_END);
            }
            
            if (status == Z_OK) {
                
                // Set real length.
                if (done) {
                    
                    [processedDataStorage setLength:stream.total_out];
                    processedData = [NSData dataWithData:processedDataStorage];
                }
            }
        }
    }
    
    
    return processedData;
}


#pragma mark - APNS

- (NSString *)pn_HEXPushToken {

    NSUInteger capacity = [self length];
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [self bytes];

    // Iterate over the bytes
    for (int i=0; i < [self length]; i++) {

      [stringBuffer appendFormat:@"%02.2hhX", dataBuffer[i]];
    }


    return stringBuffer;
}

- (NSString *)logDescription {
    
    return [NSString stringWithFormat:@"<%@>", [self pn_HEXPushToken]];
}

#pragma mark -


@end
