//
//  PNConnection+BadJson.m
//  pubnub
//
//  Created by Valentin Tuller on 10/2/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNConnectionBadJson.h"
#import "PNResponseDeserialize.h"
#import "FakeStub.h"

// Default data buffer size (Default: 32kb)
static int const kPNStreamBufferSize = 32768;
typedef NS_OPTIONS(NSUInteger, PNConnectionErrorStateFlag)  {

    // Flag which allow to set whether error occurred on read stream or not
    PNReadStreamError = 1 << 27,

    // Flag which allow to set whether error occurred on write stream or not
    PNWriteStreamError = 1 << 28,

    // Flag which allow to set whether client is experiencing some error or not
    PNConnectionError = (PNReadStreamError | PNWriteStreamError)
};

static void PNBitOn(unsigned long *flag, unsigned long mask);
void PNBitOn(unsigned long *flag, unsigned long mask) {

    *flag |= mask;
}

static void PNCFRelease(CF_RELEASES_ARGUMENT void *CFObject);
void PNCFRelease(CF_RELEASES_ARGUMENT void *CFObject) {
    if (CFObject != NULL) {

        if (*((CFTypeRef*)CFObject) != NULL) {

            CFRelease(*((CFTypeRef*)CFObject));
        }

        *((CFTypeRef*)CFObject) = NULL;
    }
}

@implementation PNConnection (BadJson)

//- (id)initWithConfiguration:(PNConfiguration *)configuration {
//
//    // Check whether initialization was successful or not
//    if ((self = [super init])) {
//
//        // Perform connection initialization
//        [(id)self setConfiguration: configuration];
//        [(id)self performSelector: @selector(setDeserializer) withObject: [PNResponseDeserialize new]];
//
//        // Set initial connection state
//        PNBitOn(&_state, PNConnectionDisconnected);
//
//        // Perform streams initial options and security initializations
//        [(id)self performSelector:@selector(prepareStreams)];
//    }
//    return self;
//}

- (void)updateBuffer:(UInt8 [])buffer {
	NSString *badJson =
	@"HTTP/1.1 504 Gateway Timeout\n"
	@"Date: Thu, 03 Oct 2013 11:10:18 GMT\n"
	@"Content-Type: text/javascript; charset=\"UTF-8\"\n"
	@"Content-Length: 372\n"
	@"Connection: keep-alive\n"
	@"Cache-Control: no-cache\n"
	@"Access-Control-Allow-Origin: *\n"
	@"Access-Control-Allow-Methods: GET\n"
	@"<?xml version='1.0'?>"
	@"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'"
	@"'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>"
	@"<html xmlns='http://www.w3.org/1999/xhtml'>"
	@"<head>"
	@"<title>The request failed</title>"
	@"</head>"
	@"<body>"
	@"<p><big>Service Unavailable.</big></p>"
	@"<p>"
	@"<i>Technical description:</i><br/>504 Gateway Time-out - The web server is not responding</p>"
	@"</body>"
	@"</html>";
	NSData *newData = [badJson dataUsingEncoding: NSUTF8StringEncoding];
//	NSLog(@"badJson \n%@", badJson);
	memcpy( buffer, newData.bytes, newData.length);
}

- (void)updateBuffer1:(UInt8 [])buffer {
	NSString *badJson =
//	@"HTTP/1.1 200 OK\n"
//	@"Date: Mon, 14 Oct 2013 11:45:34 GMT\n"
//	@"Content-Type: text/javascript; charset=\"UTF-8\"\n"
//	@"Content-Length: 33\n"
//	@"Connection: keep-alive\n"
//	@"Cache-Control: no-cache\n"
//	@"Access-Control-Allow-Origin: *\n"
//	@"Access-Control-Allow-Methods: GET\n"
//
//	@"s_654fc([[],\"13817511341066824\"])"
	@"<html>"
	@"<head><title>400 Bad Request</title></head>"
	@"'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>"
	@"<body bgcolor=\"white\">"
	@"<center><h1>400 Bad Request</h1></center>"
	@"<hr><center>nginx</center>"
	@"</body>"
	@"</html>";
	NSData *newData = [badJson dataUsingEncoding: NSUTF8StringEncoding];
//	NSLog(@"badJson1 \n%@", badJson);
	memcpy( buffer, newData.bytes, newData.length);
}

- (BOOL)isNeedUpdateBuffer {
	return NO;
}

- (BOOL)isNeedUpdateBuffer1 {
	return NO;
}

- (BOOL)isNeedCloseSocket {
	return NO;
}


-(BOOL)isNeedCreateError {
	return NO;
}

-(BOOL)isNeedReturnAfterRead {
	return NO;
}

