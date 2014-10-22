#import "PubNub.h"

/**
 Base class extension which provide methods for history fetching.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (History)


#pragma mark - Class (singleton) methods

/**
 Fetch all messages from history for specified channel.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a +requestFullHistoryForChannel: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a +requestFullHistoryForChannel: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a +requestFullHistoryForChannel:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel; 
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify end time token for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be 
 returned.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from: and allow to specify maximum number of messages which should be
 returned for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit: and allow to specify whether message time token should be
 included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:includingTimeToken: and allow to specify history request 
 handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to: and allow to specify maximum number of messages which should be
 returned for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit: and allow to specify whether message time token should be
 included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit:includingTimeToken: and allow to specify history request
 handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit: and allow to specify whether messages order in history response
 should be inverted or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:reverseHistory: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:reverseHistory: and allow to specify whether message 
 time token should be included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:limit:reverseHistory:includingTimeToken: and allow to specify 
 history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit: and allow to specify whether messages order in history response
 should be inverted or not.
 
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
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit:reverseHistory: and allow to specify history request handling block.
 
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
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:ot:limit:reverseHistory: and allow to specify whether message
 time token should be included or not.
 
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
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a +requestHistoryForChannel:from:to:limit:reverseHistory:includingTimeToken: and allow to specify
 history request handling block.
 
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
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;


#pragma mark - Instance methods

/**
 Fetch all messages from history for specified channel.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 */
- (void)requestFullHistoryForChannel:(PNChannel *)channel;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a -requestFullHistoryForChannel: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestFullHistoryForChannel:(PNChannel *)channel withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a -requestFullHistoryForChannel: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
- (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch all messages from history for specified channel.
 
 @code
 @endcode
 This method extends \a -requestFullHistoryForChannel:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel; 
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from: and allow to specify end time token for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be 
 returned.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to: and allow to specify whether message time token should be included
 or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:includingTimeToken: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from: and allow to specify maximum number of messages which should be
 returned for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit: and allow to specify whether message time token should be
 included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit:includingTimeToken: and allow to specify history request
 handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to: and allow to specify maximum number of messages which should be
 returned for history request.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:limit: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:limit: and allow to specify whether message time token should be
 included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:limit:includingTimeToken: and allow to specify history request
 handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param endDate
 \b PNDate instance which represent time token which is used to specify concrete time frame from which messages should be
 returned.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit: and allow to specify whether messages order in history response
 should be inverted or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit:reverseHistory: and allow to specify history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit:reverseHistory: and allow to specify whether message
 time token should be included or not.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel starting from specified date and till current time.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:limit:reverseHistory:includingTimeToken: and allow to specify
 history request handling block.
 
 @param channel
 \b PNChannel instance for which \b PubNub client should fetch messages history.
 
 @param startDate
 \b PNDate instance which represent time token starting from which messages should be returned from history.
 
 @param limit
 Maximum number of messages which should be pulled out from history.
 
 @param shouldReverseMessageHistory
 If set to \c YES all older messages will come first in response. Default value is \b NO.
 
 @param shouldIncludeTimeToken
 Whether message post date (time token) should be added to the message in history response.
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:limit: and allow to specify whether messages order in history response
 should be inverted or not.
 
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
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:limit:reverseHistory: and allow to specify history request handling block.
 
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
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:ot:limit:reverseHistory: and allow to specify whether message
 time token should be included or not.
 
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
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken;

/**
 Fetch messages from history for specified channel in defined time frame.
 
 @code
 @endcode
 This method extends \a -requestHistoryForChannel:from:to:limit:reverseHistory:includingTimeToken: and allow to specify
 history request handling block.
 
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
 
 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

#pragma mark -


@end
