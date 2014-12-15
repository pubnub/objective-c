#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNDate;


/**
 @brief Data feed object requirements.
 
 @discussion Protocol which dictates requirements which should be implemented by classes which would like to represent
 remote objects for data feed.
 
 @author Sergey Mamontov
 @since 3.7.0
 @copyright © 2009-2014 PubNub, Inc.
 */
@protocol PNChannelProtocol <NSObject>


#pragma mark - Properties

///------------------------------------------------
/// @name Base information
///------------------------------------------------

/**
 @brief Name for remote data feed object.
 
 @since 3.7.0
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 @brief Last data feed update time token.
 
 @since 3.7.0
 */
@property (nonatomic, readonly, copy) NSString *updateTimeToken;

/**
 Stores whether channel represents group of channels or not.
 */
@property (nonatomic, readonly, getter = isChannelGroup) BOOL channelGroup;


///------------------------------------------------
/// @name Presence information
///------------------------------------------------

/**
 @brief Date when presence information has been updated.
 
 @since 3.7.0
 */
@property (nonatomic, readonly, strong) PNDate *presenceUpdateDate;

/**
 @brief Number of subscribers on remote data feed.
 
 @discussion This value filled with data from presence API usage and from presence update events from feed.
 
 @since 3.7.0
 */
@property (nonatomic, readonly, assign) NSUInteger participantsCount;

/**
 @brief List of \b PNClient instances
 
 @discussion Each \b PNClient instance represent single subscriber on feed. But number of subscribers and value stored
 in \c participantsCount may be different.
 
 @since 3.7.0
 */
@property (nonatomic, readonly) NSArray *participants;

#pragma mark -


@end
