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
 * Retrieve reference on encrypted message
 */
- (NSString *)encryptedMessageWithError:(PNError **)encryptionError;

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

            message = [self encryptedMessageWithError:&encryptionError];

            if (encryptionError != nil) {

                PNLog(PNLogCommunicationChannelLayerErrorLevel,
                        self,
                        @"Message encryption failed with error: %@\nUnencrypted message will be sent.",
                        encryptionError);
            }
        }

        // Encode message with % so it will be delivered w/o damages to
        // the PubNub service
        self.preparedMessage = [message percentEscapedString];
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

- (NSString *)encryptedMessageWithError:(PNError **)encryptionError {

    NSString *encryptedData = [[PNCryptoHelper sharedInstance] encryptedStringFromString:self.message.message
                                                                                          error:encryptionError];

    return [NSString stringWithFormat:@"\"%@\"", encryptedData];
}

- (NSString *)signature {

    NSString *signature = @"0";
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


    return @"0";
}

#pragma mark -


@end