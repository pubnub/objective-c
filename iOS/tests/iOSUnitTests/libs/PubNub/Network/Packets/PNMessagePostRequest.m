//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  message sending request which will be
//  scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/28/12.
//
//

#import "PNMessagePostRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"
#import "PNLoggerSymbols.h"
#import "PNConfiguration.h"
#import "PNConstants.h"
#import "PNHelper.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub message post request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNMessagePostRequest ()


#pragma mark - Properties

// Stores reference on message object which will
// be processed
@property (nonatomic, strong) PNMessage *message;

// Stores reference on prepared message
@property (nonatomic, strong) NSString *preparedMessage;

@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *publishKey;


#pragma mark - Instance methods

/**
 * Retrieve message post request signature
 */
- (NSString *)signature;


@end


#pragma mark Public interface methods

@implementation PNMessagePostRequest


#pragma mark - Class methods

+ (PNMessagePostRequest *)postMessageRequestWithMessage:(PNMessage *)message; {

    return [[[self class] alloc] initWithMessage:message];
}


#pragma mark - Instance methods

- (id)initWithMessage:(PNMessage *)message {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.message = message;
    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.publishKey = configuration.publishKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.sendMessageCallback;
}

- (PNRequestHTTPMethod)HTTPMethod {
    
    return self.message.shouldCompressMessage ? PNRequestPOSTMethod : PNRequestGETMethod;
}

- (BOOL)shouldCompressPOSTBody {
    
    return self.message.shouldCompressMessage;
}

- (NSData *)POSTBody {
    
    return [self.preparedMessage dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)preparedMessage {
    
    if (_preparedMessage == nil) {
        
        id message = self.message.message;
        
        if ([self HTTPMethod] == PNRequestGETMethod) {
            
            // Encode message with % so it will be delivered w/o damages to
            // the PubNub service
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            self.preparedMessage = [message pn_percentEscapedString];
#else
            self.preparedMessage = [message pn_nonStringPercentEscapedString];
#endif
        }
        else {
            
            self.preparedMessage = message;
        }
    }
    
    
    return _preparedMessage;
}

- (NSString *)resourcePath {
    
    NSMutableString *resourcePath = [NSMutableString stringWithFormat:@"/publish/%@/%@/%@/%@/%@_%@",
                                                                      [self.publishKey pn_percentEscapedString],
                                                                      [self.subscriptionKey pn_percentEscapedString],
                                                                      [self signature],
                                                                      [self.message.channel escapedName],
                                                                      [self callbackMethodName],
                                                                      self.shortIdentifier];
    
    if (!self.message.shouldCompressMessage) {
        
        [resourcePath appendFormat:@"/%@", self.preparedMessage];
    }
    
    [resourcePath appendFormat:@"?uuid=%@%@&pnsdk=%@", [self.clientIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
                               [self clientInformationField]];
    
    if (!self.message.shouldStoreInHistory) {
        
        [resourcePath appendString:@"&store=0"];
    }
    

    return resourcePath;
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    NSString *publishKey = [self.publishKey pn_percentEscapedString];
    NSString *debugResourcePath = [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];

    
    return [debugResourcePath stringByReplacingOccurrencesOfString:publishKey withString:PNObfuscateString(publishKey)];
}

- (NSString *)signature {

    NSString *signature = @"0";
#if PN_SHOULD_USE_SIGNATURE
    NSString *secretKey = self.secretKey;
    if ([secretKey length] > 0) {

        NSString *signedRequestPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@%@", self.publishKey, self.subscriptionKey,
                                       secretKey, [self.message.channel escapedName], self.message.message,
                        ([self authorizationField] ? [NSString stringWithFormat:@"?%@", [self authorizationField]] : @""),
                        ([self authorizationField] ? [NSString stringWithFormat:@"&pnsdk=%@", [self clientInformationField]] :
                                                     [NSString stringWithFormat:@"?pnsdk=%@", [self clientInformationField]])];
        
        signature = [PNEncryptionHelper HMACSHA256FromString:signedRequestPath withKey:secretKey];
    }
#endif

    return signature;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
