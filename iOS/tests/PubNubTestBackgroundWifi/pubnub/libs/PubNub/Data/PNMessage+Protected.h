//
//  PNMessage+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#import "PNMessage.h"


#pragma mark Static

/**
 Stores reference on key under which message body is stored in case if API return time token for message.
 */
static NSString * const kPNMessageBodyKey = @"message";

/**
 Stores reference on key under which message timetoken is stired in case if API return time token for message.
 */
static NSString * const kPNMessageTimeTokenKey = @"timetoken";

#pragma mark Struct

struct PNMessageDataKeysStruct {

    /**
     Stores key under which message will be encoded.
     */
    __unsafe_unretained NSString *message;

    /**
     Stores key under which channel name will be encoded.
     */
    __unsafe_unretained NSString *channel;
    
    /**
     Stores key under which stored whether message should be compressed or not
     */
    __unsafe_unretained NSString *compress;

    /**
     Stores key under which message receive will be encoded.
     */
    __unsafe_unretained NSString *date;
};

extern struct PNMessageDataKeysStruct PNMessageDataKeys;


#pragma mark - Class forward

@class PNChannel, PNError, PNDate;


#pragma mark - Protected methods

@interface PNMessage (Protected)


#pragma mark - Properties

// Stores reference on message body
@property (nonatomic, strong) id message;

// Stores whether message should be compressed or not
@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;

// Stores reference on channel to which this message
// should be sent
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on date when this message was received (doesn't work for history, only for presence events).
@property (nonatomic, strong) PNDate *receiveDate;

@property (nonatomic, strong) PNDate *date;



#pragma mark - Class methods

/**
 * Return reference on object data object initialized with
 * object object and target channel
 * Message should be in stringified JSON format
 */
+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage error:(PNError **)error;

/**
 * Return reference on message data object which will represent
 * message received from PubNub service
 */
+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(PNDate *)messagePostDate;


#pragma mark - Instance methods

/**
 * Initialize object instance with text and channel
 */
- (id)initWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;

- (void)setReceiveDate:(PNDate *)receiveDate;


@end
