/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNResponseParser.h"
#import "PNAccessRightsResponseParser+Protected.h"
#import "PNPushNotificationsEnabledChannelsParser.h"
#import "PNClientStateUpdateResponseParser.h"
#import "PNActionResponseParser+Protected.h"
#import "PNChannelHistoryParser+Protected.h"
#import "PNOperationStatusResponseParser.h"
#import "PNErrorResponseParser+Protected.h"
#import "PNChannelEventsResponseParser.h"
#import "PNClientStateResponseParser.h"
#import "PNServiceResponseCallbacks.h"
#import "PNTimeTokenResponseParser.h"
#import "PNWhereNowResponseParser.h"
#import "PNHereNowResponseParser.h"
#import "PNActionResponseParser.h"
#import "PNErrorResponseParser.h"
#import "PNResponse+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNResponseParser ()


#pragma mark - Class methods

/**
 * Retrieve reference on class of parser which should be used
 * to parse response which arrived from PubNub service
 */
/**
 Retrieve reference on parser class which is able to parse data from \b PNResponse instance.

 @param response
 \b PNResponse instance for which method should return reference on correct parser class.

 @return Class of the parser which is able to parse data from response.
 */
+ (Class)classForResponse:(PNResponse *)response;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNResponseParser


#pragma mark - Class methods

+ (PNResponseParser *)parserForResponse:(PNResponse *)response {
    
    if ([response.response isKindOfClass:[NSArray class]] && [response.callbackMethod isEqualToString:PNServiceResponseCallbacks.messageHistoryCallback] &&
        [PNChannelHistoryParser isErrorResponse:response]) {
        
        if ([PNChannelHistoryParser errorMessage:response]) {
            
            response = [PNResponse errorResponseWithMessage:[PNChannelHistoryParser errorMessage:response]];
        }
    }
    

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

            // Check whether there is only single item in array which will mean that this is time token.
            if ([responseData count] == 1) {

                parserClass = [PNTimeTokenResponseParser class];
            }
            // Check whether first element in array is array as well (which will mean that response holds set of
            // events for set of channels or at least one channel).
            else if ([[responseData objectAtIndex:0] isKindOfClass:[NSArray class]]) {

                // Check whether there is 3 elements in response array or not (depending on whether two last elements
                // is number or not, this will mean whether response is for history or not).
                if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.messageHistoryCallback]) {
                    
                    parserClass = [PNChannelHistoryParser class];
                }
                else if ([response.callbackMethod isEqualToString:PNServiceResponseCallbacks.subscriptionCallback]) {

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

                parserClass = [PNAccessRightsResponseParser class];
            }
        }
        // Check whether error report response arrived
        else if ([responseData objectForKey:kPNResponseErrorMessageKey]) {

            parserClass = [PNErrorResponseParser class];
        }
    }

    // Looks like server sent malformed JSON string (there is no array or dictionary at top level) and we should
    // treat it as error.
    if (parserClass == nil) {
        
        parserClass = [PNErrorResponseParser class];
    }


    return parserClass;
}


#pragma mark - Instance methods

- (id)parsedData {

    NSAssert1(0, @"%s SHOULD BE RELOADED IN SUBCLASSES", __PRETTY_FUNCTION__);


    return nil;
}

#pragma mark -


@end
