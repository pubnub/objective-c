//
//  StoreUnexpectedHTTPDesctiptionTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 11/11/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNResponseDeserialize.h"


/*
 To keep name consistency
 */

#define _kCFHTTPMessageEmptyString			CFSTR("")
#define HEADERS_COMPLETE	0x00002000
#define IS_RESPONSE			0x00001000

#define DELIM_UNKNOWN		0
#define DELIM_CRLF			1
#define DELIM_CR			2
#define DELIM_LF			3

#define DELIMITER_MASK		0x00000C00

typedef struct __CFRuntimeBaseTest {
    uintptr_t _cfisa;
    uint8_t _cfinfo[4];
#if __LP64__
    uint32_t _rc;
#endif
} CFRuntimeBaseTest;

struct __CFHTTPMessageTest {
    CFRuntimeBaseTest _cfBase;
    
    CFStringRef _firstLine; // This is the request line for HTTP requests; the status line for HTTP responses
    CFStringRef _method;
    CFURLRef _url;
    CFMutableDictionaryRef _headers;
    CFMutableArrayRef _headerOrder;
    CFStringRef	_lastKey;	// This is the last key that was parsed in _parseHeadersFromData.
    CFDataRef _data;
	CFHTTPAuthenticationRef _auth;
	CFHTTPAuthenticationRef _proxyAuth;
    UInt32 _flags;
};

typedef struct __CFHTTPMessageTest* CFHTTPMessageRefTest;

/* To do - convert this ot the CFBit family of functions */
// Flag bitfields/masks
#define STATUS_MASK			0x000003FF

@interface StoreUnexpectedHTTPDesctiptionTest : XCTestCase

@end

@implementation StoreUnexpectedHTTPDesctiptionTest {
    PubNub *_pubNub;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)t1estResponseDeserialization
{
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost publishKey:kTestPNPublishKey subscribeKey:kTestPNSubscriptionKey secretKey:nil];
    
    _pubNub = [PubNub clientWithConfiguration:configuration];
    
    dispatch_group_t resGroup = dispatch_group_create();
    
    dispatch_group_enter(resGroup);
    
    [_pubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(resGroup);
    } errorBlock:^(PNError *error) {
        XCTFail(@"Error during connection: %@", error);
        
        dispatch_group_leave(resGroup);
    }];
    
    if ([GCDWrapper isGroup:resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout fired when try to connect pubnub");
    }
}

