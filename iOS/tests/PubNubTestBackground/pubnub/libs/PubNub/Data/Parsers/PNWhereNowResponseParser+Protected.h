/**
 Extending \b PNWhereNowResponseParser class with properties which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNWhereNowResponseParser.h"


#pragma mark Static

/**
 Stores reference on key under which list of channels is stored.
 */
static NSString * const kPNResponseChannelsKey = @"channels";


#pragma mark - Class forward

@class PNWhereNow;


#pragma mark - Private interface declaration

@interface PNWhereNowResponseParser ()


#pragma mark - Properties

/**
 Stores parsed information for participant channels response.
 */
@property (nonatomic, strong) PNWhereNow *whereNow;

#pragma mark -


@end
