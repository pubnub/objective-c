//
//  PNHereNow.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

#import "PNHereNow.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNHereNow ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *participants;
@property (nonatomic, assign) unsigned int participantsCount;
@property (nonatomic, strong) PNChannel *channel;


@end


#pragma mark - Public interface methods

@implementation PNHereNow


@end
