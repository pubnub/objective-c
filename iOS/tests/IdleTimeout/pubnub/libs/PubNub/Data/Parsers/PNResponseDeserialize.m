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
#import "PNResponse.h"
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub response deserializer must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif



#pragma mark Static

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

// Stores reference on data object which is used
// to find response block start
@property (nonatomic, strong) NSData *httpHeaderStartData;

// Stores reference on data object which is used
// to mark chunked content end in HTTP response
// body
@property (nonatomic, strong) NSData *httpChunkedContentEndData;

// Stores reference on data object which is used
// to find new line chars (\r\n) in provided data
@property (nonatomic, strong) NSData *endLineCharactersData;

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

- (PNResponse *)responseInRange:(NSRange)responseRange
                         ofData:(NSData *)data
             incompleteResponse:(BOOL *)isIncompleteResponse;

/**
 * Return reference on index where next HTTP
 * response starts (searching index of "HTTP/1.1"
 * string after current one)
 */
- (NSUInteger)nextResponseStartIndexForData:(NSData *)data inRange:(NSRange)responseRange;

- (NSRange)nextResponseStartSearchRangeInRange:(NSRange)responseRange;

/**
 * Allow to compose response data object from chunked data using
 * octet values to determine next chunk size
 */
- (NSData *)joinedDataFromChunkedDataUsingOctets:(NSData *)chunkedData;


@end


#pragma mark Public interface methods

@implementation PNResponseDeserialize


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.httpHeaderStartData = [@"HTTP/1.1 " dataUsingEncoding:NSUTF8StringEncoding];
        self.httpChunkedContentEndData = [@"0\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.endLineCharactersData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        [self pn_setupPrivateSerialQueueWithIdentifier:@"response-deserializer"
                                           andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    }
    
    
    return self;
}

- (void)parseResponseData:(NSMutableData *)data withBlock:(void (^)(NSArray *responses))parseCompletionBlock {
    
    [self pn_dispatchBlock:^{

        NSMutableArray *parsedData = [NSMutableArray array];
        
        self.deserializing = YES;
        
        BOOL incompleteBody = NO;
        NSRange responseRange = NSMakeRange(0, [data length]);
        NSRange contentRange = NSMakeRange(0, [data length]);
        
        
        void(^malformedResponseParseErrorHandler)(NSData *, NSRange) = ^(NSData *responseData, NSRange subrange) {
            
            [PNLogger logDeserializerErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                
                NSData *failedResponseData = [responseData subdataWithRange:subrange];
                NSString *encodedContent = [[NSString alloc] initWithData:failedResponseData encoding:NSUTF8StringEncoding];
                if (!encodedContent) {
                    
                    encodedContent = [[NSString alloc] initWithData:failedResponseData encoding:NSASCIIStringEncoding];
                    
                    if (!encodedContent) {
                        
                        encodedContent = @"Binary data (can't be stringified)";
                    }
                }
                
                return @[PNLoggerSymbols.deserializer.unableToEncodeResponseData, @([failedResponseData length]),
                         (encodedContent ? encodedContent : [NSNull null])];
            }];
        };
        
        @autoreleasepool {
            
            NSUInteger nextResponseIndex = [self nextResponseStartIndexForData:data inRange:responseRange];
            if (nextResponseIndex == NSNotFound) {
                
                // Try construct response instance
                PNResponse *response = [self responseInRange:contentRange ofData:data incompleteResponse:&incompleteBody];
                if (response) {
                    
                    [parsedData addObject:response];
                }
                else {
                    
                    if (!incompleteBody) {
                        
                        malformedResponseParseErrorHandler(data, contentRange);
                    }
                    else {
                        
                        contentRange = NSMakeRange(NSNotFound, 0);
                    }
                }
            }
            else {
                
                // Stores previous content range and will be used to
                // update current content range in case of parsing error
                // (maybe tried parse incomplete response)
                NSRange previousContentRange = NSMakeRange(NSNotFound, 0);
                
                // Search for another responses while it is possible
                while (nextResponseIndex != NSNotFound) {
                    
                    contentRange.length = nextResponseIndex - contentRange.location;
                    
                    
                    // Try construct response instance
                    PNResponse *response = [self responseInRange:contentRange ofData:data incompleteResponse:&incompleteBody];
                    if(response) {
                        
                        [parsedData addObject:response];
                    }
                    
                    if (!incompleteBody) {
                        
                        if (!response) {
                            
                            malformedResponseParseErrorHandler(data, contentRange);
                        }
                        
                        // Update content search range
                        responseRange.location = responseRange.location + contentRange.length;
                        responseRange.length = responseRange.length - contentRange.length;
                        if (responseRange.length > 0) {
                            
                            nextResponseIndex = [self nextResponseStartIndexForData:data inRange:responseRange];
                            if (nextResponseIndex == NSNotFound) {
                                
                                nextResponseIndex = responseRange.location + responseRange.length;
                            }
                            
                            previousContentRange.location = contentRange.location;
                            previousContentRange.length = contentRange.length;
                            contentRange.location = responseRange.location;
                        }
                        else {
                            
                            nextResponseIndex = NSNotFound;
                        }
                    }
                    else {
                        
                        nextResponseIndex = NSNotFound;
                        contentRange.location = previousContentRange.location;
                        contentRange.length = previousContentRange.length;
                    }
                }
            }
        }
        
        
        if(contentRange.location != NSNotFound) {
            
            // Update provided data to remove from it response content which successfully was parsed
            NSUInteger lastResponseEndIndex = contentRange.location + contentRange.length;
            [data setData:[data subdataWithRange:NSMakeRange(lastResponseEndIndex, [data length]-lastResponseEndIndex)]];
        }

        self.deserializing = NO;
        parseCompletionBlock(parsedData);
    }];
}

