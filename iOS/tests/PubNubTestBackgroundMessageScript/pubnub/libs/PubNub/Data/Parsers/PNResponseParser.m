<<<<<<< HEAD
/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */
=======
//
//  PNChannel.m
//  pubnub
//
//  This class allow to parse response from server
//  into logical units:
//      - update time token
//      - channels on which event occurred in pair with event
//
//
//  Created by moonlight on 1/1/13.
//
//
>>>>>>> fix-pt65153600

#import "PNResponseParser.h"
#import "PNAccessRightsResponseParser+Protected.h"
#import "PNPushNotificationsEnabledChannelsParser.h"
<<<<<<< HEAD
#import "PNClientStateUpdateResponseParser.h"
#import "PNActionResponseParser+Protected.h"
#import "PNOperationStatusResponseParser.h"
#import "PNErrorResponseParser+Protected.h"
#import "PNClientStateResponseParser.h"
#import "PNChannelEventsResponseParser.h"
#import "PNServiceResponseCallbacks.h"
#import "PNTimeTokenResponseParser.h"
#import "PNWhereNowResponseParser.h"
=======
#import "PNHereNowResponseParser+Protected.h"
#import "PNActionResponseParser+Protected.h"
#import "PNOperationStatusResponseParser.h"
#import "PNErrorResponseParser+Protected.h"
#import "PNChannelEventsResponseParser.h"
#import "PNServiceResponseCallbacks.h"
#import "PNTimeTokenResponseParser.h"
>>>>>>> fix-pt65153600
#import "PNHereNowResponseParser.h"
#import "PNActionResponseParser.h"
#import "PNChannelHistoryParser.h"
#import "PNErrorResponseParser.h"
<<<<<<< HEAD
#import "PNResponse+Protected.h"
=======
#import "PNResponse.h"
>>>>>>> fix-pt65153600


// ARC check
#if !__has_feature(objc_arc)
#error PubNub response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Private interface methods
=======
#pragma mark Static

// Stores reference on key which is used to store service name in response
static NSString * const kPNResponseServiceKey = @"service";


#pragma mark - Private interface methods
>>>>>>> fix-pt65153600

@interface PNResponseParser ()


#pragma mark - Class methods

/**
 * Retrieve reference on class of parser which should be used
 * to parse response which arrived from PubNub service
 */
<<<<<<< HEAD
/**
 Retrieve reference on parser class which is able to parse data from \b PNResponse instance.

 @param response
 \b PNResponse instance for which method should return reference on correct parser class.

 @return Class of the parser which is able to parse data from response.
 */
+ (Class)classForResponse:(PNResponse *)response;

#pragma mark -

=======
+ (Class)classForResponse:(PNResponse *)response;

>>>>>>> fix-pt65153600

@end


#pragma mark - Public interface methods

@implementation PNResponseParser


#pragma mark - Class methods

+ (PNResponseParser *)parserForResponse:(PNResponse *)response {

    return [[[self classForResponse:response] alloc] initWithResponse:response];
}

