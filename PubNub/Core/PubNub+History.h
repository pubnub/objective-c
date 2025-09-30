#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNHistoryMessagesCountRequest.h>
#import <PubNub/PNHistoryMessagesDeleteRequest.h>
#import <PubNub/PNHistoryFetchRequest.h>

// Response
#import <PubNub/PNMessageCountResult.h>
#import <PubNub/PNHistoryResult.h>

// Deprecated
#import <PubNub/PNDeleteMessageAPICallBuilder.h>
#import <PubNub/PNMessageCountAPICallBuilder.h>
#import <PubNub/PNHistoryAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Message Persistence` APIs.
///
/// Set of API which allow fetching events which has been moved from remote data object live feed to persistent storage.
@interface PubNub (History)


#pragma mark - Message persistence API builder interdace (deprecated)

/// History / storage API access builder.
@property (nonatomic, readonly, strong) PNHistoryAPICallBuilder * (^history)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// History / storage manipulation API access builder.
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder * (^deleteMessage)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// Storage messages count audition API call builder.
@property (nonatomic, readonly, strong) PNMessageCountAPICallBuilder * (^messageCounts)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Full history

/// Fetch message history for channels.
///
/// #### Example:
/// ```objc
/// PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[@"channel-a", @"channel-b"]];
///
/// [self.client fetchHistoryWithRequest:request completion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         //   `result.data.start` - oldest message time stamp in response
///         //   `result.data.end` - newest message time stamp in response
///         //   `result.data.messages` - list of messages
///     } else {
///         // Handle message history download error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to retrieve channels history.
///   - block: History retrieve request completion block.
- (void)fetchHistoryWithRequest:(PNHistoryFetchRequest *)request completion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(fetchHistoryWithRequest(_:completion:));

/// Allow to fetch up to **100** events from specified `channel`'s events storage.
///
/// #### Example:
/// ```objc
/// [self.client historyForChannel:@"storage" withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of messages
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch up to **100** events from specified `channel`'s events storage including `metadata` which has been
/// sent along with messages.
///
/// #### Example:
/// ```objc
/// [self.client historyForChannel:@"storage" 
///                   withMetadata:YES
///                     completion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Fetched data available here:
///        //   `result.data.channels` - dictionary with single key (name of requested channel) and list of dictionaries
///        //                            as value. Each entry will include two keys: `message` - for body and `metadata`
///        //                            for meta which has been added during message publish.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - shouldIncludeMetadata: Whether event metadata should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
             withMetadata:(BOOL)shouldIncludeMetadata
               completion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:withMetadata:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch up to **100** events from specified `channel`'s events storage including `actions` which has been 
/// added to messages.
///
/// #### Example:
/// ```objc
/// [self.client historyForChannel:@"chat" 
///             withMessageActions:YES
///                     completion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Fetched data available here:
///        //   `result.data.channels` - dictionary with single key (name of requested channel) and list of
///        //                            dictionaries.
///        //                            Each entry will include two keys: `message` - for body and `actions` for list
///        //                            of added actions.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - shouldIncludeMessageActions: Whether event actions should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
       withMessageActions:(BOOL)shouldIncludeMessageActions
               completion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:withMessageActions:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch up to **100** events from specified `channel`'s events storage including message `meta` and `actions`
/// which has been added to messages.
///
/// #### Example:
/// ```objc
/// [self.client historyForChannel:@"chat" 
///                   withMetadata:YES
///                 messageActions:YES
///                     completion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Fetched data available here:
///        //   `result.data.channels` - dictionary with single key (name of requested channel) and list of
///        //                            dictionaries. Each entry will include three keys: `message` - for body,
///        //                            `metadata` for meta which has been added during message publish and `actions`
///        //                            for list of added actions.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - shouldIncludeMetadata: Whether event metadata should be included in response or not.
///   - shouldIncludeMessageActions: Whether event actions should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
             withMetadata:(BOOL)shouldIncludeMetadata
           messageActions:(BOOL)shouldIncludeMessageActions
               completion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:withMetadata:messageActions:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");


#pragma mark - History in specified frame

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Handle downloaded history using:
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of messages
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame including `metadata` which has
/// been sent along with messages.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///                includeMetadata:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Fetched data available here:
///        //   `result.data.channels` - dictionary with single key (name of requested channel) and list of
///        //                            dictionaries. Each entry will include two keys: `message` - for body and
///        //                            `metadata` for meta which has been added during message publish.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - shouldIncludeMetadata: Whether event metadata should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
          includeMetadata:(BOOL)shouldIncludeMetadata
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:includeMetadata:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame including `actions` which has
/// been added to messages.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///          includeMessageActions:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Fetched data available here:
///        //   `result.data.channels` - dictionary with single key (name of requested channel) and list of
///        //                            dictionaries. Each entry will include two keys: `message` - for body and
///        //                            `actions` for list of added actions.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - shouldIncludeMessageActions: Whether event actions should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
    includeMessageActions:(BOOL)shouldIncludeMessageActions
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:includeMessageActions:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame including message `meta` and
/// `actions` which has been added to messages.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///                includeMetadata:YES
///          includeMessageActions:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Fetched data available here:
///        //   `result.data.channels` - dictionary with single key (name of requested channel) and list of
///        //                            dictionaries. Each entry will include three keys: `message` - for body,
///        //                            `metadata` for meta which has been added during message publish and `actions`
///        //                            for list of added actions.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - shouldIncludeMetadata: Whether event metadata should be included in response or not.
///   - shouldIncludeMessageActions: Whether event actions should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
          includeMetadata:(BOOL)shouldIncludeMetadata
    includeMessageActions:(BOOL)shouldIncludeMessageActions
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:includeMetadata:includeMessageActions:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///                          limit:50
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Handle downloaded history using:
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of messages
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - limit: Maximum number of events which should be returned in response (not more then **100**).
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
                    limit:(NSUInteger)limit
           withCompletion:(PNHistoryCompletionBlock)block 
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");


