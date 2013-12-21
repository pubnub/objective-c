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
#import "PubNub+Protected.h"
#import "PNCryptoHelper.h"
#import "PNConstants.h"


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

// Stores reference on client identifier on the
// moment of request creation
@property (nonatomic, copy) NSString *clientIdentifier;


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
        self.clientIdentifier = [PubNub escapedClientIdentifier];
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.sendMessageCallback;
}

- (NSString *)resourcePath {

    if (self.preparedMessage == nil) {

        NSString *message = self.message.message;

        // Retrieve reference on encrypted message (if possible)
        PNError *encryptionError;
        if ([PNCryptoHelper sharedInstance].isReady) {

            message = [PubNub AESEncrypt:self.message.message error:&encryptionError];
            
            if (encryptionError != nil) {

                PNLog(PNLogCommunicationChannelLayerErrorLevel,
                        self,
                        @"Message encryption failed with error: %@\nUnencrypted message will be sent.",
                        encryptionError);
            }
        }

        // Encode message with % so it will be delivered w/o damages to
        // the PubNub service
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        self.preparedMessage = [message percentEscapedString];
#else
        self.preparedMessage = [message nonStringPercentEscapedString];
#endif
    }


    return [NSString stringWithFormat:@"%@/publish/%@/%@/%@/%@/%@_%@/%@?uuid=%@%@",
                    kPNRequestAPIVersionPrefix,
                    [PubNub sharedInstance].configuration.publishKey,
                    [PubNub sharedInstance].configuration.subscriptionKey,
                    [self signature],
                    [self.message.channel escapedName],
                    [self callbackMethodName],
                    self.shortIdentifier,
                    self.preparedMessage,
                    self.clientIdentifier,
					([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@"")];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:2 withObject:PNObfuscateString([PubNub sharedInstance].configuration.publishKey)];
    [resourcePathComponents replaceObjectAtIndex:3 withObject:PNObfuscateString([PubNub sharedInstance].configuration.subscriptionKey)];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

- (NSString *)signature {

    NSString *signature = @"0";
#if PN_SHOULD_USE_SIGNATURE
    NSString *secretKey = [PubNub sharedInstance].configuration.secretKey;
    if ([secretKey length] > 0) {

        NSString *signedRequestPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@%@",
                        [PubNub sharedInstance].configuration.publishKey,
                        [PubNub sharedInstance].configuration.subscriptionKey,
                        secretKey,
                        [self.message.channel escapedName],
                        self.message.message,
                        ([self authorizationField]?[NSString stringWithFormat:@"?%@", [self authorizationField]]:@"")];

        signature = PNHMACSHA256String(secretKey, signedRequestPath);
    }
#endif

    return signature;
}

#pragma mark -


@end
