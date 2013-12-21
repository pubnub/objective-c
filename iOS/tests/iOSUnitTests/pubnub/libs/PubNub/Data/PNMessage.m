//
//  PNMessage.m
//  pubnub
//
//  This class is used to represent single message
//  which is sent to the PubNub service and will be
//  sent to the PubNub client delegate and observers
//  to notify about that message will/did/fail to send.
//  This object also used to represent arrived messages
//  (received on subscribed channels).
//
//
//  Created by Sergey Mamontov on 1/7/13.
//
//


#import "PNMessage+Protected.h"
#import "PNJSONSerialization.h"
#import "PNCryptoHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub message must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNMessage ()


#pragma mark - Properties

// Stores reference on channel to which this message
// should be sent
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on message body
@property (nonatomic, strong) id message;

// Stores reference on date when this message was received
// (doesn't work for history, only for presence events)
@property (nonatomic, strong) PNDate *receiveDate;

// Stores reference on timetoken when this message was received
@property (nonatomic, strong) NSNumber *timeToken;


@end


#pragma mark Public interface methods

@implementation PNMessage


#pragma mark - Class methods

+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel error:(PNError **)error {

    PNMessage *messageObject = nil;
    BOOL isValidMessage = NO;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    object = object?[PNJSONSerialization stringFromJSONObject:object]:@"";
    isValidMessage = [[object stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0;
#else
    isValidMessage = object != nil;
#endif

    // Ensure that all parameters provided and they are valid or not
    if (isValidMessage && channel != nil) {

        messageObject = [[[self class] alloc] initWithObject:object forChannel:channel];
    }
    // Looks like some conditions not met
    else {

        // Check whether reference on error holder has been passed or not
        if (error != NULL) {

            // Check whether user tried to send empty object or not
            if (!isValidMessage) {

                *error = [PNError errorWithCode:kPNMessageHasNoContentError];
            }
            // Looks like user didn't specified channel on which this object
            // should be sent
            else {

                *error = [PNError errorWithCode:kPNMessageHasNoChannelError];
            }
        }
    }


    return messageObject;
}

+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(PNDate *)messagePostDate {

    PNMessage *message = [[self class] new];
    message.message = [PubNub AESDecrypt:messageBody];
    message.channel = channel;
    message.receiveDate = messagePostDate;


    return message;
}


#pragma mark - Instance methods

- (id)initWithObject:(id)object forChannel:(PNChannel *)channel {

    // Check whether initialization was successful or not
    if ((self = [super init])) {
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        self.message = [PNJSONSerialization stringFromJSONObject:object];
#else
        self.message = [PNCryptoHelper sharedInstance].isReady ? object : [PNJSONSerialization stringFromJSONObject:object];
#endif
        self.channel = channel;
    }


    return self;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <message: %@, date: %@, channel: %@>",
                                      NSStringFromClass([self class]),
                                      self,
                                      self.message,
                                      self.receiveDate,
                                      self.channel.name];
}

#pragma mark -


@end