#pragma mark - History in frame with extended response

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///               includeTimeToken:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Handle downloaded history using:
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of dictionaries. Each entry will include two keys: `message` - for body
///        //                            and `timetoken` for date when message has been sent.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - shouldIncludeTimeToken: Whether event dates (time tokens) should be included in response or not.
///   - block: History pull completion block which.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block 
    NS_SWIFT_NAME(historyForChannel(_:start:end:includeTimeToken:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage"
///                          start:startDate
///                            end:endDate
///                          limit:35 includeTimeToken:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Handle downloaded history using:
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of dictionaries. Each entry will include two keys: `message` - for body
///        //                            and `timetoken` for date when message has been sent.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - limit: Maximum number of events which should be returned in response (not more then **100**).
///   - shouldIncludeTimeToken: Whether event dates (time tokens) should be included in response or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
                    limit:(NSUInteger)limit
         includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:includeTimeToken:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///                          limit:35
///                        reverse:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Handle downloaded history using:
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of messages
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - limit: Maximum number of events which should be returned in response (not more then **100**).
///   - shouldReverseOrder: Whether events order in response should be reversed or not.
///   - block: History pull completion block.
- (void)historyForChannel:(NSString *)channel
                    start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate
                    limit:(NSUInteger)limit
                  reverse:(BOOL)shouldReverseOrder
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:reverse:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");

/// Allow to fetch events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client historyForChannel:@"storage" 
///                          start:startDate
///                            end:endDate
///                          limit:35
///                        reverse:YES
///               includeTimeToken:YES
///                 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///        // Handle downloaded history using:
///        //   `result.data.start` - oldest message time stamp in response
///        //   `result.data.end` - newest message time stamp in response
///        //   `result.data.messages` - list of dictionaries. Each entry will include two keys: `message` - for body
///        //                            and `timetoken` for date when message has been sent.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel for which events should be pulled out from storage.
///   - startDate: Timetoken for oldest event starting from which next should be returned events.
///   Value will be converted to required precision internally.
///   - endDate: Timetoken for latest event till which events should be pulled out.
///   Value will be converted to required precision internally.
///   - limit: Maximum number of events which should be returned in response (not more then **100**).
///   - shouldReverseOrder: Whether events order in response should be reversed or not.
///   - shouldIncludeTimeToken: Whether event dates (time tokens) should be included in response or not.
///   - block: History pull completion block.
///
/// @since 4.0
////
- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate limit:(NSUInteger)limit
                  reverse:(BOOL)shouldReverseOrder includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block
    NS_SWIFT_NAME(historyForChannel(_:start:end:limit:reverse:includeTimeToken:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-fetchHistoryWithRequest:completion:' method instead.");


#pragma mark - History manipulation

/// Delete messages from `channel`.
///
/// #### Example:
/// ```objc
/// PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@"channel-a"];
/// request.start = @([[NSDate dateWithTimeIntervalSinceNow:-(60 * 60)] timeIntervalSince1970]);
/// request.end = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client deleteMessagesWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Messages within specified time frame has been removed.
///     } else {
///         // Handle message history download error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to remove portion of channels messages.
///   - block: Messages delete request completion block.
- (void)deleteMessagesWithRequest:(PNHistoryMessagesDeleteRequest *)request
                       completion:(PNMessageDeleteCompletionBlock)block
    NS_SWIFT_NAME(deleteMessagesWithRequest(_:completion:));

/// Allow to remove events from specified `channel`'s history within specified time frame.
///
/// #### Example:
/// ```objc
/// NSNumber *startDate = @([[NSDate dateWithTimeIntervalSinceNow:-(60*60)] timeIntervalSince1970]);
/// NSNumber *endDate = @([[NSDate date] timeIntervalSince1970]);
///
/// [self.client deleteMessagesFromChannel:@"storage" 
///                                  start:startDate
///                                    end:endDate
///                         withCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///        // Messages within specified time frame has been removed.
///     } else {
///        // Handle message history download error. Check `category` property to find out possible issue because of
///        // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Name of the channel from which events should be removed.
///   - startDate: Timetoken for oldest event starting from which events should be removed.
///   Value will be converted to required precision internally. If no `endDate` value provided, will be removed all
///   events till specified `startDate` date (not inclusive).
///   - endDate: Timetoken for latest event till which events should be removed.
///   Value will be converted to required precision internally. If no `startDate` value provided, will be removed all
///   events starting from specified `endDate` date (inclusive).
///   - block: Events remove completion block.
- (void)deleteMessagesFromChannel:(NSString *)channel
                            start:(nullable NSNumber *)startDate
                              end:(nullable NSNumber *)endDate 
                   withCompletion:(nullable PNMessageDeleteCompletionBlock)block 
    NS_SWIFT_NAME(deleteMessagesFromChannel(_:start:end:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-deleteMessagesWithRequest:completion:' method instead.");


#pragma mark - Messages count


/// Count number of messages.
///
/// #### Example:
/// ```objc
/// PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannel:@"channel-a"];
///
/// [self.client fetchMessagesCountWithRequest:request completion:^(PNMessageCountResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Messages count successfully retrieved. Per-channel count available here: `result.data.channels`.
///     } else {
///         // Messages count error. Check `category` property to find out possible issue because of which request did
///         fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to retrieve number of messages for channels in specific timeframe.
///   - block: Messages count request completion block.
- (void)fetchMessagesCountWithRequest:(PNHistoryMessagesCountRequest *)request
                           completion:(PNMessageCountCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
