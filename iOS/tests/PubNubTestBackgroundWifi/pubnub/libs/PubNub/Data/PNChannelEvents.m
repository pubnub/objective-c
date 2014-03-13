<<<<<<< HEAD
/**
 This class allow to describe set of events which occurred on one of the channels and passed to the user.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
=======
//
//  PNChannelEvents.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

>>>>>>> fix-pt65153600

#import "PNChannelEvents+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel events must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Public interface methods

@implementation PNChannelEvents

=======
#pragma mark Private interface methods

@interface PNChannelEvents ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSNumber *timeToken;
>>>>>>> fix-pt65153600

#pragma mark -


@end
<<<<<<< HEAD
=======


#pragma mark - Public interface methods

@implementation PNChannelEvents


@end
>>>>>>> fix-pt65153600
