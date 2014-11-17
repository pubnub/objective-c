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
#import "PNChannelGroup.h"
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
    .store = @"store",
    .date = @"date"
};


#pragma mark - Private interface methods

@interface PNMessage () <NSCoding>


#pragma mark - Properties

@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) PNChannelGroup *channelGroup;
@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;
@property (nonatomic, assign, getter = shouldStoreInHistory) BOOL storeInHistory;
@property (nonatomic, assign, getter = isContentEncrypted) BOOL contentEncrypted;
@property (nonatomic, strong) id message;
@property (nonatomic, strong) PNDate *receiveDate;
@property (nonatomic, strong) PNDate *date;
@property (nonatomic, strong) NSNumber *timeToken;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNMessage


#pragma mark - Class methods

+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
                  storeInHistory:(BOOL)shouldStoreInHistory error:(PNError **)error {

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

        messageObject = [[[self class] alloc] initWithObject:object forChannel:channel compressed:shouldCompressMessage
                                              storeInHistory:shouldStoreInHistory];
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
    
    return [self messageFromServiceResponse:messageBody onChannel:channel channelGroup:nil atDate:messagePostDate];
}

+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel
                             channelGroup:(PNChannelGroup *)group atDate:(PNDate *)messagePostDate {
    
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
    
    message.message = messageBody;
    message.channel = channel;
    message.channelGroup = group;
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
            self.storeInHistory = [[decoder decodeObjectForKey:PNMessageDataKeys.store] boolValue];
        }
    }
    else {

        self = nil;
    }


    return self;
}

- (id)initWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
      storeInHistory:(BOOL)shouldStoreInHistory {

    // Check whether initialization was successful or not
    if ((self = [super init])) {
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        self.message = [PNJSONSerialization stringFromJSONObject:object];
#else
        self.message = [PNCryptoHelper sharedInstance].isReady ? object : [PNJSONSerialization stringFromJSONObject:object];
#endif
        self.channel = channel;
        self.compressMessage = shouldCompressMessage;
        self.storeInHistory = shouldStoreInHistory;
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
    [coder encodeObject:@(self.shouldStoreInHistory) forKey:PNMessageDataKeys.store];
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): <message: %@, date: %@, channel: %@>", NSStringFromClass([self class]),
            self, self.message, (self.receiveDate ? self.receiveDate : self.date), self.channel.name];
}

- (NSString *)logDescription {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    PNDate *eitherDate = (self.receiveDate ? self.receiveDate : self.date);
    NSMutableString *logDescription = [NSMutableString stringWithFormat:@"<%@|%@",
                                       (self.channel.name ? self.channel.name : [NSNull null]),
                                       (eitherDate ? [eitherDate performSelector:@selector(logDescription)] : [NSNull null])];
    if (self.message) {
        
        [logDescription appendFormat:@"%@>",
         ([self.message respondsToSelector:@selector(logDescription)] ?
          [self.message performSelector:@selector(logDescription)] : self.message)];
    }
    else {
        
        [logDescription appendString:@">"];
    }
#pragma clang diagnostic pop
    
    
    return logDescription;
}

#pragma mark -


@end
