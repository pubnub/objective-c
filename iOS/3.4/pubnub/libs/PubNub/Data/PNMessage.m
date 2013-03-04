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


#import "PNMessage.h"
#import "PNMessage+Protected.h"


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
@property (nonatomic, strong) NSDate *receiveDate;


@end


#pragma mark Public interface methods

@implementation PNMessage


#pragma mark - Class methods

+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel error:(PNError **)error {

    PNMessage *messageObject = nil;

    // Ensure that all parameters provided and they are valid or not
    if ([[object stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0 && channel != nil) {

        messageObject = [[[self class] alloc] initWithObject:object forChannel:channel];
    }
    // Looks like some conditions not met
    else {

        // Check whether reference on error holder has been passed or not
        if (error != NULL) {

            // Check whether user tried to send empty object or not
            if ([[object stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {

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

+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(NSDate *)messagePostDate {

    PNMessage *message = [[self class] new];
    message.message = messageBody;
    message.channel = channel;
    message.receiveDate = messagePostDate;


    return message;
}


#pragma mark - Instance methods

- (id)initWithObject:(id)object forChannel:(PNChannel *)channel {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.message = [PNJSONSerialization stringFromJSONObject:object];
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