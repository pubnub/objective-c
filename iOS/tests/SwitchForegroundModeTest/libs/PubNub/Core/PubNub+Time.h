#import "PubNub.h"

/**
 Base class extension which provide methods to get server time.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (Time)


#pragma mark - Class (singleton) methods

/**
 Request time token from \b PubNub service. Service will respond with unixtimestamp (UTC+0).
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub requestServerTimeToken];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
 
     // PubNub client successfully received time token.
 }
 
 - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to receive time token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addTimeTokenReceivingObserver:self withCallbackBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 @see +requestServerTimeTokenWithCompletionBlock:
 */
+ (void)requestServerTimeToken;

/**
 Request time token from \b PubNub service. Service will respond with unixtimestamp (UTC+0).
 
 @code
 @endcode
 This method extendeds \a +requestServerTimeToken and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
 
     // PubNub client successfully received time token.
 }
 
 - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to receive time token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addTimeTokenReceivingObserver:self withCallbackBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 @see +requestServerTimeToken
 */
+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;


#pragma mark - Instance methods

/**
 Request time token from \b PubNub service. Service will respond with unixtimestamp (UTC+0).
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestServerTimeToken];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
 
     // PubNub client successfully received time token.
 }
 
 - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to receive time token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addTimeTokenReceivingObserver:self withCallbackBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 @see -requestServerTimeTokenWithCompletionBlock:
 */
- (void)requestServerTimeToken;

/**
 Request time token from \b PubNub service. Service will respond with unix timestamp (UTC+0).
 
 @code
 @endcode
 This method extends \a -requestServerTimeToken and allow to specify subscription process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [pubNub connect];
 [pubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
 
     // PubNub client successfully received time token.
 }
 
 - (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
 
     // PubNub client did fail to receive time token.
 }
 @endcode
 
 There is also way to observe connection state from any place in your application using  \b PNObservationCenter:
 @code
 [pubNub.observationCenter addTimeTokenReceivingObserver:self withCallbackBlock:^(NSNumber *timeToken, PNError *error) {
 
     if (error == nil) {
 
         // PubNub client successfully received time token.
     }
     else {
 
         // PubNub client did fail to receive time token.
     }
 }];
 @endcode
 
 @see -requestServerTimeToken
 */
- (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success;

#pragma mark -


@end