- (void)checkDeserializing:(void(^)(BOOL deserializing))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        checkCompletionBlock(self.isDeserializing);
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

- (PNResponse *)responseInRange:(NSRange)responseRange ofData:(NSData *)data incompleteResponse:(BOOL *)isIncompleteResponse {

    // Mark that request is incomplete because from the start we don't know for sure
    // (also this make code cleaner)
    *isIncompleteResponse = YES;
    PNResponse *response = nil;
    NSData *responseSubdata = [data subdataWithRange:responseRange];

    // Pass bytes into HTTP message object to ease headers parsing
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(NULL, FALSE);
    CFHTTPMessageAppendBytes(message, responseSubdata.bytes, responseSubdata.length);

    // Ensure that full HTTP header has been received
    if (message != NULL) {

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

            // Fetch cleaned up response body (all extra new lines will be stripped away)
            NSData *responseBody = CFBridgingRelease(CFHTTPMessageCopyBody(message));


            NSUInteger contentSize = [responseBody length];
            if ((contentLength > 0 && contentSize > 0) || contentSize > 0) {

                if (statusCode != 200 && !(statusCode >= 401 && statusCode <= 503)) {

                    NSData *httpPayload = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(message));
                    NSString *encodedContent = [[NSString alloc] initWithData:httpPayload
                                                                     encoding:NSASCIIStringEncoding];
                    [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                        return @[PNLoggerSymbols.deserializer.unexpectedResponseStatusCode, @(statusCode),
                                (encodedContent ? encodedContent : [NSNull null])];
                    }];
                    
                    // In case if response arrived with unexpected code, store it for future research.
                    [PNLogger storeUnexpectedHTTPDescription:nil packetData:^NSData *{
                        
                        return responseSubdata;
                    }];
                }

                // Check whether there provided content is larger than declared by 'Content-Length' or not
                if (contentSize > contentLength && contentLength > 0) {

                    // Looks like there is an extra data at the end of parsed response which should be truncated to the
                    // correct size
                    responseBody = [responseBody subdataWithRange:NSMakeRange(0, contentLength)];
                    contentSize = [responseBody length];
                }


                BOOL isFullBody = contentSize == contentLength;

                if (isResponseChunked) {

                    // Retrieve range of content end
                    NSRange contentEndRange = [responseBody rangeOfData:self.httpChunkedContentEndData
                                                                options:NSDataSearchBackwards
                                                                  range:NSMakeRange(0, contentSize)];


                    isFullBody = contentEndRange.location != NSNotFound &&
                            (contentEndRange.location + contentEndRange.length == contentSize);
                    if (isFullBody) {

                        responseBody = [responseBody subdataWithRange:NSMakeRange(0, contentEndRange.location)];
                    }
                }

                if (isFullBody) {

                    if (isResponseChunked) {

                        responseBody = [self joinedDataFromChunkedDataUsingOctets:responseBody];
                    }

                    if (isResponseCompressed) {

                        if ([self isGZIPCompressedTransfer:headers]) {

                            responseBody = [responseBody pn_GZIPInflate];
                        }
                        else {

                            responseBody = [responseBody pn_inflate];
                        }
                    }

                    *isIncompleteResponse = responseBody == nil;
                    [PNLogger logDeserializerInfoMessageFrom:self withParametersFromBlock:^NSArray *{

                        NSString *rawData = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
                        return @[PNLoggerSymbols.deserializer.rawResponseData, @(statusCode),
                                (rawData ? rawData : [NSNull null])];
                    }];
                    response = [PNResponse responseWithContent:responseBody size:responseSubdata.length code:statusCode
                                      lastResponseOnConnection:!isKeepAliveConnection];
                }
            }
        }
        CFRelease(message);
    }
    
    
    return response;
}

