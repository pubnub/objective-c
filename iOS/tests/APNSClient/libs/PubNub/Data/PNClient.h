#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannel;


/**
 This class allow to represent single remote channel and it's data. This objects used for: presence events,
 where / here now request.

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNClient : NSObject


#pragma mark - Properties

/**
 Stores reference on channel in which this client reside.
 */
@property (nonatomic, readonly, strong) PNChannel *channel;

/**
 Property allow to identify concrete client among other subscribed to the channel.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 Stores data which has been assigned to the client.
 */
@property (nonatomic, readonly, strong) NSDictionary *data;


#pragma mark - Instance methods

/**
 Check whether \b PNClient instance created for \a 'anonymous' record or not.

 @return \c YES if \a 'anonymous' client.
 */
- (BOOL)isAnonymous;

#pragma mark -


@end
