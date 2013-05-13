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


#pragma mark Class forward

@class PNChannel, PNDate;


#pragma mark - Protected methods

@interface PNMessage (Protected)


#pragma mark - Properties

// Stores reference on message body
@property (nonatomic, strong) id message;

// Stores reference on channel to which this message
// should be sent
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on date when this message was received
// (doesn't work for history, only for presence events)
@property (nonatomic, strong) PNDate *receiveDate;



#pragma mark - Class methods

/**
 * Return reference on object data object initialized with
 * object object and target channel
 * Message should be in stringified JSON format
 */
+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel error:(PNError **)error;

/**
 * Return reference on message data object which will represent
 * message received from PubNub service
 */
+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(PNDate *)messagePostDate;


#pragma mark - Instance methods

/**
 * Initialize object instance with text and channel
 */
- (id)initWithObject:(id)object forChannel:(PNChannel *)channel;

- (void)setReceiveDate:(PNDate *)receiveDate;


@end