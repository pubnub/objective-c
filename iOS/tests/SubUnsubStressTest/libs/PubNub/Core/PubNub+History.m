/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+History.h"
#import "PNMessageHistoryRequest.h"
#import "NSObject+PNAdditions.h"
#import "PNMessagesHistory.h"
#import "PNServiceChannel.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNCryptoHelper.h"
#import "PubNub+Cipher.h"
#import "PNHelper.h"
#import "PNDate.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (HistoryPrivate)


#pragma mark - Instance methods

/**
 Extension of -requestHistoryForChannel:from:to:limit:reverseHistory:includingTimeToken:withCompletionBlock: and allow specify
 whether handler block should be replaced or not.

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

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as history request will be completed. The block takes five arguments:
 \c messages - array of \b PNMessage instances which represent messages sent to the specified \c channel;
 \c channel - \b PNChannel instance for which history request has been made; \c startDate - \b PNDate instance which represent date
 of the first message from returned list of messages; \c endDate - \b PNDate instance which represent date of the last message
 from returned list of messages; \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes).
 */
- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
          reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;

/**
 Postpone history fetch user request so it will be executed in future.
 
 @note Postpone can be because of few cases: \b PubNub client is in connecting or initial connection state; another request
 which has been issued earlier didn't completed yet.
 
 @param channel
 \b PNChannel instance for which history should be fetched.
 
 @param startDate
 \b PNDate start date after which messages should be fetched from the history storage.
 
 @param endDate
 \b PNDate end date till which messages should be fetched from the history storage.
 
 @param limit
 Maximum number of messages which should be returned in single response.
 
 @param shouldReverseMessageHistory
 Whether messages should be returned in reversed order or not.
 
 @param shouldIncludeTimeToken
 Whether time token for each message should be returned or not.

 @param isMethodCallRescheduled
 In case if value set to \c YES it will mean that method call has been rescheduled and probably there is no handler
 block which client should use for observation notification.

 @param handleBlock
 Handler block which is called by \b PubNub client when history fetching process state changes. Block pass five arguments:
 \c messages - list of \b PNMessage instances which will represent history entries in specified time frame;
 \c channel - \b PNChannel instance for which history fetching has been called; \c startDate - \b PNDate instance which represent
 actual start date from which messages has been fetched; \c endDate - \b PNDate instance which represent
 actual start date till which messages has been fetched; \c error - \b PNError instance which hold information about 
 why history fetching process failed. Always check \a error.code to find out what caused error (check PNErrorCodes header
 file and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human 
 readable description for error).
 */
- (void)postponeRequestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                                   limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
                      includingTimeToken:(BOOL)shouldIncludeTimeToken reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                     withCompletionBlock:(id)handleBlock;


#pragma mark - Misc methods

/**
 * This method will notify delegate about that history loading error occurred
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 
 @param error
 Instance of \b PNError which describes what exactly happened and why this error occurred. \a 'error.associatedObject'
 contains reference on \b PNAccessRightOptions instance which will allow to review and identify what options \b PubNub client tried to apply.
 */
- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (History)


#pragma mark - Class (singleton) methods

+ (void)requestFullHistoryForChannel:(PNChannel *)channel {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:NO];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:nil includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:0 includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [[self sharedInstance] requestHistoryForChannel:channel from:startDate to:endDate limit:limit
                                     reverseHistory:shouldReverseMessageHistory includingTimeToken:shouldIncludeTimeToken
                                withCompletionBlock:handleBlock];
}


#pragma mark - Instance methods

- (void)requestFullHistoryForChannel:(PNChannel *)channel {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:NO];
}

- (void)requestFullHistoryForChannel:(PNChannel *)channel
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:NO withCompletionBlock:handleBlock];
}

- (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestFullHistoryForChannel:channel includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

- (void)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:nil includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:NO];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:NO withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:NO];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:NO
               withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:0 includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:NO];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:NO withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:NO];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:NO
               withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit includingTimeToken:shouldIncludeTimeToken
               withCompletionBlock:nil];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
              includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate
                           limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:NO withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
    
    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken withCompletionBlock:nil];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:shouldReverseMessageHistory
                includingTimeToken:shouldIncludeTimeToken reschedulingMethodCall:NO withCompletionBlock:handleBlock];
}

