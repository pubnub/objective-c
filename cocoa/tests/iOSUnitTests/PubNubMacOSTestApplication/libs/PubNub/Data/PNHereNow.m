<<<<<<< HEAD
/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNHereNow+Protected.h"
=======
//
//  PNHereNow.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

#import "PNHereNow.h"
>>>>>>> fix-pt65153600


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Externs

/**
 Used for \b PNClient instances in case if client identifier is unknown.
 */
NSString * const kPNAnonymousParticipantIdentifier = @"unknown";


#pragma mark - Public interface methods

@implementation PNHereNow


#pragma mark -
=======
#pragma mark Private interface methods

@interface PNHereNow ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *participants;
@property (nonatomic, assign) unsigned int participantsCount;
@property (nonatomic, strong) PNChannel *channel;


@end


#pragma mark - Public interface methods

@implementation PNHereNow
>>>>>>> fix-pt65153600


@end
