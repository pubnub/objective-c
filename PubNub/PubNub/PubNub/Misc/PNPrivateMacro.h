//
//  PNPrivateMacro.h
//  PubNub
//
//  Created by Sergey Mamontov on 3/12/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <zlib.h>


#ifndef PNPrivateMacro_h
#define PNPrivateMacro_h 1


#pragma mark Structures

/**
This enumerator represents possible GZIP operation
*/
typedef NS_OPTIONS(NSInteger , GZIPOperations) {

    /**
     @brief Decompress \b NSData instance content using GZIP and \c inflate algorithm.
     */
    GZIPDecompressInflateOperation,

    /**
     @brief Decompress \b NSData instance content using GZIP and simplified \c inflate algorithm.
     */
    DecompressInflateOperation,

    /**
     @brief Compress \b NSData instance content using GZIP and \c deflate algorithm.
     */
    GZIPCompressDeflateOperation
};


#pragma mark - Static

static BOOL GZIPDeflateCompressionAlgorithmEnabled = NO;
static NSUInteger GZIPDeflateChunkSize = 1024;
static NSUInteger GZIPDeflateWindowBits = 31;
static NSUInteger GZIPInflateWindowBits = 47;
static NSUInteger DeflateWindowBits = -15;


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"


#pragma mark - C helpers

static NSUInteger pn_str_location(const void* buffer, NSUInteger size, NSUInteger offset,
                                  const void *needle);
NSUInteger pn_str_location(const void* buffer, NSUInteger size, NSUInteger offset,
                           const void *needle) {
    
    NSUInteger location = NSNotFound;
    
    // Use strlen to calculate length of the string before \0 (strlen stop size calculation if it
    // find \0 in target string).
    size_t countableBufferLength = strlen(buffer);
    bool containNullTermination = (countableBufferLength < size);
    const void *needlePointer = strstr(buffer, needle);
    if (needlePointer) {
        
        location = (needlePointer - buffer) + offset;
    }
    else if (containNullTermination) {
        
        NSUInteger currentChunkSize = (countableBufferLength + 1);
        location = pn_str_location((buffer + currentChunkSize), (size - currentChunkSize),
                                   (offset + currentChunkSize), needle);
    }
    
    
    return location;
}


#pragma mark - GZIP helpers

static const void* pn_bufferUsingGZIPOperation(GZIPOperations operation, const void* buffer,
                                               NSUInteger size, NSUInteger *extractedSize);
static const void* pn_GZIPDeflate(const void* buffer, NSUInteger size, NSUInteger *extractedSize);
static const void* pn_GZIPInflate(const void* buffer, NSUInteger size, NSUInteger *extractedSize);
static const void* pn_inflate(const void* buffer, NSUInteger size, NSUInteger *extractedSize);

const void* pn_GZIPDeflate(const void* buffer, NSUInteger size, NSUInteger *extractedSize) {

    return pn_bufferUsingGZIPOperation(GZIPCompressDeflateOperation, buffer, size, extractedSize);
}

const void* pn_GZIPInflate(const void* buffer, NSUInteger size, NSUInteger *extractedSize) {

    return pn_bufferUsingGZIPOperation(GZIPDecompressInflateOperation, buffer, size, extractedSize);
}

const void* pn_inflate(const void* buffer, NSUInteger size, NSUInteger *extractedSize) {

    return pn_bufferUsingGZIPOperation(DecompressInflateOperation, buffer, size, extractedSize);
}

const void* pn_bufferUsingGZIPOperation(GZIPOperations operation, const void* buffer,
                                        NSUInteger size, NSUInteger *extractedSize) {

    NSMutableData *processedDataStorage = nil;
    NSUInteger window = (operation == GZIPDecompressInflateOperation ? GZIPInflateWindowBits :
                         (operation == GZIPCompressDeflateOperation ? GZIPDeflateWindowBits : DeflateWindowBits));
    if (size > 0) {
        
        BOOL done = NO;
        int status;
        z_stream stream;
        bzero(&stream, sizeof(stream));
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        stream.next_in = (Bytef *)buffer;
        stream.avail_in = (uint)size;
        stream.total_out = 0;
        

        NSUInteger fullLength = size;
        NSUInteger halfLength = (NSUInteger)(fullLength * 0.5f);

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
                }
            }
        }
    }

    if (processedDataStorage) {

        *extractedSize = processedDataStorage.length;
    }


    return (processedDataStorage ? processedDataStorage.bytes : buffer);
}


#pragma clang diagnostic pop


#endif // PNPrivateMacro_h
