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

static NSString * const kHTTPHeaderStartMarker = @"HTTP/1.1";
static NSString * const kHTTPHeaderEndMarker = @"\r\n\r\n";
static NSString * const kChunkedHTTPPacketEndMarker = @"\r\n0\r\n\r\n";
static NSString * const kNewLineFeedMarker = @"\r\n";

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

- (PNResponse *)responseFrom:(NSData *)buffer withRange:(NSRange)bufferRange
           malformedResponse:(BOOL *)isMalformedResponse;

/**
 @brief      Allow to find HTTP response in specified buffer.

 @param buffer       Pointer to the buffer with data inside of which packet should be found.
 @param searchRange  Range in which search should be performed.

 @return \c NSNotFound in case if there is no more packets in specified buffer.

 @since 3.7.10
 */
- (NSUInteger)HTTPResponseLocationIn:(NSData *)buffer withRange:(NSRange)searchRange;

/**
 @brief      Allow to find next HTTP response in specified buffer.

 @param buffer       Pointer to the buffer with data inside of which packet should be found.
 @param searchRange  Range in which search should be performed.

 @return \c NSNotFound in case if there is no more packets in specified buffer.

 @since 3.7.10
 */
- (NSUInteger)nextHTTPResponseLocationIn:(NSData *)buffer withRange:(NSRange)searchRange;

- (NSUInteger)HTTPHeadersEndMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange;

- (NSUInteger)chunkedHTTPPacketEndMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange;
- (BOOL)hasChunkedHTTPPacketEndMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange;

- (NSUInteger)newLineFeedMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange;

/**
 * Allow to compose response data object from chunked data using
 * octet values to determine next chunk size
 */
- (NSData *)joinedDataFromChunkedDataUsingOctets:(NSData *)buffer
                                  withJoinedSize:(NSUInteger *)joinedBufferSize;


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

