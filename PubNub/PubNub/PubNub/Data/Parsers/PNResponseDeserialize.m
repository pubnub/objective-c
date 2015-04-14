//
//  PNResponseDeserialize.m
//  pubnub
//
//  This class was created to help deserialize
//  responses which connection recieves over the
//  stream opened on sockets.
//  Server returns formatted HTTP headers with response
//  body which should be extracted.
//
//
//  Created by Sergey Mamontov on 12/19/12.
//
//

#import "PNResponseDeserialize.h"
#import "NSObject+PNAdditions.h"
#import "NSData+PNAdditions.h"
#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"
#import "PNPrivateMacro.h"
#import "PNResponse.h"
#import "PNHelper.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub response deserializer must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif



#pragma mark Static

static void * const kHTTPHeaderStartMarker = "HTTP/1.1";
static void * const kHTTPHeaderEndMarker = "\r\n\r\n";
static void * const kChunkedHTTPPackenEndMarker = "\r\n0\r\n\r\n";
static void * const kNewLineFeedMarker = "\r\n";

static NSString * const kPNTransferEncodingHeaderFieldName = @"Transfer-Encoding";
static NSString * const kPNChunkedTransferEncodingHeaderFieldValue = @"chunked";

static NSString * const kPNContentEncodingHeaderFieldName = @"Content-Encoding";
static NSString * const kPNGZIPCompressedContentEncodingHeaderFieldValue = @"gzip";
static NSString * const kPNDeflateCompressedContentEncodingHeaderFieldValue = @"deflate";

static NSString * const kPNContentLengthHeaderFieldName = @"Content-Length";

static NSString * const kPNConnectionTypeFieldName = @"Connection";
static NSString * const kPNCloseConnectionTypeFieldValue = @"close";


#pragma mark Private interface methods

@interface PNResponseDeserialize ()


#pragma mark - Properties

// Reflects whether deserializer still working or not
@property (nonatomic, assign, getter = isDeserializing) BOOL deserializing;


#pragma mark - Instance methods

- (BOOL)isChunkedTransfer:(NSDictionary *)httpResponseHeaders;
- (BOOL)isCompressedTransfer:(NSDictionary *)httpResponseHeaders;
- (BOOL)isGZIPCompressedTransfer:(NSDictionary *)httpResponseHeaders;
- (BOOL)isDeflateCompressedTransfer:(NSDictionary *)httpResponseHeaders;
- (BOOL)isKeepAliveConnectionType:(NSDictionary *)httpResponseHeaders;
- (NSUInteger)contentLength:(NSDictionary *)httpResponseHeaders;
- (NSString *)contentCompressionType:(NSDictionary *)httpResponseHeaders;

- (PNResponse *)responseFrom:(const void *)buffer withSize:(NSUInteger)bufferSize
           malformedResponse:(BOOL *)isMalformedResponse;

/**
 @brief      Allow to find HTTP response in specified buffer.

 @param buffer       Pointer to the buffer with data inside of which packet should be found.
 @param bufferSize   Original buffer size.

 @return \c NSNotFound in case if there is no more packets in specified buffer.

 @since 3.7.10
 */
- (NSUInteger)HTTPResponseLocationIn:(const void *)buffer withSize:(NSUInteger)bufferSize;

/**
 @brief      Allow to find next HTTP response in specified buffer.
 @discussion This method used as addition to \c -HTTPResponseLocationIn:withSize: and use it's
             output as offset in buffer to find another HTTP packet start location.

 @param buffer       Pointer to the buffer with data inside of which packet should be found.
 @param bufferSize   Original buffer size.
 @param searchOffset Used on buffer pointer to get reference on new pointer starting from which
                     search should be done.

 @return \c NSNotFound in case if there is no more packets in specified buffer.

 @since 3.7.10
 */
- (NSUInteger)nextHTTPResponseLocationIn:(const void *)buffer withSize:(NSUInteger)bufferSize
                               andOffset:(NSUInteger)searchOffset;

- (NSUInteger)HTTPHeadersEndMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize;

- (NSUInteger)chunkedHTTPPacketEndMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize;
- (BOOL)hasChunkedHTTPPacketEndMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize;
- (NSUInteger)newLineFeedMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize;

/**
 * Allow to compose response data object from chunked data using
 * octet values to determine next chunk size
 */
