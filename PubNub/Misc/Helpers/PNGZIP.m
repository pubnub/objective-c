/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNGZIP.h"
#import <zlib.h>


#pragma mark Interface implementation

@implementation PNGZIP


#pragma mark - Compression

+ (NSData *)GZIPDeflatedData:(NSData *)data {

    NSMutableData *processedDataStorage = nil;
    NSUInteger window = 31;
    if (data.length > 0) {

        BOOL done = NO;
        int status;
        z_stream stream;
        bzero(&stream, sizeof(stream));
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        stream.next_in = (Bytef *)data.bytes;
        stream.avail_in = (uint)data.length;
        stream.total_out = 0;
        status = deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, window, 8, Z_DEFAULT_STRATEGY);

        if (status == Z_OK) {

            BOOL isOperationCompleted = NO;
            processedDataStorage = [[NSMutableData alloc] initWithLength:1024];

            while (!isOperationCompleted) {

                // Make sure we have enough room and reset the lengths.
                if ((status == Z_BUF_ERROR)  || stream.total_out >= processedDataStorage.length) {

                    [processedDataStorage increaseLengthBy:1024];
                }
                stream.next_out = (Bytef*)processedDataStorage.mutableBytes + stream.total_out;
                stream.avail_out = (uInt)(processedDataStorage.length - stream.total_out);

                // Deflate another chunk
                status = deflate(&stream, Z_FINISH);
                isOperationCompleted = ((status != Z_OK) && (status != Z_BUF_ERROR));
            }

            status = deflateEnd(&stream);
            done = (status == Z_OK || status == Z_STREAM_END);

            if (status == Z_OK) {

                // Set real length.
                if (done) { [processedDataStorage setLength:stream.total_out]; }
            }
        }
    }

    return (processedDataStorage.length ? processedDataStorage : nil);
}


#pragma mark -


@end