- (void)testTest {
    PNResponseDeserialize *response = [PNResponseDeserialize new];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testdata" ofType:@"plist"]];
    NSData *testData = dict[@"data"];
    
//    NSString *testString = @"48545450 2f312e31 20323030 204f4b0d 0a446174 653a2054 75652c20 3131204e 6f762032 30313420 31353a34 343a3132 20474d54 0d0a436f 6e74656e 742d5479 70653a20 74657874 2f6a6176 61736372 6970743b 20636861 72736574 3d225554 462d3822 0d0a436f 6e74656e 742d4c65 6e677468 3a203238 0d0a436f 6e6e6563 74696f6e 3a206b65 65702d61 6c697665 0d0a4361 6368652d 436f6e74 726f6c3a 206e6f2d 63616368 650d0a41 63636573 732d436f 6e74726f 6c2d416c 6c6f772d 4f726967 696e3a20 2a0d0a41 63636573 732d436f 6e74726f 6c2d416c 6c6f772d 4d657468 6f64733a 20474554 0d0a0d0a 745f6165 32356528 5b313431 35373230 36353234 35303233 31325d29";
//    
//    unsigned int c = [testString length];
//    uint8_t *bytes = malloc(sizeof(*bytes) * c);
//    
//    unsigned i;
//    for (i = 0; i < c; i++)
//    {
//        NSString *str = [testString characterAtIndex:i];
//        int byte = [str intValue];
//        bytes[i] = byte;
//    }
    
    /*
     <48545450 2f312e31 20323030 204f4b0d 0a446174 653a2054 75652c20 3131204e 6f762032 30313420 31363a32 303a3434 20474d54 0d0a436f 6e74656e 742d5479 70653a20 74657874 2f6a6176 61736372 6970743b 20636861 72736574 3d225554 462d3822 0d0a436f 6e74656e 742d4c65 6e677468 3a203238 0d0a436f 6e6e6563 74696f6e 3a206b65 65702d61 6c697665 0d0a4361 6368652d 436f6e74 726f6c3a 206e6f2d 63616368 650d0a41 63636573 732d436f 6e74726f 6c2d416c 6c6f772d 4f726967 696e3a20 2a0d0a41 63636573 732d436f 6e74726f 6c2d416c 6c6f772d 4d657468 6f64733a 20474554 0d0a0d0a 745f3661 34323228 5b313431 35373232 38343433 35323430 36305d29>

     */
    
//    NSMutableData *testData = [[testString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    // Pass bytes into HTTP message object to ease headers parsing
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(NULL, FALSE);
    CFHTTPMessageAppendBytes(message, testData.bytes, testData.length);
    
//    CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)@"status", (__bridge CFStringRef)@"505");
    
    CFIndex status = CFHTTPMessageGetResponseStatusCode(message);
//    CFIndex status = CFHTTPMessageGetResponseStatusCodeTest(message);
//    NSData *d = (__bridge NSData *)(CFHTTPMessageCopySerializedMessage(message));

    _parseHeadersFromData(message);
    
    CFHTTPMessageRefTest nativeMessage = (CFHTTPMessageRefTest)message;
    
//    UInt32 x = nativeMessage->_flags & STATUS_MASK;
    
//    nativeMessage->_flags = 201;
    
    nativeMessage->_firstLine = (__bridge CFStringRef)@"1111";
    
//    nativeMessage->_url = (__bridge CFURLRef)@"http:///afdfafds";
    
    CFIndex status3 = CFHTTPMessageGetResponseStatusCodeTest((CFHTTPMessageRef)nativeMessage);
    CFIndex status2 = CFHTTPMessageGetResponseStatusCode((CFHTTPMessageRef)nativeMessage);
    
//    NSLog(@"%@",[[NSString alloc] initWithBytes:[d bytes] length:[d length] encoding:NSUTF8StringEncoding]);
    
    [response parseResponseData:testData];
}

const UInt8 *parseHTTPVersion(const UInt8 *bytes, CFIndex len, Boolean consumeSpaces) {
    Boolean sawDecimal = FALSE, sawOneDigit = FALSE;
    const UInt8 *currentByte, *lastByte = bytes + len;
    if (len < 8) {
        // Yes, we could do some checking here, but instead we choose to wait until we have at least 8 bytes to look at
        // However, we want to at least catch very small 0.9 responses (which don't have a header)
        if (len > 0 && bytes[0] != 'H') return NULL;
        return bytes;
    } else if (!(bytes[0] == 'H' && bytes[1] == 'T' && bytes[2] == 'T' && bytes[3] == 'P' &&  bytes[4] == '/')) {
        // Don't have the prefix "HTTP/"
        return NULL;
    }
    for (currentByte = bytes+5; currentByte < lastByte; currentByte ++) {
        UInt8 ch = *currentByte;
        if (ch <= '9' && ch >= '0') {
            sawOneDigit = TRUE;
        } else if (ch == '.') {
            if (sawDecimal)  {
                return sawOneDigit ? currentByte : NULL;
            } else {
                sawDecimal = TRUE;
                sawOneDigit = FALSE;
            }
        } else {
            if (sawDecimal && sawOneDigit) {
                if (consumeSpaces) {
                    while (currentByte < lastByte && *currentByte == ' ') {
                        currentByte ++;
                    }
                }
                return currentByte;
            } else {
                return NULL;
            }
        }
    }
    return bytes;
}

