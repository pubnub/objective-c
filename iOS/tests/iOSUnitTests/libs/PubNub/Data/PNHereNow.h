#import <Foundation/Foundation.h>


#pragma mark - Class forward

@class PNChannel;


/**
 This class allow to get access ro result of 'Where now' API and find out to which channel client (specified by \c
 identifier property) subscribed at this moment.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNHereNow : NSObject


#pragma mark Properties

/**
 Stores reference on list of \b PNClient instances.
 */
@property (nonatomic, readonly, strong) NSArray *participants;

/**
 Stores how much participants have been found subscribed on concrete channel.
 */
@property (nonatomic, readonly, assign) unsigned long participantsCount;

/**
 Stores reference on channel inside of which \b PubNub client searched for participants (clients).
 */
@property (nonatomic, readonly, strong) PNChannel *channel;

#pragma mark -


@end
