//
//  PNWriteBuffer.m
//  pubnub
//
//  Write buffer is objects which is used by
//  connection instance to fetch portion of
//  data which should be send and also used
//  to check whether full packet has been
//  sent or not.
//
//
//  Created by Sergey Mamontov on 12/14/12.
//
//

#import "PNWriteBuffer.h"
#import "PNBaseRequest+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub write buffer must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

// Stores reference on maximum write TCP
// packet size which will be sent over the
// socket (Default: 4kb)
static NSUInteger const kPNWriteBufferSize = 4096;


#pragma mark - Private interface methods

@interface PNWriteBuffer () {
    
    char *buffer;
}


#pragma mark - Properties

// Stores reference on how long packet payload which should
// be sent over the socket
@property (nonatomic, assign) CFIndex length;


@end


#pragma mark - Public interface methods

@implementation PNWriteBuffer


#pragma mark - Class methods

+ (PNWriteBuffer *)writeBufferForRequest:(PNBaseRequest *)request {
    
    return [[[self class] alloc] initWithRequest:request];
}


#pragma mark - Instance methods

- (id)initWithRequest:(PNBaseRequest *)request {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        NSString *httpPayload = [request HTTPPayload];
        self.requestIdentifier = request.identifier;
        self.length = sizeof(char)*[httpPayload length];
        
        // Allocate buffer for HTTP payload
        buffer = malloc((size_t)self.length);
        strncpy(buffer, [httpPayload UTF8String], (size_t)self.length);
    }
    
    
    return self;
}

- (BOOL)hasData {
    
    return self.offset < self.length;
}

- (BOOL)isPartialDataSent {
    
    return self.offset != 0 && self.offset != self.length;
}

- (UInt8 *)buffer {
    
    return (UInt8 *)(buffer+self.offset);
}

- (CFIndex)bufferLength {
    
    return MIN(kPNWriteBufferSize, self.length);
}

- (void)reset {

    self.sendingBytes = NO;
    self.offset = 0;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"WRITE BUFFER CONTENT: %@", [[NSString alloc] initWithBytes:buffer
                                                                                            length:(NSUInteger)self.length
                                                                                          encoding:NSUTF8StringEncoding]];
}


#pragma mark - Memory management

/**
 * Deallocate and release all resources which
 * was taken for write buffer support
 */
- (void)dealloc {
    
    // Clean up
    free(buffer);
}

#pragma mark -


@end