- (NSData *)joinedDataFromChunkedDataUsingOctets:(NSData *)chunkedData {

    NSMutableData *joinedData = [NSMutableData data];
    BOOL parsingChunkOctet = YES;
    BOOL parsingChunk = NO;
    NSRange searchRange = NSMakeRange(0, [chunkedData length]);
    NSUInteger chunkStart = searchRange.location;

    NSRange cursor = [chunkedData rangeOfData:self.endLineCharactersData
                                      options:(NSDataSearchOptions)0
                                        range:searchRange];

    while (cursor.location != NSNotFound) {

        // When the loop starts chunkStart points to the first byte of the chunk
        // we are processing, and cursor points to byte that signifies the end
        // of the chunk (which is always \r\n).
        // The chunk NSData can be a header, a chunk octet, or an actual chunk.
        NSData *chunk = [chunkedData subdataWithRange:NSMakeRange(chunkStart, cursor.location - chunkStart)];

        // The next chunk starts after the cursor.
        chunkStart = cursor.location + cursor.length;
        NSUInteger chunkEnd = searchRange.location + searchRange.length - chunkStart;
        NSRange nextSearchRange = NSMakeRange(chunkStart, chunkEnd);

        if (parsingChunk) {

            parsingChunk = NO;
            parsingChunkOctet = YES;

            [joinedData appendData:chunk];

            cursor = [chunkedData rangeOfData:self.endLineCharactersData
                                      options:(NSDataSearchOptions)0
                                        range:nextSearchRange];
        }
        else if (parsingChunkOctet) {

            parsingChunkOctet = NO;
            parsingChunk = YES;

            unsigned long chunkSize = 0;
            if (chunk) {

                chunkSize = strtoul(chunk.bytes, NULL, 16);
            }
            
            // Check whether octet report that next chunk of data will
            // be zero length or not
            if (chunkSize == 0 || chunkSize == INT_MAX || chunkSize == INT_MIN) {

                break;
            }

            cursor = NSMakeRange(chunkStart + chunkSize, [self.endLineCharactersData length]);
        }
        else {

            if ([chunk length] <= 0) {

                parsingChunkOctet = YES;
            }

            cursor = [chunkedData rangeOfData:self.endLineCharactersData
                                      options:(NSDataSearchOptions)0
                                        range:nextSearchRange];
        }
    }


    return joinedData;
}

- (NSUInteger)nextResponseStartIndexForData:(NSData *)data inRange:(NSRange)responseRange {
    
    NSRange range = NSMakeRange(NSNotFound, 0);
    if ([data length]) {
        
        NSRange searchRange = [self nextResponseStartSearchRangeInRange:responseRange];
        
        if (searchRange.location != NSNotFound && searchRange.location + searchRange.length < [data length]) {
            
            range = [data rangeOfData:self.httpHeaderStartData options:(NSDataSearchOptions)0
                                range:searchRange];
        }
    }
    
    
    return range.location;
}

- (NSRange)nextResponseStartSearchRangeInRange:(NSRange)responseRange; {
    
    return NSMakeRange(responseRange.location + 1, responseRange.length-1);
}

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];
}

#pragma mark -


@end