- (NSData *)joinedDataFromChunkedDataUsingOctets:(const void *)buffer withSize:(NSUInteger)bufferSize
                                   andJoinedSize:(NSUInteger *)joinedBufferSize;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNResponseDeserialize


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        [self pn_setupPrivateSerialQueueWithIdentifier:@"response-deserializer"
                                           andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    }
    
    
    return self;
}

- (void)parseBufferContent:(dispatch_data_t)buffer
                 withBlock:(void(^)(NSArray *responses, NSUInteger fullBufferLength,
                                    NSUInteger processedBufferLength,
                                    void(^readBufferPostProcessing)(void)))parseCompletionBlock {
    
    // "retain" passed buffer by creating sub-range from it at full size.
    // Doing to trying to prevent ARC from generating code outisde of this method which will
    // release last reference on object after which it will get deallocasted.
    dispatch_data_t retainedBuffer = dispatch_data_create_subrange(buffer, 0, dispatch_data_get_size(buffer));
    
    [self pn_dispatchBlock:^{
        
        if (!self.deserializing) {
                
            self.deserializing = YES;
            __block dispatch_data_t normalizedBuffer = dispatch_data_create(NULL, 0,
                                                                            DISPATCH_TARGET_QUEUE_DEFAULT,
                                                                            DISPATCH_DATA_DESTRUCTOR_DEFAULT);
            NSUInteger bufferSize = dispatch_data_get_size(retainedBuffer);
            __block NSUInteger processedLength = 0;
            __block NSUInteger packetsCount = 0;
            __block NSUInteger httpPacketStart = NSNotFound;
            __block NSUInteger httpPacketLength = 0;
            
            void(^captureNormalizedBuffer)(NSUInteger, NSUInteger) = ^(NSUInteger normalizedBufferOffset,
                                                                       NSUInteger normalizedBufferLength) {
                
                if (httpPacketLength > 0) {
                    
                    packetsCount++;
                    processedLength = (normalizedBufferOffset + normalizedBufferLength);
                    dispatch_data_t packetData = dispatch_data_create_subrange(retainedBuffer,
                                                                               normalizedBufferOffset,
                                                                               normalizedBufferLength);
                    dispatch_data_t mappedData = dispatch_data_create_map(packetData, NULL, NULL);
                    dispatch_data_t updatedNormalizedBuffer = dispatch_data_create_concat(normalizedBuffer, mappedData);
                    [PNDispatchHelper release:normalizedBuffer];
                    normalizedBuffer = updatedNormalizedBuffer;
                    [PNDispatchHelper release:mappedData];
                    [PNDispatchHelper release:packetData];
                }
            };
            
            __block __pn_desired_weak void(^bufferProcessingBlockWeak)(const void *, size_t, size_t);
            void(^bufferProcessingBlock)(const void *, size_t, size_t);
            bufferProcessingBlockWeak = bufferProcessingBlock = ^(const void *bytes, size_t size,
                                                                  size_t offset) {
                
                // Search for HTTP packet start location in suggested buffer.
                NSUInteger packetStartLocation = [self HTTPResponseLocationIn:bytes
                                                                     withSize:size];
                
                // Check whether packet start has been found or not.
                if (packetStartLocation != NSNotFound) {
                    
                    // Calculate real HTTP packet start location using data region offset and
                    // packet start location information.
                    NSUInteger originalPacketOffset = (offset + packetStartLocation);
                    
                    // Check whether already found packet start earlier or not.
                    if (httpPacketStart != NSNotFound) {
                        
                        // Calculate target HTTP packet size
                        httpPacketLength = originalPacketOffset - httpPacketStart;
                        if (originalPacketOffset > httpPacketStart) {
                            
                            captureNormalizedBuffer(httpPacketStart, httpPacketLength);
                        }
                        
                        // Update tracked HTTP packet information.
                        httpPacketStart = originalPacketOffset;
                    }
                    else {
                        
                        // Check whether there is a garbage from previous incomplete HTTP
                        // packet or not.
                        if (offset == 0 && packetStartLocation != 0) {
                            
                            [PNLogger logDeserializerInfoMessageFrom:self
                                             withParametersFromBlock:^NSArray * {
                                
                                return @[PNLoggerSymbols.deserializer.garbageResponseData,
                                         @(originalPacketOffset)];
                            }];
                            
                            [PNLogger storeGarbageHTTPPacketData:^dispatch_data_t {
                                
                                return dispatch_data_create_subrange(retainedBuffer, 0, bufferSize);
                            }];
                        }
                        // Looks like potentionally we have read buffer which may haave more content in next portion.
                        else {
                            
                            httpPacketStart = originalPacketOffset;
                        }
                    }
                    
                    // Search for next HTTP packet start location in suggested buffer.
                    packetStartLocation = [self nextHTTPResponseLocationIn:bytes withSize:size
                                                                 andOffset:packetStartLocation];
                    
                    // Check whether there is more HTTP packets in this buffer or not
                    if (packetStartLocation != NSNotFound) {
                        
                        if (size > packetStartLocation) {
                            
                            bufferProcessingBlockWeak(bytes + packetStartLocation,
                                                      size - packetStartLocation,
                                                      offset + packetStartLocation);
                        }
                    }
                    // Looks like there is no more HTTP packet in this buffer. Check whether HTTP packet
                    // start has been found or this is last sub-buffer.
                    else if (httpPacketStart != NSNotFound && (offset + size) == bufferSize){
                        
                        // Calculate target HTTP packet size
                        httpPacketLength = bufferSize - httpPacketStart;
                        if (bufferSize > httpPacketStart) {
                            
                            captureNormalizedBuffer(httpPacketStart, httpPacketLength);
                        }
                    }
                }
                // Check whether de-serializer found packet start in previous buffer chunk or not.
                else if (httpPacketStart != NSNotFound && (offset + size) == bufferSize) {
                    
                    // Calculate target HTTP packet size
                    httpPacketLength = bufferSize - httpPacketStart;
                    if (bufferSize > httpPacketStart) {
                        
                        captureNormalizedBuffer(httpPacketStart, httpPacketLength);
                    }
                }
            };
            
            // Iterate over chunks of data stored in buffer.
            dispatch_data_apply(retainedBuffer, ^bool(dispatch_data_t region, size_t offset,
                                                      const void *bytes, size_t size) {
                
                bufferProcessingBlock(bytes, size, offset);
                
                return true;
            });
            
            NSMutableArray *parsedResponses = [NSMutableArray new];
            NSUInteger normalizedBufferSize = dispatch_data_get_size(normalizedBuffer);
            if (bufferSize > 0) {
                
                // Check whether at least one HTTP packet has been found in provided buffer.
                if(normalizedBufferSize > 0) {
                    
                    void(^malformedResponseParseErrorHandler)(void const *, NSUInteger) = ^(void const *malformedBuffer, NSUInteger malformedBufferSize) {
                        
                        [PNLogger logDeserializerErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            NSString *encodedContent = [[NSString alloc] initWithBytes:malformedBuffer
                                                                                length:malformedBufferSize encoding:NSUTF8StringEncoding];
                            if (!encodedContent) {
                                
                                encodedContent = [[NSString alloc] initWithBytes:malformedBuffer
                                                                          length:malformedBufferSize encoding:NSASCIIStringEncoding];
                                
                                if (!encodedContent) {
                                    
                                    encodedContent = @"Binary data (can't be stringified)";
                                }
                            }
                            
                            return @[PNLoggerSymbols.deserializer.unableToEncodeResponseData,
                                     @(malformedBufferSize),
                                     (encodedContent ? encodedContent : [NSNull null])];
                        }];
                    };
                    
                    dispatch_data_apply(normalizedBuffer, ^bool(dispatch_data_t region, size_t offset,
                                                                void const *bytes, size_t size) {
                        
                        BOOL malformedResponse;
                        PNResponse *response = [self responseFrom:bytes withSize:size
                                                malformedResponse:&malformedResponse];
                        if (response) {
                            
                            [parsedResponses addObject:response];
                        }
                        else {
                            
                            if (packetsCount == 1 || (offset + size) == normalizedBufferSize) {
                                
                                if (malformedResponse) {
                                    
                                    malformedResponseParseErrorHandler(bytes, size);
                                }
                                else {
                                    
                                    if (processedLength >= size) {
                                        
                                        processedLength -= size;
                                    }
                                }
                            }
                            else {
                                
                                [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray * {
                                    
                                    return @[PNLoggerSymbols.deserializer.garbageResponseData,
                                             @(size)];
                                }];
                                
                                [PNLogger storeGarbageHTTPPacketData:^dispatch_data_t {
                                    
                                    return dispatch_data_create_subrange(retainedBuffer, 0, bufferSize);
                                }];
                            }
                        }
                        
                        
                        return true;
                    });
                }
                else {
                    
                    [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray * {
                        
                        return @[PNLoggerSymbols.deserializer.garbageResponseData,
                                 @(bufferSize)];
                    }];
                    
                    processedLength = bufferSize;
                    [PNLogger storeGarbageHTTPPacketData:^dispatch_data_t {
                        
                        return dispatch_data_create_subrange(retainedBuffer, 0, bufferSize);
                    }];
                }
            }
            
            [PNDispatchHelper release:retainedBuffer];
            parseCompletionBlock([parsedResponses copy], bufferSize, processedLength, ^{
                
                [self pn_dispatchBlock:^{
                    
                    self.deserializing = NO;
                }];
            });
        }
        else {
            
            [PNDispatchHelper release:retainedBuffer];
        }
    }];
}

