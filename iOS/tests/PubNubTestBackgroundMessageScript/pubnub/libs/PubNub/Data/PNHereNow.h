<<<<<<< HEAD
#pragma mark - Class forward

@class PNChannel;


/**
 This class allow to get access ro result of 'Where now' API and find out to which channel client (specified by \c
 identifier property) subscribed at this moment.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
=======
//
//  PNHereNow.h
// 
//
//  Created by moonlight on 1/15/13.
//
//


#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNChannel;


>>>>>>> fix-pt65153600
@interface PNHereNow : NSObject


#pragma mark Properties

<<<<<<< HEAD
/**
 Stores reference on list of \b PNClient instances.
 */
@property (nonatomic, readonly, strong) NSArray *participants;

/**
 Stores how much participants have been found subscribed on concrete channel.
 */
@property (nonatomic, readonly, assign) unsigned int participantsCount;

/**
 Stores reference on channel inside of which \b PubNub client searched for participants (clients).
 */
=======
// Stores reference on list of participants
// uuid
@property (nonatomic, readonly, strong) NSArray *participants;

// Stores reference on how many participants in
// the channel
@property (nonatomic, readonly, assign) unsigned int participantsCount;

// Stores reference on channel which this 'Here now'
// information was generated on PubNub service by client
// request
>>>>>>> fix-pt65153600
@property (nonatomic, readonly, strong) PNChannel *channel;

#pragma mark -


@end
