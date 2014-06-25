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
#import "PubNub+Protected.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub base request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNBaseRequest ()

#pragma mark - Properties

// Stores reference on whether connection should
// be closed before sending this message or not
@property (nonatomic, assign, getter = shouldCloseConnection) BOOL closeConnection;

// Stores number of request sending retries
// (when it will reach limit communication
// channel should remove it from queue
@property (nonatomic, assign) NSUInteger retryCount;


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

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    return @"0";
}

- (NSString *)resourcePath {

    [PNLogger logCommunicationChannelWarnMessageFrom:self message:^NSString * {

        return @"THIS METHOD SHOULD BE RELOADED IN SUBCLASS";
    }];
    
    return [self resourcePath:NO];
}

- (NSString *)debugResourcePath {

    return [self resourcePath:YES];
}

- (NSString *)resourcePath:(BOOL)forConsole {

    [PNLogger logCommunicationChannelWarnMessageFrom:self message:^NSString * {

        return @"THIS METHOD SHOULD BE RELOADED IN SUBCLASS";
    }];


    return @"/";
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

    NSString *authorizationKey = [PubNub sharedInstance].configuration.authorizationKey;
    if ([authorizationKey length] > 0) {

		authorizationKey = [NSString stringWithFormat:@"auth=%@", [authorizationKey percentEscapedString]];
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
    
    return [NSString stringWithFormat:@"http://%@%@", [PubNub sharedInstance].configuration.origin, [self resourcePath]];
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
    if ([PubNub sharedInstance].configuration.shouldAcceptCompressedResponse || [self shouldCompressPOSTBody]) {

        acceptEncoding = @"Accept-Encoding: gzip, deflate\r\n";
    }
    
    NSString *HTTPMethod = @"GET";
    NSData *postBody = nil;
    if ([self HTTPMethod] == PNRequestPOSTMethod) {
        
        HTTPMethod = @"POST";
        postBody = [self POSTBody];
        
        if ([self shouldCompressPOSTBody]) {
            
            postBody = [postBody GZIPDeflate];
        }
    }
    
    [plainPayload appendFormat:@"%@ %@ HTTP/1.1\r\nHost: %@\r\nAccept: */*\r\n%@",
     HTTPMethod, [self resourcePath], [PubNub sharedInstance].configuration.origin, acceptEncoding];
    
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

#pragma mark -


@end