- (BOOL)isChunkedTransfer:(NSDictionary *)httpResponseHeaders {

    NSString *transferEncoding = [httpResponseHeaders objectForKey:kPNTransferEncodingHeaderFieldName];
    NSComparisonResult result = [transferEncoding caseInsensitiveCompare:kPNChunkedTransferEncodingHeaderFieldValue];


    return transferEncoding && result == NSOrderedSame;
}

- (BOOL)isCompressedTransfer:(NSDictionary *)httpResponseHeaders {

    return [self isGZIPCompressedTransfer:httpResponseHeaders] || [self isDeflateCompressedTransfer:httpResponseHeaders];
}

- (BOOL)isGZIPCompressedTransfer:(NSDictionary *)httpResponseHeaders {

    NSString *contentEncoding = [self contentCompressionType:httpResponseHeaders];
    NSComparisonResult result = [contentEncoding caseInsensitiveCompare:kPNGZIPCompressedContentEncodingHeaderFieldValue];


    return contentEncoding && result == NSOrderedSame;
}

- (BOOL)isDeflateCompressedTransfer:(NSDictionary *)httpResponseHeaders {

    NSString *contentEncoding = [self contentCompressionType:httpResponseHeaders];
    NSComparisonResult result = [contentEncoding caseInsensitiveCompare:kPNDeflateCompressedContentEncodingHeaderFieldValue];


    return contentEncoding && result == NSOrderedSame;
}

