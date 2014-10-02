//
//  PNBaseRequest.m
//  pubnub
//
//  Base request class which will allow to
//  serialize specified data into format
//  which will be sent over socket connection.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import <Foundation/Foundation.h>
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "NSData+PNAdditions.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub base request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNBaseRequest ()

#pragma mark - Properties

// Stores reference on client identifier on the moment of request creation
@property (nonatomic, copy) NSString *clientIdentifier;

// Stores reference on whether connection should be closed before sending this message or not
@property (nonatomic, assign, getter = shouldCloseConnection) BOOL closeConnection;

// Stores number of request sending retries (when it will reach limit communication channel should remove it from queue
@property (nonatomic, assign) NSUInteger retryCount;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *authorizationKey;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, assign, getter = shouldAcceptCompressedResponse) BOOL acceptCompressedResponse;


#pragma mark - Instance methods

/**
 Compose and output request resource path and depending on whether it should be used to send request or to be shown
 in console, it will obfuscate some inner data.

 @param forConsole
 If set to \c YES some secret information will be obfuscated or shown in original form if set to \c NO.

 @return composed resource path which can be used for request and console output
 */
- (NSString *)resourcePath:(BOOL)forConsole;


@end


#pragma mark - Public interface methods

@implementation PNBaseRequest


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization is successful or not
    if((self = [super init])) {
        
        self.identifier = [PNHelper UUID];
        self.shortIdentifier = [PNHelper shortenedUUIDFromUUID:self.identifier];
    }
    
    
    return self;
}
- (NSString *)callbackMethodName {

    return @"0";
}

- (NSString *)resourcePath {

    [PNLogger logCommunicationChannelWarnMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.requests.methodRequiresOwnImplementation, NSStringFromSelector(_cmd)];
    }];
    
    return [self resourcePath:NO];
}

- (NSString *)debugResourcePath {

    return [self resourcePath:YES];
}

- (NSString *)resourcePath:(BOOL)forConsole {

    [PNLogger logCommunicationChannelWarnMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.requests.methodRequiresOwnImplementation, NSStringFromSelector(_cmd)];
    }];


    return @"/";
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    self.acceptCompressedResponse = configuration.shouldAcceptCompressedResponse;
    self.timeout = configuration.nonSubscriptionRequestTimeout;
    self.authorizationKey = configuration.authorizationKey;
    self.origin = configuration.origin;
}

- (PNWriteBuffer *)buffer {
    
    return [PNWriteBuffer writeBufferForRequest:self];
}

- (void)reset {
    
    [self resetWithRetryCount:YES];
}

- (void)resetWithRetryCount:(BOOL)shouldResetRetryCountInformation {
    
    if (shouldResetRetryCountInformation) {
        
        self.retryCount = 0;
    }
    self.processing = NO;
    self.processed = NO;
}

- (void)resetRetryCount {

    self.retryCount = 0;
}

- (void)increaseRetryCount {

    self.retryCount++;
}

- (BOOL)canRetry {

    return self.retryCount < [self allowedRetryCount];
}

- (NSUInteger)allowedRetryCount {

    return kPNRequestMaximumRetryCount;
}

- (NSString *)authorizationField {

    NSString *authorizationKey = self.authorizationKey;
    if ([authorizationKey length] > 0) {

		authorizationKey = [NSString stringWithFormat:@"auth=%@", [authorizationKey pn_percentEscapedString]];
    }
    else {

        authorizationKey = nil;
    }


    return authorizationKey;
}

- (NSString *)clientInformationField {
    
    static NSString *clientInformation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        clientInformation = [NSString stringWithFormat:@"PubNub-%@%%2F%@", kPNClientName, kPNLibraryVersion];
    });
    
    
    return clientInformation;
}

- (NSString *)requestPath {
    
    return [NSString stringWithFormat:@"http://%@%@", self.origin, [self resourcePath]];
}

- (PNRequestHTTPMethod)HTTPMethod {
    
    return PNRequestGETMethod;
}

- (BOOL)shouldCompressPOSTBody {
    
    return NO;
}

- (NSData *)POSTBody {
    
    return nil;
}

- (NSData *)HTTPPayload {

    NSMutableString *plainPayload = [NSMutableString string];
    NSMutableData *payloadData = [NSMutableData data];
    NSString *acceptEncoding = @"";
    if (self.shouldAcceptCompressedResponse || [self shouldCompressPOSTBody]) {

        acceptEncoding = @"Accept-Encoding: gzip, deflate\r\n";
    }
    
    NSString *HTTPMethod = @"GET";
    NSData *postBody = nil;
    if ([self HTTPMethod] == PNRequestPOSTMethod) {
        
        HTTPMethod = @"POST";
        postBody = [self POSTBody];
        
        if ([self shouldCompressPOSTBody]) {
            
            postBody = [postBody pn_GZIPDeflate];
        }
    }
    
    [plainPayload appendFormat:@"%@ %@ HTTP/1.1\r\nHost: %@\r\nAccept: */*\r\n%@",
     HTTPMethod, [self resourcePath], self.origin, acceptEncoding];
    
    if (postBody) {
        
        [plainPayload appendFormat:@"Content-Encoding: gzip\r\nContent-Length: %lu\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n", (unsigned long)[postBody length]];
    }
    else {
        
        [plainPayload appendString:@"\r\n"];
    }
    
    [payloadData appendData:[plainPayload dataUsingEncoding:NSUTF8StringEncoding]];
    if (postBody) {
        
        [payloadData appendData:postBody];
        [payloadData appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    return payloadData;
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *resourcePath = ([self respondsToSelector:@selector(debugResourcePath)] ?
                              [self performSelector:@selector(debugResourcePath)] : [self resourcePath]);
    #pragma clang diagnostic pop
    
    return [NSString stringWithFormat:@"<%@|%@|%@>", ([self HTTPMethod] == PNRequestPOSTMethod ? @"POST" :@"GET"),
            resourcePath, @([self shouldCompressPOSTBody])];
}

#pragma mark -


@end
