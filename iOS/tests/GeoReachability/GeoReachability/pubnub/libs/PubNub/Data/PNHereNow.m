/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNHereNow+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Externs

/**
 Used for \b PNClient instances in case if client identifier is unknown.
 */
NSString * const kPNAnonymousParticipantIdentifier = @"unknown";


#pragma mark - Public interface methods

@implementation PNHereNow


#pragma mark -


@end