- (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
          reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.historyFetchAttempt, (channel ? channel : [NSNull null]),
                     (startDate ? startDate : [NSNull null]), (endDate ? endDate : [NSNull null]),
                     @(limit), @(shouldReverseMessageHistory), @(shouldIncludeTimeToken),
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsHistoryDownloadObserver];
            }
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            if (statusCode == 0) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.fetchingHistory, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handleBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsHistoryDownloadObserverWithBlock:handleBlock];
                }
                
                PNMessageHistoryRequest *request = [PNMessageHistoryRequest messageHistoryRequestForChannel:channel
                                                                                                       from:startDate to:endDate limit:limit
                                                                                             reverseHistory:shouldReverseMessageHistory
                                                                                         includingTimeToken:shouldIncludeTimeToken];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.historyFetchImpossible, [self humanReadableStateFrom:self.state]];
                }];
                
                PNError *historyFetchError = [PNError errorWithCode:statusCode];
                historyFetchError.associatedObject = channel;
                
                [self notifyDelegateAboutHistoryDownloadFailedWithError:historyFetchError];
                
                if (handleBlock && !isMethodCallRescheduled) {
                    
                    handleBlock(nil, channel, startDate, endDate, historyFetchError);
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeHistoryFetching, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRequestHistoryForChannel:channel from:startDate to:endDate limit:limit
                                           reverseHistory:shouldReverseMessageHistory includingTimeToken:shouldIncludeTimeToken
                                   reschedulingMethodCall:isMethodCallRescheduled withCompletionBlock:handleBlock];
               }];
    }];
}

- (void)postponeRequestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit
                          reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken
                  reschedulingMethodCall:(BOOL)isMethodCallRescheduled withCompletionBlock:(id)handleBlock {
    
    SEL selector = @selector(requestHistoryForChannel:from:to:limit:reverseHistory:includingTimeToken:reschedulingMethodCall:withCompletionBlock:);
    id handlerBlockCopy = (handleBlock ? [handleBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:channel], [PNHelper nilifyIfNotSet:startDate], [PNHelper nilifyIfNotSet:endDate],
                             @(limit), @(shouldReverseMessageHistory), @(shouldIncludeTimeToken), @(isMethodCallRescheduled),
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Misc methods

- (void)notifyDelegateAboutHistoryDownloadFailedWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.historyDownloadFailed, [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate us able to handle message history download error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didFailHistoryDownloadForChannel:withError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self didFailHistoryDownloadForChannel:error.associatedObject withError:error];
            });
        }
        
        [self sendNotification:kPNClientHistoryDownloadFailedWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Service channel delegate methods

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didReceiveMessagesHistory:(PNMessagesHistory *)history {

    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){

        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

            return @[PNLoggerSymbols.api.didReceiveHistory, [self humanReadableStateFrom:self.state]];
        }];

        if (shouldNotify) {

            // In case if cryptor configured and ready to go, message will be decrypted.
            if (self.cryptoHelper.ready) {

                [history.messages enumerateObjectsUsingBlock:^(PNMessage *message, NSUInteger messageIdx,
                        BOOL *messageEnumeratorStop) {

                    message.message = [self AESDecrypt:message.message];
                }];
            }

            // Check whether delegate can response on history download event or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveMessageHistory:forChannel:startingFrom:to:)]) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.clientDelegate pubnubClient:self didReceiveMessageHistory:history.messages forChannel:history.channel
                                         startingFrom:history.startDate to:history.endDate];
                });
            }

            [self sendNotification:kPNClientDidReceiveMessagesHistoryNotification withObject:history];
        }
    };

    [self checkShouldChannelNotifyAboutEvent:serviceChannel withBlock:^(BOOL shouldNotify) {

        [self handleLockingOperationBlockCompletion:^{

            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)serviceChannel:(PNServiceChannel *)serviceChannel didFailHisoryDownloadForChannel:(PNChannel *)channel
             withError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:channel];
        [self notifyDelegateAboutHistoryDownloadFailedWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleHistoryRequest, [self humanReadableStateFrom:self.state]];
            }];
            
            NSDictionary *options = (NSDictionary *)error.associatedObject;
            [self requestHistoryForChannel:channel from:[options valueForKey:@"startDate"] to:[options valueForKey:@"endDate"]
                                     limit:[[options valueForKey:@"limit"] integerValue]
                            reverseHistory:[[options valueForKey:@"revertMessages"] boolValue]
                        includingTimeToken:[[options valueForKey:@"includeTimeToken"] boolValue]
                    reschedulingMethodCall:YES withCompletionBlock:nil];
        }];
    }
}

#pragma mark -


@end
