/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+History.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNHelpers.h"
#import "PNAES.h"
#import "PNLog.h"


#pragma mark Private interface

@interface PubNub (HistoryPrivate)


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'history' API
         group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'publish' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedHistoryResponse:(id)response;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation PubNub (History)


#pragma mark - Full history

- (void)historyForChannel:(NSString *)channel withCompletion:(PNCompletionBlock)block {
    
    [self historyForChannel:channel start:nil end:nil withCompletion:block];
}


#pragma mark - History in specified frame

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
           withCompletion:(PNCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:100 withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit withCompletion:(PNCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit includeTimeToken:NO
             withCompletion:block];
}


#pragma mark - Hisotry in frame with extended response

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:100
           includeTimeToken:shouldIncludeTimeToken withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit reverse:NO
           includeTimeToken:shouldIncludeTimeToken withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder
           withCompletion:(PNCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit
                    reverse:shouldReverseOrder includeTimeToken:NO withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNCompletionBlock)block {
    
    // Swap time frame dates if required.
    if ([startDate integerValue] > [endDate integerValue]) {
        
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    // Clamp limit to allowed values.
    limit = MIN(limit, (NSUInteger)100);

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSMutableDictionary *parameters = [@{@"count": @(limit)} mutableCopy];
        parameters[@"reverse"] = (shouldReverseOrder ? @"true" : @"false");
        parameters[@"include_token"] = (!shouldIncludeTimeToken ? @"true" : @"false");
        if (startDate) {
            
            parameters[@"start"] = startDate;
        }
        if (endDate) {
            
            parameters[@"end"] = endDate;
        }
        NSMutableString *path = [NSMutableString stringWithFormat:@"/v2/history/sub-key/%@/channel/%@",
                                 subscribeKey, [PNString percentEscapedString:channel]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:PNHistoryOperation
                                         withCompletion:nil];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedHistoryResponse:rawData];
        };
        request.reportBlock = block;
        
        DDLogAPICall(@"<PubNub> %@ for '%@' channel%@%@ with %@ limit%@.",
                     (shouldReverseOrder ? @"Reversed history" : @"History"), (channel?: @"<error>"),
                     (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
                     (endDate ? [NSString stringWithFormat:@" to %@", endDate] : @""), @(limit),
                     (shouldIncludeTimeToken ? @" (including message time tokens)" : @""));

        // Ensure what all required fields passed before starting processing.
        if ([channel length]) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Channel not specified.";
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}


#pragma mark - Processing

- (NSDictionary *)processedHistoryResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for history request.
    if ([response isKindOfClass:[NSArray class]] && [(NSArray *)response count] == 3) {
        
        NSDictionary *data = @{@"start":(NSArray *)response[1], @"end":(NSArray *)response[2],
                               @"messages":[NSMutableArray new]};
        [(NSArray *)response[0] enumerateObjectsUsingBlock:^(id messageObject,
                                                             NSUInteger messageObjectIdx,
                                                             BOOL *messageObjectEnumeratorStop) {
            
            NSNumber *timeToken = nil;
            id message = messageObject;
            
            // Check whether history response returned with 'timetoken' or not.
            if ([messageObject isKindOfClass:[NSDictionary class]] &&
                messageObject[@"message"] && messageObject[@"timetoken"]) {
                
                timeToken = messageObject[@"timetoken"];
                message = messageObject[@"message"];
            }
            
            // Try decrypt message if possible.
            if ([self.cipherKey length] && [message isKindOfClass:[NSString class]]) {
                
                NSError *decryptionError;
                NSData *eventData = [PNAES decrypt:message withKey:self.cipherKey
                                          andError:&decryptionError];
                if (!decryptionError) {
                    
                    message = [[NSString alloc] initWithData:eventData
                                                    encoding:NSUTF8StringEncoding];

                    // In case if decrypted message (because of error suppression) is equal to
                    // original message, there is no need to retry JSON de-serialization.
                    if (![message isEqualToString:messageObject]) {
                        
                        message = [PNJSON JSONObjectFrom:message withError:nil];
                    }
                }
                else {

                    DDLogAESError(@"<PubNub> History entry decryption error: %@", decryptionError);
                }
            }

            if (message) {

                message = (timeToken ? @{@"message":message, @"tt":timeToken} : message);
                [data[@"messages"] addObject:message];
            }
        }];
        processedResponse = data;
    }
    
    
    return [processedResponse copy];
}

#pragma mark -


@end