- (BOOL)isKeepAliveConnectionType:(NSDictionary *)httpResponseHeaders {

    NSString *connectionType = [httpResponseHeaders objectForKey:kPNConnectionTypeFieldName];
    NSComparisonResult result = [connectionType caseInsensitiveCompare:kPNCloseConnectionTypeFieldValue];


    return connectionType && result != NSOrderedSame;
}

- (NSUInteger)contentLength:(NSDictionary *)httpResponseHeaders {

    NSString *contentLength = [httpResponseHeaders objectForKey:kPNContentLengthHeaderFieldName];
    NSUInteger length = 0;
    if (contentLength && ![contentLength isEqualToString:@"0"]) {

        length = strtoul([contentLength UTF8String], NULL, 10);
    }


    return length;
}

- (NSString *)contentCompressionType:(NSDictionary *)httpResponseHeaders {

    return [httpResponseHeaders objectForKey:kPNContentEncodingHeaderFieldName];
}

- (PNResponse *)responseFrom:(const void *)buffer withSize:(NSUInteger)bufferSize
           malformedResponse:(BOOL *)isMalformedResponse {

    // Mark that request is incomplete because from the start we don't know for sure
    // (also this make code cleaner)
    *isMalformedResponse = YES;
    PNResponse *response = nil;

    CFHTTPMessageRef message = NULL;
    NSUInteger httpHeadersEndMarkerLocation = [self HTTPHeadersEndMarkerIn:buffer withSize:bufferSize];
    NSUInteger responseBodyOffset = 0;
    if (httpHeadersEndMarkerLocation != NSNotFound && bufferSize >= httpHeadersEndMarkerLocation) {

        responseBodyOffset = (httpHeadersEndMarkerLocation + strlen(kHTTPHeaderEndMarker));

        // Appending only portion of bytes which contains reference on all passed with response
        // HTTP headers which will be used during body processing.
        message = CFHTTPMessageCreateEmpty(NULL, FALSE);
        CFHTTPMessageAppendBytes(message, buffer, (CFIndex)responseBodyOffset);
    }

    if (message) {

        // Ensure that all headers has been received.
        if (CFHTTPMessageIsHeaderComplete(message)) {

            // Fetch HTTP headers from response
            NSDictionary *headers = CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(message));

            // Fetch HTTP status code from response
            NSInteger statusCode = CFHTTPMessageGetResponseStatusCode(message);


            // Check whether response is chunked or not
            BOOL isResponseChunked = [self isChunkedTransfer:headers];

            // Check whether response is archived or not
            BOOL isResponseCompressed = [self isCompressedTransfer:headers];

            // Check whether server want to close connection right after this response or keep it alive
            BOOL isKeepAliveConnection = [self isKeepAliveConnectionType:headers];

            // Retrieve response body length (from header field)
            NSUInteger contentLength = [self contentLength:headers];

            if (!isResponseChunked || [self hasChunkedHTTPPacketEndMarkerIn:buffer withSize:bufferSize]) {

                // Retrieve pointer on actual message body (all headers stripped from it).
                const void *responseBody = (buffer + responseBodyOffset);
                NSUInteger contentSize = (bufferSize > responseBodyOffset ? (bufferSize - responseBodyOffset) : 0);

                if ((contentLength > 0 && contentSize > 0) || contentSize > 0) {

                    if (statusCode != 200 && !(statusCode >= 401 && statusCode <= 503)) {

                        [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                            NSString *encodedContent = [[NSString alloc] initWithBytes:buffer
                                                        length:bufferSize encoding:NSASCIIStringEncoding];

                            return @[PNLoggerSymbols.deserializer.unexpectedResponseStatusCode,
                                    @(statusCode), (encodedContent ? encodedContent : [NSNull null])];
                        }];

                        // In case if response arrived with unexpected code, store it for future research.
                        [PNLogger storeUnexpectedHTTPDescription:nil packetData:^NSData *{

                            return [[NSData alloc] initWithBytes:buffer length:bufferSize];
                        }];
                    }

                    // Check whether there provided content is larger than declared by
                    // 'Content-Length' or not
                    if (!isResponseChunked && contentSize > contentLength && contentLength > 0) {

                        // Looks like there is an extra data at the end of parsed response which
                        // should be truncated to the correct size
                        contentSize = contentLength;
                    }

                    // Real content can be larger then specified in 'Content-Length' and it will be
                    // truncated during processing step.
                    BOOL isFullBody = (contentSize == contentLength);

                    if (isResponseChunked) {

                        NSUInteger packetEndLocation = [self chunkedHTTPPacketEndMarkerIn:buffer
                                                                                 withSize:bufferSize];

                        isFullBody = (packetEndLocation != NSNotFound);
                        if (isFullBody) {

                            // Calculate new useful body content size. This will allow to truncate
                            // and data which has been appended by server aside from declared
                            // chinked content.
                            contentSize = (packetEndLocation + strlen(kChunkedHTTPPackenEndMarker));
                        }
                    }

                    if (isFullBody) {

                        NSData *preparedData = nil;
                        if (isResponseChunked) {

                            NSUInteger joinedSize;
                            NSData *joinedData = [self joinedDataFromChunkedDataUsingOctets:responseBody
                                                                                   withSize:contentSize
                                                                              andJoinedSize:&joinedSize];
                            if (joinedData) {
                                
                                preparedData = [joinedData copy];
                            }
                            contentSize = joinedSize;
                        }
                        else {

                            preparedData = [[NSData alloc] initWithBytes:responseBody
                                                                  length:contentSize];
                        }

                        if (isResponseCompressed) {

                            NSData *extractedData;
                            NSUInteger extractedSize;
                            if ([self isGZIPCompressedTransfer:headers]) {
                                
                                extractedData = pn_GZIPInflate(preparedData.bytes, contentSize, &extractedSize);
                            }
                            else {

                                extractedData = pn_inflate(preparedData.bytes, contentSize, &extractedSize);
                            }
                            
                            contentSize = extractedSize;
                            preparedData = [[NSData alloc] initWithData:extractedData];
                        }
                        *isMalformedResponse = (contentSize == 0);


                        [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                            NSString *rawData = [[NSString alloc] initWithBytes:preparedData.bytes
                                                 length:contentSize encoding:NSUTF8StringEncoding];

                            return @[PNLoggerSymbols.deserializer.rawResponseData, @(statusCode),
                                    (rawData ? rawData : [NSNull null])];
                        }];
                        response = [PNResponse responseWithContent:preparedData
                                                              size:contentSize code:statusCode
                                          lastResponseOnConnection:!isKeepAliveConnection];
                    }
                }
            }
            else {

                *isMalformedResponse = !isResponseChunked;
            }
        }
        CFRelease(message);
    }
    

    return response;
}

