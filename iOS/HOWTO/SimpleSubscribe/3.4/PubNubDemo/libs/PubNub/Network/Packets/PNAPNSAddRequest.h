//
//  PNBaseRequest.h
//  pubnub
//
//  This request object is used to describe
//  the APNSAdd call.
//
//
//  Created by Geremy Cohen on 05/08/13.
//
//

#import "PNBaseRequest.h"

#pragma mark Class forward

@class PNChannel;


@interface PNAPNSAddRequest : PNBaseRequest


#pragma mark - Class methods

/**
 * Returns reference on configured history download request
 * which will take into account default values for certain
 * parameters (if passed) to change itself to load full or
 * partial history
 */

+ (PNAPNSAddRequest *)enableAPNSOnChannel:(PNChannel *)channel
        forDevice:(NSString *)deviceID;

#pragma mark - Instance methods

/**
 * Returns reference on initialized request which will take
 * into account all special cases which depends on the values
 * which is passed to it
 */
- (id)initForChannel:(PNChannel *)channel
        forDevice:(NSString *)deviceID;

#pragma mark -


@end