const UInt8 *_extractResponseStatusLineTest(CFHTTPMessageRefTest response, const UInt8 *bytes, CFIndex len) {
    const UInt8 *currentByte = parseHTTPVersion(bytes, len, TRUE);
    const UInt8 *end = bytes + len;
    if (currentByte == bytes || currentByte + 3 >= end) { // insufficient bytes; we want 3 characters to be able grab the staus code
        return bytes;
    } else if (currentByte == NULL || *currentByte > '9' || *currentByte < '0' || currentByte[1] > '9' || currentByte[1] < '0' || currentByte[2] > '9' || currentByte[2] < '0') {
        // Something in the first bytes doesn't match the expected HTTP header.  Assume that we're receiving a header-less response
        response->_firstLine = CFRetain(_kCFHTTPMessageEmptyString);
        response->_flags |= HEADERS_COMPLETE;
        return bytes;
    } else {
        // O.k.; we've got a good HTTP header
        UInt32 delim = DELIM_UNKNOWN;
        UInt32 status = (currentByte[0] - '0')*100 + (currentByte[1] - '0')*10 + (currentByte[2] - '0');
        currentByte += 3;
        while (currentByte < end) {
            if (*currentByte == '\n' || *currentByte == '\r') {
                break;
            }
            currentByte ++;
        }
        if (currentByte < end) {
            if (*currentByte == '\n') {
                delim = DELIM_LF;
            } else if (currentByte+1 < end) {
                delim = (*(currentByte+1) == '\n') ? DELIM_CRLF : DELIM_CR;
            }
            // If neither of the clauses above is triggered, we need one more byte before we can figure this out.  Fall through and return the response unchanged, and we will try again when next new bytes arrive
        }
        if (delim == DELIM_UNKNOWN) {
            // Never found an EOL
            return bytes;
        } else {
            // Status code is in bytes 10 - 12
            response->_firstLine = CFStringCreateWithBytes(CFGetAllocator(response), bytes, currentByte - bytes, kCFStringEncodingISOLatin1, FALSE);
            response->_flags = (response->_flags & ~DELIMITER_MASK) | (delim << 10);
            response->_flags = (response->_flags & ~STATUS_MASK) | status;
            return  (delim == DELIM_CRLF) ? currentByte + 2 : currentByte + 1;
        }
    }
}

// The data to be parsed is sitting in message->_data
static Boolean _parseHeadersFromData(CFHTTPMessageRefTest message) {
    
    Boolean result = TRUE;
    CFAllocatorRef alloc = CFGetAllocator(message);
    const UInt8* start = CFDataGetBytePtr(message->_data);
    const UInt8* end = start + CFDataGetLength(message->_data);
    
    if (!message->_firstLine) {
        
        const UInt8* newStart;
        
        // NOTE this is not using CFHTTPMessageIsRequest in order
        // to avoid the function dispatch.
        if (message->_flags & IS_RESPONSE)
            newStart = _extractResponseStatusLineTest(message, start, end - start);
        else
            NSLog(@"We don't use it.");
//            newStart = _extractRequestFirstLine(message, start, end - start);
        
        if (newStart == start)
            return TRUE;
        
        if (!newStart)
            return FALSE;
        
        start = newStart;
    }
    
    return true;
}

// Assert if response is a request, not a response.  Return -1 if we haven't parsed a response code yet
UInt32 CFHTTPMessageGetResponseStatusCodeTest(CFHTTPMessageRefTest response) {
    //    __CFGenericValidateType(response, CFHTTPMessageGetTypeID());
    //    CFAssert2(((response->_flags & IS_RESPONSE) != 0), __kCFLogAssertion, "%s(): message 0x%x is an HTTP request, not a response", __PRETTY_FUNCTION__, response);
    
    if (!response->_firstLine) {
        // Haven't paresd out the status line yet
        return -1;
    } else if (CFStringGetLength(response->_firstLine) == 0) {
        // We got a simple response - no headers.  We fake a status response of 200 (OK), since we are receiving data....
        return 200;
    } else {
        return (response->_flags & STATUS_MASK);
    }
}

@end