- (void)parseBufferContent:(NSData *)buffer
                 withBlock:(void(^)(NSArray *responses, NSUInteger fullBufferLength,
                                    NSUInteger processedBufferLength,
                                    void(^readBufferPostProcessing)(void)))parseCompletionBlock {
    
    [self pn_dispatchBlock:^{
        
        if (!self.deserializing) {
                
            self.deserializing = YES;
            NSMutableArray *packetRanges = [NSMutableArray new];
            NSUInteger bufferSize = [buffer length];
            __block NSUInteger processedLength = 0;
            __block NSUInteger packetsCount = 0;
            __block NSUInteger httpPacketStart = NSNotFound;
            __block NSUInteger httpPacketLength = 0;
            
            void(^captureNormalizedBuffer)(NSUInteger, NSUInteger) = ^(NSUInteger normalizedBufferOffset,
                                                                       NSUInteger normalizedBufferLength) {
                
                if (httpPacketLength > 0) {
                    
                    packetsCount++;
                    processedLength = (normalizedBufferOffset + normalizedBufferLength);
                    NSRange packetRange = NSMakeRange(normalizedBufferOffset, normalizedBufferLength);
                    [packetRanges addObject:[NSValue valueWithRange:packetRange]];
                }
            };
            
            __block __pn_desired_weak void(^bufferProcessingBlockWeak)(NSUInteger, NSUInteger);
            void(^bufferProcessingBlock)( NSUInteger, NSUInteger);
            bufferProcessingBlockWeak = bufferProcessingBlock = ^(NSUInteger offset,  NSUInteger size) {

                // Search for HTTP packet start location in suggested buffer.
                NSRange searchRange = NSMakeRange(offset, size);
                NSUInteger packetStartLocation = [self HTTPResponseLocationIn:buffer
                                                                    withRange:searchRange];
                
                // Check whether packet start has been found or not.
                if (packetStartLocation != NSNotFound) {
                    
                    // Check whether already found packet start earlier or not.
                    if (httpPacketStart != NSNotFound) {
                        
                        // Calculate target HTTP packet size
                        httpPacketLength = packetStartLocation - httpPacketStart;
                        if (packetStartLocation > httpPacketStart) {
                            
                            captureNormalizedBuffer(httpPacketStart, httpPacketLength);
                        }
                        
                        // Update tracked HTTP packet information.
                        httpPacketStart = packetStartLocation;
                    }
                    else {
                        
                        // Check whether there is a garbage from previous incomplete HTTP
                        // packet or not.
                        if (offset == 0 && packetStartLocation != 0) {
                            
                            [PNLogger logDeserializerInfoMessageFrom:self
                                             withParametersFromBlock:^NSArray * {
                                
                                return @[PNLoggerSymbols.deserializer.garbageResponseData,
                                         @(packetStartLocation)];
                            }];
                            
                            [PNLogger storeGarbageHTTPPacketData:^NSData *{
                                
                                return buffer;
                            }];
                        }
                        // Looks like potentially we have read buffer which may have more content in
                        // next portion.
                        else {
                            
                            httpPacketStart = packetStartLocation;
                        }
                    }
                    
                    // Search for next HTTP packet start location in suggested buffer.
                    packetStartLocation = NSNotFound;
                    if (bufferSize >= httpPacketStart) {

                        searchRange = NSMakeRange(httpPacketStart, bufferSize - httpPacketStart);
                        packetStartLocation = [self nextHTTPResponseLocationIn:buffer withRange:searchRange];
                    }
                    
                    // Check whether there is more HTTP packets in this buffer or not
                    if (packetStartLocation != NSNotFound) {
                        
                        if (bufferSize > packetStartLocation) {
                            
                            bufferProcessingBlockWeak(packetStartLocation, bufferSize - packetStartLocation);
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
                
            bufferProcessingBlock(0, bufferSize);
            
            NSMutableArray *parsedResponses = [NSMutableArray new];
            if (bufferSize > 0) {
                
                // Check whether at least one HTTP packet has been found in provided buffer.
                if([packetRanges count] > 0) {
                    
                    void(^malformedResponseParseErrorHandler)(NSData *) = ^(NSData *malformedBuffer) {
                        
                        [PNLogger logDeserializerErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                            
                            NSString *encodedContent = [[NSString alloc] initWithData:malformedBuffer
                                                                             encoding:NSUTF8StringEncoding];
                            if (!encodedContent) {
                                
                                encodedContent = [[NSString alloc] initWithData:malformedBuffer
                                                                       encoding:NSASCIIStringEncoding];
                                
                                if (!encodedContent) {
                                    
                                    encodedContent = @"Binary data (can't be stringified)";
                                }
                            }
                            
                            return @[PNLoggerSymbols.deserializer.unableToEncodeResponseData,
                                     @([malformedBuffer length]),
                                     (encodedContent ? encodedContent : [NSNull null])];
                        }];
                    };

                    for (NSUInteger packetRangeIdx = 0; packetRangeIdx < [packetRanges count]; packetRangeIdx++) {

                        BOOL malformedResponse;
                        NSRange packetRange = [[packetRanges objectAtIndex:packetRangeIdx] rangeValue];
                        PNResponse *response = [self responseFrom:buffer withRange:packetRange
                                                malformedResponse:&malformedResponse];
                        if (response) {

                            [parsedResponses addObject:response];
                        }
                        else {

                            if (packetsCount == 1 || (packetRangeIdx == [packetRanges count] - 1)) {

                                if (malformedResponse) {

                                    malformedResponseParseErrorHandler([buffer subdataWithRange:packetRange]);
                                }
                                else {

                                    if (processedLength >= packetRange.length) {

                                        processedLength -= packetRange.length;
                                    }
                                }
                            }
                            else {

                                [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray * {

                                    return @[PNLoggerSymbols.deserializer.garbageResponseData,
                                            @(packetRange.length)];
                                }];

                                [PNLogger storeGarbageHTTPPacketData:^NSData *{

                                    return [buffer subdataWithRange:packetRange];
                                }];
                            }
                        }
                    }
                }
                else {
                    
                    [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray * {
                        
                        return @[PNLoggerSymbols.deserializer.garbageResponseData,
                                 @(bufferSize)];
                    }];
                    
                    processedLength = bufferSize;
                    [PNLogger storeGarbageHTTPPacketData:^NSData *{
                        
                        return buffer;
                    }];
                }
            }

            parseCompletionBlock([parsedResponses copy], bufferSize, processedLength, ^{
                
                [self pn_dispatchBlock:^{
                    
                    self.deserializing = NO;
                }];
            });
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

- (PNResponse *)responseFrom:(NSData *)buffer withRange:(NSRange)bufferRange
           malformedResponse:(BOOL *)isMalformedResponse {

    // Mark that request is incomplete because from the start we don't know for sure
    // (also this make code cleaner)
    *isMalformedResponse = YES;
    PNResponse *response = nil;

    CFHTTPMessageRef message = NULL;
    NSUInteger httpHeadersEndMarkerLocation = [self HTTPHeadersEndMarkerIn:buffer withRange:bufferRange];
    NSUInteger responseBodyOffset = 0;
    if (httpHeadersEndMarkerLocation != NSNotFound && bufferRange.length >= httpHeadersEndMarkerLocation) {

        responseBodyOffset = (httpHeadersEndMarkerLocation + [kHTTPHeaderEndMarker length]);

        // Appending only portion of bytes which contains reference on all passed with response
        // HTTP headers which will be used during body processing.
        message = CFHTTPMessageCreateEmpty(NULL, FALSE);
        CFHTTPMessageAppendBytes(message, [buffer bytes], (CFIndex)responseBodyOffset);
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

            if (!isResponseChunked || [self hasChunkedHTTPPacketEndMarkerIn:buffer withRange:bufferRange]) {

                // Retrieve pointer on actual message body (all headers stripped from it).
                NSUInteger contentSize = (bufferRange.length > responseBodyOffset ? (bufferRange.length - responseBodyOffset) : 0);

                if ((contentLength > 0 && contentSize > 0) || contentSize > 0) {

                    if (statusCode != 200 && !(statusCode >= 401 && statusCode <= 503)) {

                        [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                            NSString *encodedContent = [[NSString alloc] initWithData:buffer
                                                                             encoding:NSASCIIStringEncoding];

                            return @[PNLoggerSymbols.deserializer.unexpectedResponseStatusCode,
                                    @(statusCode), (encodedContent ? encodedContent : [NSNull null])];
                        }];

                        // In case if response arrived with unexpected code, store it for future research.
                        [PNLogger storeUnexpectedHTTPDescription:nil packetData:^NSData *{

                            return [[NSData alloc] initWithData:buffer];
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
                                                                                withRange:bufferRange];

                        isFullBody = (packetEndLocation != NSNotFound);
                        if (isFullBody) {

                            // Calculate new useful body content size. This will allow to truncate
                            // and data which has been appended by server aside from declared
                            // chinked content.
                            contentSize = (packetEndLocation + [kChunkedHTTPPacketEndMarker length]) - responseBodyOffset;
                        }
                    }

                    if (isFullBody) {

                        NSData *preparedData = [buffer subdataWithRange:NSMakeRange(responseBodyOffset, contentSize)];
                        if (isResponseChunked) {

                            NSUInteger joinedSize;
                            preparedData = [[self joinedDataFromChunkedDataUsingOctets:preparedData
                                                                        withJoinedSize:&joinedSize] copy];
                            contentSize = joinedSize;
                        }

                        if (isResponseCompressed) {

                            NSData *extractedData;
                            if ([self isGZIPCompressedTransfer:headers]) {
                                
                                extractedData = [preparedData pn_GZIPInflate];
                            }
                            else {

                                extractedData = [preparedData pn_inflate];
                            }
                            
                            contentSize = [extractedData length];
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
        
        if (message) {
            
            CFRelease(message);
        }
    }
    

    return response;
}

- (NSData *)joinedDataFromChunkedDataUsingOctets:(NSData *)buffer
                                  withJoinedSize:(NSUInteger *)joinedBufferSize {
    
    NSMutableData *joinedData = [NSMutableData new];
    BOOL parsingChunkOctet = YES;
    BOOL parsingChunk = NO;
    NSUInteger chunkStart = 0;
    NSInteger chunkSize = 0;

    NSUInteger cursorLocation = [self newLineFeedMarkerIn:buffer
                                                withRange:NSMakeRange(0, [buffer length])];

    while (cursorLocation != NSNotFound && (parsingChunkOctet || parsingChunk)) {

        if (parsingChunkOctet) {
            
            if ([buffer length] > chunkStart) {
                
                // Get size of the chunk with data
                chunkSize = strtol([buffer bytes] + chunkStart, NULL, 16);
                parsingChunkOctet = NO;
                parsingChunk = (chunkSize > 0);
                
                // Adjust chunk start position to the end of chunk size line feed
                chunkStart = cursorLocation + [kNewLineFeedMarker length];
            }
            else {
                
                chunkSize = 0;
            }

            // Check whether octet report that next chunk of data will
            // be zero length or not
            if (chunkSize == 0 || chunkSize >= INT_MAX || chunkSize == INT_MIN) {

                break;
            }
        }

        if (parsingChunk) {

            if (chunkSize > 0 && (chunkStart + chunkSize) <= [buffer length]) {

                [joinedData appendBytes:([buffer bytes] + chunkStart) length:(NSUInteger)chunkSize];
                parsingChunk = NO;

                // Adjust chunk start position to the end of chunk size line feed.
                // New line feed has been added, because each chunk of data end up with new line
                // feed not counted in chunk size.
                chunkStart += (chunkSize + [kNewLineFeedMarker length]);

                if ([buffer length] > chunkStart) {

                    parsingChunkOctet = YES;
                    cursorLocation = [self newLineFeedMarkerIn:buffer
                                                     withRange:NSMakeRange(chunkStart, [buffer length] - chunkStart)];
                }
            }
        }
    }

    *joinedBufferSize = joinedData.length;


    return (joinedData.length ? joinedData : nil);
}

- (NSUInteger)HTTPResponseLocationIn:(NSData *)buffer withRange:(NSRange)searchRange {

    NSUInteger location = NSNotFound;
    if ([buffer length] >= NSMaxRange(searchRange) && searchRange.length > 0) {

        static NSData *httpHeaderStartMarker;
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{

            httpHeaderStartMarker = [[kHTTPHeaderStartMarker dataUsingEncoding:NSUTF8StringEncoding] copy];
        });
        location = [buffer rangeOfData:httpHeaderStartMarker options:(NSDataSearchOptions)0
                                 range:searchRange].location;
    }


    return location;
}

- (NSUInteger)nextHTTPResponseLocationIn:(NSData *)buffer withRange:(NSRange)searchRange {

    if (searchRange.length > 0) {

        // Shift 1 symbol from previously found location
        searchRange = NSMakeRange(searchRange.location + 1, searchRange.length - 1);
    }

    return [self HTTPResponseLocationIn:buffer withRange:searchRange];
}

- (NSUInteger)HTTPHeadersEndMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange {

    NSUInteger location = NSNotFound;
    if ([buffer length] >= NSMaxRange(searchRange) && searchRange.length > 0) {

        static NSData *httpHeaderEndMarker;
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{

            httpHeaderEndMarker = [[kHTTPHeaderEndMarker dataUsingEncoding:NSUTF8StringEncoding] copy];
        });
        location = [buffer rangeOfData:httpHeaderEndMarker options:(NSDataSearchOptions)0
                                 range:searchRange].location;
    }


    return location;
}

- (NSUInteger)chunkedHTTPPacketEndMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange {

    NSUInteger location = NSNotFound;
    if ([buffer length] >= NSMaxRange(searchRange) && searchRange.length > 0) {

        static NSData *chunkedHTTPPacketEndMarker;
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{

            chunkedHTTPPacketEndMarker = [[kChunkedHTTPPacketEndMarker dataUsingEncoding:NSUTF8StringEncoding] copy];
        });
        location = [buffer rangeOfData:chunkedHTTPPacketEndMarker options:(NSDataSearchOptions)0
                                 range:searchRange].location;
    }


    return location;
}

- (BOOL)hasChunkedHTTPPacketEndMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange {

    return [self chunkedHTTPPacketEndMarkerIn:buffer withRange:searchRange] != NSNotFound;
}

- (NSUInteger)newLineFeedMarkerIn:(NSData *)buffer withRange:(NSRange)searchRange {

    NSUInteger location = NSNotFound;
    if ([buffer length] >= NSMaxRange(searchRange) && searchRange.length > 0) {

        static NSData *newLineFeedMarker;
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{

            newLineFeedMarker = [[kNewLineFeedMarker dataUsingEncoding:NSUTF8StringEncoding] copy];
        });
        location = [buffer rangeOfData:newLineFeedMarker options:(NSDataSearchOptions)0
                                 range:searchRange].location;
    }


    return location;
}

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];
}

#pragma mark -


@end
