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
#import "PNErrorCodes.h"
#import "PNChannel.h"
#import "PNError.h"
#import "PNDate.h"
#import "PubNub.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub message must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif

#pragma mark Structures

struct PNMessageDataKeysStruct PNMessageDataKeys = {

    .message = @"message",
    .channel = @"channel",
    .compress = @"compressed",
    .date = @"date"
};


#pragma mark - Private interface methods

@interface PNMessage () <NSCoding>


#pragma mark - Properties

// Stores reference on channel to which this message
// should be sent
@property (nonatomic, strong) PNChannel *channel;

// Stores whether message should be compressed or not
@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;

// Stores reference on message body
@property (nonatomic, strong) id message;

// Stores reference on date when this message was received
// (doesn't work for history, only for presence events)
@property (nonatomic, strong) PNDate *receiveDate;

@property (nonatomic, strong) PNDate *date;

// Stores reference on timetoken when this message was received
@property (nonatomic, strong) NSNumber *timeToken;


@end


#pragma mark Public interface methods

@implementation PNMessage


#pragma mark - Class methods

+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage error:(PNError **)error {

    PNMessage *messageObject = nil;
    BOOL isValidMessage = NO;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    object = object?[PNJSONSerialization stringFromJSONObject:object]:@"";
    if (![object isKindOfClass:[NSNumber class]]) {

        isValidMessage = [[object stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0;
    }
    else {

        isValidMessage = YES;
    }
#else
    isValidMessage = object != nil;
#endif

    // Ensure that all parameters provided and they are valid or not
    if (isValidMessage && channel != nil) {

        messageObject = [[[self class] alloc] initWithObject:object forChannel:channel compressed:shouldCompressMessage];
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

    // Check whether message body contains time token included from history API or not
    if ([messageBody isKindOfClass:[NSDictionary class]]) {

        if ([messageBody objectForKey:kPNMessageTimeTokenKey])  {

            messagePostDate = [PNDate dateWithToken:[messageBody objectForKey:kPNMessageTimeTokenKey]];
        }

        // Extract real message
        if ([messageBody objectForKey:kPNMessageTimeTokenKey]) {

            messageBody = [messageBody valueForKey:kPNMessageBodyKey];
        }
    }

    message.message = [PubNub AESDecrypt:messageBody];
    message.channel = channel;
    message.receiveDate = messagePostDate;


    return message;
}

+ (PNMessage *)messageFromFileAtPath:(NSString *)messageFilePath {

    PNMessage *message = nil;
    if (messageFilePath) {

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:messageFilePath]) {

            message = [NSKeyedUnarchiver unarchiveObjectWithFile:messageFilePath];
        }
    }


    return message;
}


#pragma mark - Instance methods

- (id)initWithCoder:(NSCoder *)decoder {

    // Checking whether valid decoder data has been provided or not.
    if ([decoder containsValueForKey:PNMessageDataKeys.message] &&
        [decoder containsValueForKey:PNMessageDataKeys.channel]) {

        // Check whether initialization has been successful or not
        if ((self = [super init])) {

            self.message = [decoder decodeObjectForKey:PNMessageDataKeys.message];
            self.channel = [PNChannel channelWithName:[decoder decodeObjectForKey:PNMessageDataKeys.channel]];

            if ([decoder containsValueForKey:PNMessageDataKeys.date]) {

                self.receiveDate = [PNDate dateWithToken:[decoder decodeObjectForKey:PNMessageDataKeys.date]];
            }
            self.compressMessage = [[decoder decodeObjectForKey:PNMessageDataKeys.compress] boolValue];
        }
    }
    else {

        self = nil;
    }


    return self;
}

- (id)initWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage {

    // Check whether initialization was successful or not
    if ((self = [super init])) {
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        self.message = [PNJSONSerialization stringFromJSONObject:object];
#else
        self.message = [PNCryptoHelper sharedInstance].isReady ? object : [PNJSONSerialization stringFromJSONObject:object];
#endif
        self.channel = channel;
        self.compressMessage = shouldCompressMessage;
    }


    return self;
}

- (BOOL)writeToFileAtPath:(NSString *)messageStoreFilePath {

    BOOL isWritten = NO;
    if (messageStoreFilePath) {

        NSError *storeError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:messageStoreFilePath]) {

            [fileManager removeItemAtPath:messageStoreFilePath error:&storeError];
        }

        if (storeError == nil) {

            isWritten = [NSKeyedArchiver archiveRootObject:self toFile:messageStoreFilePath];
        }
    }


    return isWritten;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.message forKey:PNMessageDataKeys.message];
    [coder encodeObject:self.channel.name forKey:PNMessageDataKeys.channel];

    if (self.receiveDate) {

        [coder encodeObject:self.receiveDate.timeToken forKey:PNMessageDataKeys.date];
    }
    [coder encodeObject:@(self.shouldCompressMessage) forKey:PNMessageDataKeys.compress];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <message: %@, date: %@, channel: %@>",
                                      NSStringFromClass([self class]),
                                      self,
                                      self.message,
                                      (self.receiveDate ? self.receiveDate : self.date),
                                      self.channel.name];
}

#pragma mark -


@end
