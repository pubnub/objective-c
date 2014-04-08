//
//  PNDataManager.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNConfiguration, PNChannel;


@interface PNDataManager : NSObject


#pragma mark - Properties

// Stores reference on PubNub client configuration
@property (nonatomic, copy) PNConfiguration *configuration;

// Stores reference on list of channels on which client is subscribed
@property (nonatomic, readonly, strong) NSArray *subscribedChannelsList;

// Stores reference on dictionary which stores number of unreaded/unseen events
// on channel(s)
@property (nonatomic, strong) NSMutableDictionary *events;

// Stores reference on current channel
@property (nonatomic, strong) PNChannel *currentChannel;

// Stores reference on current chat history
@property (nonatomic, strong) NSString *currentChannelChat;

/**
 Stores reference on device push notification token which has been received during registration with APNS.
 */
@property (nonatomic, strong) NSData *devicePushToken;


#pragma mark - Class methods

+ (PNDataManager *)sharedInstance;


#pragma mark - Instance methods

/**
 Allow to parse launch options / URL in case when application has been used with \b supported URL scheme, which allow
 to pass application options.
 */
- (BOOL)handleOpenWithURL:(NSURL *)url;

/**
 * Allow to update client security option
 */
- (void)updateSSLOption:(BOOL)shouldEnableSSL;

/**
 * Retrieve number of new events on specified channel
 */
- (NSUInteger)numberOfEventsForChannel:(PNChannel *)channel;

/**
 * Clear chat history for current channel
 */
- (void)clearChatHistory;

/**
 Clean up all channels on which application subscrbed at this moment.
 */
- (void)clearChannels;


#pragma mark -


@end
