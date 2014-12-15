//
//  PNMessageHistoryRequest.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel, PNDate;


@interface PNMessageHistoryRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Create and initialize request which will allow to pull out messages from specified channel history.

 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.

 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.

 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.

 @param limit
 Maximum number of messages which should be pulled out from history.

 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.

 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.

 @since 3.4.0
 @updated 3.6.0

 @return Ready to use \b PNMessageHistoryRequest instance.
 */
+ (PNMessageHistoryRequest *)messageHistoryRequestForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                                       limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessagesInResponse
                                          includingTimeToken:(BOOL)shouldIncludeTimeToken;


#pragma mark - Instance methods

/**
 Initialize request which will allow to pull out messages from specified channel history.

 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.

 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.

 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.

 @param limit
 Maximum number of messages which should be pulled out from history.

 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.

 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.

 @since 3.4.0
 @updated 3.6.0

 @return Initialized \b PNMessageHistoryRequest instance.
 */
- (id)initForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
      reverseHistory:(BOOL)shouldReverseMessagesInResponse includingTimeToken:(BOOL)shouldIncludeTimeToken;

#pragma mark -


@end