+ (Class)classForResponse:(PNResponse *)response {

    Class parserClass = nil;

    if ([response.response isKindOfClass:[NSArray class]]) {

        NSArray *responseData = response.response;
        if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.pushNotificationEnabledChannelsCallback]) {

            parserClass = [PNPushNotificationsEnabledChannelsParser class];
        }
        else {

<<<<<<< HEAD
            // Check whether there is only single item in array which will mean that this is time token.
=======
            // Check whether there is only single item in array which will mean
            // that this is time token
>>>>>>> fix-pt65153600
            if ([responseData count] == 1) {

                parserClass = [PNTimeTokenResponseParser class];
            }
<<<<<<< HEAD
            // Check whether first element in array is array as well (which will mean that response holds set of
            // events for set of channels or at least one channel).
            else if ([[responseData objectAtIndex:0] isKindOfClass:[NSArray class]]) {

                // Check whether there is 3 elements in response array or not (depending on whether two last elements
                // is number or not, this will mean whether response is for history or not).
                if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.messageHistoryCallback]) {

                    parserClass = [PNChannelHistoryParser class];
                }
                else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.subscriptionCallback]) {
=======
            // Check whether first element in array is array as well
            // (which will mean that response holds set of events for
            // set of channels or at least one channel)
            else if ([[responseData objectAtIndex:0] isKindOfClass:[NSArray class]]) {

                // Check whether there is 3 elements in response array or not
                // (depending on whether two last elements is number or not,
                // this will mean whether response is for history or not)
                if ([responseData count] == 3 &&
                    [[responseData objectAtIndex:1] isKindOfClass:[NSNumber class]] &&
                    [[responseData objectAtIndex:2] isKindOfClass:[NSNumber class]]) {

                    parserClass = [PNChannelHistoryParser class];
                }
                else {
>>>>>>> fix-pt65153600

                    parserClass = [PNChannelEventsResponseParser class];
                }
            }
            // Looks like this is response with status message
            else {

                parserClass = [PNOperationStatusResponseParser class];
            }
        }
    }
    else if ([response.response isKindOfClass:[NSDictionary class]]){

        NSDictionary *responseData = response.response;

<<<<<<< HEAD
        // Check whether response arrived as result of specific action execution.
        if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.leaveChannelCallback] ||
            [responseData objectForKey:kPNResponseActionKey]) {

            parserClass = [PNActionResponseParser class];
        }
        // Check whether result is result for "State retrieval" request or not.
        else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.stateRetrieveCallback]) {

            parserClass = [PNClientStateResponseParser class];
        }
        // Check whether result is result for "State update" request or not.
        else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.stateUpdateCallback]) {

            parserClass = [PNClientStateUpdateResponseParser class];
        }
        // Check whether result is result for "Here now" request execution or not.
        else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.channelParticipantsCallback]) {

            parserClass = [PNHereNowResponseParser class];
        }
        // Check whether result is result for "Where now" request execution or not.
        else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.participantChannelsCallback]) {

            parserClass = [PNWhereNowResponseParser class];
        }
        // Check whether response arrived as result of channel access rights change or not.
        else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.channelAccessRightsChangeCallback] ||
                 [response.callbackMethod isEqualToString:PNServiceResponseCallbacks.channelAccessRightsAuditCallback]) {

            if (![response isErrorResponse]) {

=======
        // Check whether response arrived as result of specific action execution
        if ([responseData objectForKey:kPNResponseActionKey]) {

            parserClass = [PNActionResponseParser class];
        }
        // Check whether result is result for "Here now" request execution or not
        else if ([responseData objectForKey:kPNResponseUUIDKey] &&
                 [responseData objectForKey:kPNResponseOccupancyKey]) {

            parserClass = [PNHereNowResponseParser class];
        }
        // Check whether response arrived as result of channel access rights change or not
        else if ([responseData objectForKey:kPNResponsePayloadKey] && [responseData objectForKey:kPNResponseServiceKey] &&
                ![responseData objectForKey:kPNResponseErrorMessageKey]) {
            
            if ([[responseData valueForKey:kPNResponseServiceKey] isEqualToString:kPNAccessServiceName]) {
                
>>>>>>> fix-pt65153600
                parserClass = [PNAccessRightsResponseParser class];
            }
        }
        // Check whether error report response arrived
        else if ([responseData objectForKey:kPNResponseErrorMessageKey]) {

            parserClass = [PNErrorResponseParser class];
        }
    }
<<<<<<< HEAD

    // Looks like server sent malformed JSON string (there is no array or dictionary at top level) and we should
    // treat it as error.
    if (parserClass == nil) {
=======
    // Looks like server sent malformed JSON string (there is no array or dictionary at top level) and we should treat it as error.
    else {
>>>>>>> fix-pt65153600
        
        parserClass = [PNErrorResponseParser class];
    }


    return parserClass;
}


#pragma mark - Instance methods

<<<<<<< HEAD
=======
/**
 * Returns reference on parsed data
 * (template method, actual implementation is in
 * subclasses)
 */
>>>>>>> fix-pt65153600
- (id)parsedData {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);


    return nil;
}

#pragma mark -


@end
