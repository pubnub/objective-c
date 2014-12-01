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
     Stores key under which stored whether message should be stored on PubNub servers or not.
     */
    __unsafe_unretained NSString *store;

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

// Stores whether message should be stored on PubNub servers for future usage with History API.
@property (nonatomic, assign, getter = shouldStoreInHistory) BOOL storeInHistory;

// Stpres whether message body has been encrypted or not
@property (nonatomic, assign, getter = isContentEncrypted) BOOL contentEncrypted;

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
+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
                  storeInHistory:(BOOL)shouldStoreInHistory error:(PNError **)error;

/**
 * Return reference on message data object which will represent
 * message received from PubNub service
 */
+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(PNDate *)messagePostDate;

/**
 @brief Construct message instance from \b PubNub service response.
 
 @discussion During subscriptino session servive may deliver different type of events and message is one of the. If 
 subscribed on channle group (which encloses set of channels into which messages are sent) there will information about
 at which channel inside of channel group message has been sent.
 
 @param messageBody     Message payload which has been delivered through \b PubNub message delivery service.
 @param channel         Reference on channel inside of which message has been sent
 @param group           Reference on channel group which contain channel with message
 @param messagePostDate Message receive date (server time when it has been registered inside of system)
 
 @return Configured and ready to use \b PNMessage instance.
 
 @since 3.7.0
 */
+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel
                             channelGroup:(PNChannelGroup *)group atDate:(PNDate *)messagePostDate;


#pragma mark - Instance methods

/**
 * Initialize object instance with text and channel
 */
- (id)initWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage
      storeInHistory:(BOOL)shouldStoreInHistory;
- (void)setReceiveDate:(PNDate *)receiveDate;


@end