- (void)readStreamContent {
//	NSLog(@"readStreamContent");
    PNLog(PNLogConnectionLayerInfoLevel, self, @"[CONNECTION::%@::READ] READING ARRIVED DATA... (STATE: %d)",
          [(id)self name] ? [(id)self name] : self, [(id)self state]);

    // Check whether data available right now or not (this is non-blocking request)
    if (CFReadStreamHasBytesAvailable( (CFReadStreamRef)[self performSelector:@selector(socketReadStream)])) {

        // Read raw data from stream
        UInt8 buffer[kPNStreamBufferSize];
		if( [self isNeedCloseSocket] == YES )
			CFReadStreamClose( (CFReadStreamRef)[self performSelector:@selector(socketReadStream)]);
        CFIndex readedBytesCount = CFReadStreamRead( (CFReadStreamRef)[self performSelector:@selector(socketReadStream)], buffer, kPNStreamBufferSize);

		if( [self isNeedReturnAfterRead] == YES ) {
			for( int j=0; j<60; j++ )
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
//			return;
		}

//		NSData *data = [NSData dataWithBytes: buffer length: readedBytesCount];
//		[data writeToFile: [NSString stringWithFormat: @"/Users/tuller/data/%ld.txt", readedBytesCount] atomically: YES];

		if( [self isNeedUpdateBuffer] == YES ) {
			[self updateBuffer: buffer];
			readedBytesCount = 605;
		}

		if( [self isNeedUpdateBuffer1] == YES ) {
			[self updateBuffer1: buffer+readedBytesCount];
			readedBytesCount += 164;
//			NSString *read = [[NSString alloc] initWithBytes: buffer length: readedBytesCount encoding: NSUTF8StringEncoding];
//			NSLog(@"read \n%@", read);
		}

        // Checking whether client was able to read out some data from stream or not
        if (readedBytesCount > 0) {

            PNLog(PNLogConnectionLayerInfoLevel, self, @"[CONNECTION::%@::READ] READED %d BYTES (STATE: %d)",
                  [(id)self name] ? [(id)self name] : self, readedBytesCount, [(id)self state]);


            // Check whether debugging options is enabled to show received response or not
            if (PNLoggingEnabledForLevel(PNLogConnectionLayerHTTPLoggingLevel) || PNHTTPDumpOutputToFileEnabled()) {

                NSData *tempData = [NSData dataWithBytes:buffer length:(NSUInteger)readedBytesCount];

                if (PNLoggingEnabledForLevel(PNLogConnectionLayerHTTPLoggingLevel)) {

                    NSString *responseString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
                    if (!responseString) {

                        responseString = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
                    }
                    if (!responseString) {

                        responseString = @"Can't striongify response. Try check response dump on file system (if enabled)";
                    }

                    PNLog(PNLogConnectionLayerHTTPLoggingLevel, self, @"[CONNECTION::%@::READ] RESPONSE: %@",
						  [(id)self name] ? [(id)self name] : self, responseString);
                }

                PNHTTPDumpOutputToFile(tempData);
            }

            // Check whether working on data deserialization or not
            if ( [[self performSelector:@selector(deserializer)] isDeserializing]) {

                PNLog(PNLogConnectionLayerInfoLevel, self, @"[CONNECTION::%@::READ] DESERIALIZED IS BUSY. WRITTING "
					  "INTO TEMPORARY STORAGE (STATE: %d)",
                      [(id)self name] ? [(id)self name] : self, readedBytesCount, [(id)self state]);

                // Temporary store data in object
                [ [(id)self performSelector:@selector(temporaryRetrievedData)] appendBytes:buffer length:(NSUInteger)readedBytesCount];
            }
            else {

                // Store fetched data
                [[self performSelector:@selector(retrievedData)] appendBytes:buffer length:(NSUInteger)readedBytesCount];
                [self performSelector:@selector(processResponse)];
            }
        }
        // Looks like there is no data or error occurred while tried to read out stream content
        else if (readedBytesCount < 0) {

            PNLog(PNLogConnectionLayerInfoLevel, self, @"[CONNECTION::%@::READ] READ ERROR (STATE: %d)",
                  [(id)self name] ? [(id)self name] : self, [(id)self state]);

            CFErrorRef error = CFReadStreamCopyError((CFReadStreamRef)[self performSelector:@selector(socketReadStream)]);
			if( error == nil && [self isNeedCreateError] == YES ) {
				error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainOSStatus, -9800, NULL);
			}
			unsigned long state = [(id)self state];
            PNBitOn(&state, PNReadStreamError);
			[(FakeStub*)self setState: state];
            [(FakeStub*)self handleStreamError: error];

            PNCFRelease(&error);
        }
    }
}

void fakeReadStreamCallback(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
}

- (void)configureFakeReadStream {
	CFReadStreamRef readStream = (__bridge CFReadStreamRef)([self performSelector: @selector(socketReadStream)]);

    CFOptionFlags options = (kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable |
                             kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered);
//    CFStreamClientContext client = [self performSelector: @selector(streamClientContext)];

    // Configuring connection channel instance as client for read stream with described set of handling events
    CFReadStreamSetClient(readStream, options, fakeReadStreamCallback, /*&client*/ NULL);
}

- (void)myReconnect {
	[self reconnect];
}


@end