- (NSData *)joinedDataFromChunkedDataUsingOctets:(const void *)buffer withSize:(NSUInteger)bufferSize
                                   andJoinedSize:(NSUInteger *)joinedBufferSize {
    
    NSMutableData *joinedData = [NSMutableData new];
    BOOL parsingChunkOctet = YES;
    BOOL parsingChunk = NO;
    NSUInteger chunkStart = 0;
    NSUInteger chunkSize = 0;

    NSUInteger cursorLocation = [self newLineFeedMarkerIn:buffer withSize:bufferSize];

    while (cursorLocation != NSNotFound && (parsingChunkOctet || parsingChunk)) {

        if (parsingChunkOctet) {
            
            // Get size of the chunk with data
            chunkSize = strtoul(buffer + chunkStart, NULL, 16);
            parsingChunkOctet = NO;
            parsingChunk = (chunkSize > 0);
            
            // Adjust chunk start position to the end of chunk size line feed
            chunkStart = cursorLocation + strlen(kNewLineFeedMarker);

            // Check whether octet report that next chunk of data will
            // be zero length or not
            if (chunkSize == 0 || chunkSize >= INT_MAX || chunkSize == INT_MIN) {

                break;
            }
        }

        if (parsingChunk) {

            if (chunkStart + chunkSize <= bufferSize) {

                [joinedData appendBytes:(buffer + chunkStart) length:chunkSize];
                parsingChunk = NO;

                // Adjust chunk start position to the end of chunk size line feed.
                // New line feed has been added, because each chunk of data end up with new line
                // feed not counted in chunk size.
                chunkStart += (chunkSize + strlen(kNewLineFeedMarker));

                if (bufferSize > chunkStart) {

                    parsingChunkOctet = YES;
                    cursorLocation = [self newLineFeedMarkerIn:(buffer + chunkStart)
                                                      withSize:(bufferSize - chunkStart)];
                    if (cursorLocation != NSNotFound) {
                        
                        cursorLocation += chunkStart;
                    }
                }
            }
        }
    }

    *joinedBufferSize = joinedData.length;


    return joinedData;
}

