//
//  PNMessage.h
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


#import <Foundation/Foundation.h>

#pragma mark Class forward

@class PNChannelGroup, PNChannel, PNDate;


#pragma mark - Public interface declaration

@interface PNMessage : NSObject


#pragma mark - Properties

// Stores reference on channel to which this message
// should be sent
@property (nonatomic, readonly, strong) PNChannel *channel;

/**
 @brief Stores reference on channel group with channel for whic message has been received.
 
 @since 3.7.0
 */
@property (nonatomic, readonly, strong) PNChannelGroup *channelGroup;

// Stores reference on message body
@property (nonatomic, readonly, strong) id message;

// Stores reference on date when this message was received
@property (nonatomic, readonly, strong) PNDate *receiveDate;

// Stores reference on date when this message has been sent to the target channel.
@property (nonatomic, readonly, strong) PNDate *date;

#pragma mark - Class methods

/**
 Load saved \b PNMessage instance from file specified by parameter.

 @param messageFilePath
 Full path to the file, which should represent serialized \b PNMessage instance.

 @return Reference on \b PNMessage instance initialized from file or \a 'nil' if wrong file has been provided.
 */
+ (PNMessage *)messageFromFileAtPath:(NSString *)messageFilePath;


#pragma mark - Instance methods

/**
 Serialized \b PNMessage and save it into file at specified path.

 @param messageStoreFilePath
 Full path to the location where serialized instance should be saved.

 @note By default this method will override file stored at specified path (if there is some).

 @return Whether serialized instance written to the file at specified path or not.
 */
- (BOOL)writeToFileAtPath:(NSString *)messageStoreFilePath;


#pragma mark -


@end
