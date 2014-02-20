#import "PNChannelEvents+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel events must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNChannelEvents ()


#pragma mark - Properties

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSNumber *timeToken;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNChannelEvents


@end