- (NSUInteger)HTTPResponseLocationIn:(const void *)buffer withSize:(NSUInteger)bufferSize {

    return pn_str_location(buffer, bufferSize, 0, kHTTPHeaderStartMarker);
}

- (NSUInteger)nextHTTPResponseLocationIn:(const void *)buffer withSize:(NSUInteger)bufferSize
                               andOffset:(NSUInteger)searchOffset {

    NSUInteger location = NSNotFound;
    if (searchOffset != NSNotFound) {

        searchOffset++;
        if (bufferSize > searchOffset) {

            location = pn_str_location(buffer + searchOffset, bufferSize - searchOffset, 0,
                                       kHTTPHeaderStartMarker);
        }
    }

    return location;
}

- (NSUInteger)HTTPHeadersEndMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize {

    return pn_str_location(buffer, bufferSize, 0, kHTTPHeaderEndMarker);
}

- (NSUInteger)chunkedHTTPPacketEndMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize {

    return pn_str_location(buffer, bufferSize, 0, kChunkedHTTPPackenEndMarker);
}

- (BOOL)hasChunkedHTTPPacketEndMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize {

    return [self chunkedHTTPPacketEndMarkerIn:buffer withSize:bufferSize] != NSNotFound;
}

- (NSUInteger)newLineFeedMarkerIn:(const void *)buffer withSize:(NSUInteger)bufferSize {

    return pn_str_location(buffer, bufferSize, 0, kNewLineFeedMarker);
}

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];
}

#pragma mark -


@end
