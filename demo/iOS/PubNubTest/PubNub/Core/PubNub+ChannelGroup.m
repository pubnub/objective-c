/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+ChannelGroup.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNStatus+Private.h"
#import "PNErrorCodes.h"
#import "PNResponse.h"
#import "PNHelpers.h"


#pragma mark Protected interface declaration

@interface PubNub  (ChannelGroupProtected)


#pragma mark - Channel group content manipulation

/**
 @brief  Add or remove channels to/from the \c group.
 
 @param shouldAdd Whether provided \c channels should be added to the \c group or removed.
 @param channels  List of channels names which should be used for \c group modification.
 @param group     Name of the group which should be modified with list of passed \c objects.
 @param block     Channel group list modification process completion block which pass only one
                  argument - request processing status to report about how data pushing was 
                  successful or not.
 
 @since 4.0
 */
- (void)     add:(BOOL)shouldAdd channels:(NSArray *)channels toGroup:(NSString *)group
  withCompletion:(PNStatusBlock)block;


#pragma mark - Handlers

/**
 @brief  Process channel group channels list modification request completion and notify observers 
         about results.

 @param request Reference on base request which is used for communication with \b PubNub service.
                Object also contains request processing results.
 @param block   Channel group list modification process completion block which pass only one
                argument - request processing status to report about how data pushing was successful
                or not.

 @since 4.0
 */
- (void)handleGroupModificationRequest:(PNRequest *)request withCompletion:(PNStatusBlock)block;


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'Channel Group
         Audition' API group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'Channel Group Audition' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedChannelGroupAuditionResponse:(id)response;

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'Channel Group
         Modification' API group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'Channel Group Modification' API group.
 
 @since 4.0
 */
- (NSDictionary *)processedChannelGroupModificationResponse:(id)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PubNub (ChannelGroup)


#pragma mark - Channel group audition

- (void)channelGroupsWithCompletion:(PNCompletionBlock)block {
    
    [self channelsForGroup:nil withCompletion:block];
}

- (void)channelsForGroup:(NSString *)group withCompletion:(PNCompletionBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        PNOperationType operationType = (group ? PNChannelGroupsOperation :
                                         PNChannelsForGroupOperation);
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *format = [@"/v1/channel-registration/sub-key/%@/channel-group"
                            stringByAppendingString:(group ? @"/%@" : @"")];
        NSString *path = [NSString stringWithFormat:format, subscribeKey,
                          [PNString percentEscapedString:group]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:nil
                                           forOperation:operationType withCompletion:nil];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedChannelGroupAuditionResponse:rawData];
        };
        
        if (group) {
            
            DDLogAPICall(@"<PubNub> Request channels for '%@' channel group.", group);
        }
        else {
            
            DDLogAPICall(@"<PubNub> Request channel groups list.");
        }
        request.reportBlock = block;
        
        [strongSelf processRequest:request];
    });
}


#pragma mark - Channel group content manipulation

- (void)addChannels:(NSArray *)channels toGroup:(NSString *)group
     withCompletion:(PNStatusBlock)block {
    
    [self add:YES channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannels:(NSArray *)channels fromGroup:(NSString *)group
        withCompletion:(PNStatusBlock)block {
    
    [self add:NO channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(PNStatusBlock)block {
    
    [self removeChannels:nil fromGroup:group withCompletion:block];
}

- (void)     add:(BOOL)shouldAdd channels:(NSArray *)channels toGroup:(NSString *)group
  withCompletion:(PNStatusBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        BOOL removeAllObjects = (!shouldAdd && channels == nil);
        PNOperationType operationType = PNRemoveGroupOperation;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSString *channelsList = [PNChannel namesForRequest:channels];
        NSDictionary *parameters = nil;
        if (!removeAllObjects){
            
            operationType = (shouldAdd ? PNAddChannelsToGroupOperation :
                             PNRemoveChannelFromGroupOperation);
            parameters = @{(shouldAdd ? @"add":@"remove"): channelsList};
        }
        NSString *format = [@"/v1/channel-registration/sub-key/%@/channel-group/%@"
                            stringByAppendingString:(removeAllObjects ? @"/remove" : @"")];
        NSString *path = [NSString stringWithFormat:format, subscribeKey,
                          [PNString percentEscapedString:group]];
        __block __weak PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                                          forOperation:operationType
                                                        withCompletion:^{
                                                            
            __strong __typeof(self) strongSelfForResults = weakSelf;
            [strongSelfForResults handleGroupModificationRequest:request
                                                  withCompletion:[block copy]];
        }];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedChannelGroupModificationResponse:rawData];
        };
        request.reportBlock = block;
        
        if (removeAllObjects) {
            
            DDLogAPICall(@"<PubNub> Remove '%@' channel group", (group?: @"<error>"));
        }
        else {
            
            DDLogAPICall(@"<PubNub> %@ channels %@ '%@' channel group: %@",
                         (shouldAdd ? @"Add" : @"Remove"), (shouldAdd ? @"to" : @"from"),
                         (group?: @"<error>"), (channelsList?: @"<error>"));
        }

        // Ensure what all required fields passed before starting processing.
        if ([group length] && (removeAllObjects || [channels count])) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Channel group not specified.";
            if (!removeAllObjects && [channels count] == 0) {

                description = @"Empty channels list.";
            }
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}


#pragma mark - Handlers 

- (void)handleGroupModificationRequest:(PNRequest *)request withCompletion:(PNStatusBlock)block {
    
    // Construct corresponding data objects which should be delivered through completion block.
    PNStatus *status = [PNStatus statusForRequest:request withError:request.response.error];
    
    [self callBlock:block status:YES withResult:nil andStatus:status];
}


#pragma mark - Processing

- (NSDictionary *)processedChannelGroupAuditionResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for channel group audition response.
    if ([response isKindOfClass:[NSDictionary class]] && response[@"payload"]) {
        
        if (response[@"payload"][@"channels"]) {
            
            processedResponse = @{@"channels": response[@"payload"][@"channels"]};
        }
        else if (response[@"payload"][@"groups"]) {
            
            processedResponse = @{@"channel-groups": response[@"payload"][@"groups"]};
        }
    }
    
    return [processedResponse copy];
}

- (NSDictionary *)processedChannelGroupModificationResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for channel group modification response.
    if ([response isKindOfClass:[NSDictionary class]] &&
        response[@"message"] && response[@"error"]) {
        
        BOOL isError = ([response[@"error"] integerValue] == 1);
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:@{@"status":@YES}];
        data[@"error"] = @(isError);
        if (isError) {
            
            data[@"information"] = response[@"message"];
            data[@"status"] = @NO;
        }
        processedResponse = data;
    }
    
    return [processedResponse copy];
}

#pragma mark -


@end
