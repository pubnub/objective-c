/**
 Extending \b PNChannelEvents class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNChannelEvents.h"


#pragma mark Protected interface methods

@interface PNChannelEvents ()


#pragma mark - Properties


@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSNumber *timeToken;

#pragma mark -


@end
