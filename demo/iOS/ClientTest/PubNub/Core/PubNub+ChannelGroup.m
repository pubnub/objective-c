/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+ChannelGroup.h"
#import "PubNub+CorePrivate.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNHelpers.h"


#pragma mark Protected interface declaration

@interface PubNub  (ChannelGroupProtected)


#pragma mark - Channel group content manipulation

/**
 @brief      Add new channels to channel \c group.
 @discussion After addition channels to group it can be used in subscribe request to subscribe on
             remote data objects live feed with single group name.
 
 @param shouldAdd Whether provided channels should be added to channel \c group or not.
 @param channels  List of channel names which should be used for channel \c group modification.
 @param group     Name of the group which should be modified with list of passed \c channels.
 @param block     Channel group list modification process completion block which pass two arguments:
                  \c result - in case of successful request processing \c data field will contain
                  results of channels list modification operation; \c status - in case if error 
                  occurred during request processing.
 
 @since 4.0
 */
- (void)     add:(BOOL)shouldAdd channels:(NSArray *)channels toGroup:(NSString *)group
  withCompletion:(PNCompletionBlock)block;


#pragma mark - Processing

/**
 @brief  Try to pre-process provided data and translate it's content to expected from 'Channel Group
         Audition' API group.
 
 @param response Reference on Foundation object which should be pre-processed.
 
 @return Pre-processed dictionary or \c nil in case if passed \c response doesn't meet format 
         requirements to be handled by 'Channel Group Audition' API group.
 
 @since 4.0
 */
- (NSArray *)processedChannelGroupAuditionResponse:(id)response;

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
                                           forOperation:operationType
                                         withCompletion:^(PNResult *result, PNStatus *status){

            __strong __typeof(self) strongSelfForResponse = weakSelf;
            [strongSelfForResponse callBlock:[block copy] withResult:result andStatus:status];
        }];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedChannelGroupAuditionResponse:rawData];
        };
        [strongSelf processRequest:request];
    });
}


#pragma mark - Channel group content manipulation

- (void)addChannels:(NSArray *)channels toGroup:(NSString *)group
     withCompletion:(PNCompletionBlock)block {
    
    [self add:YES channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannels:(NSArray *)channels fromGroup:(NSString *)group
        withCompletion:(PNCompletionBlock)block {
    
    [self add:NO channels:channels toGroup:group withCompletion:block];
}

- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(PNCompletionBlock)block {
    
    [self removeChannels:nil fromGroup:group withCompletion:block];
}

- (void)     add:(BOOL)shouldAdd channels:(NSArray *)channels toGroup:(NSString *)group
  withCompletion:(PNCompletionBlock)block {

    // Dispatching async on private queue which is able to serialize access with client
    // configuration data.
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serviceQueue, ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        BOOL removeAllChannels = (!shouldAdd && channels == nil);
        PNOperationType operationType = PNRemoveGroupOperation;
        NSString *subscribeKey = [PNString percentEscapedString:strongSelf.subscribeKey];
        NSDictionary *parameters = nil;
        if (!removeAllChannels){
            
            operationType = (shouldAdd ? PNAddChannelsToGroupOperation :
                             PNRemoveChannelFromGroupOperation);
            parameters = @{(shouldAdd ? @"add":@"remove"):[PNChannel namesForRequest:channels]};
        }
        NSString *format = [@"/v1/channel-registration/sub-key/%@/channel-group/%@"
                            stringByAppendingString:(removeAllChannels ? @"/remove" : @"")];
        NSString *path = [NSString stringWithFormat:format, subscribeKey,
                          [PNString percentEscapedString:group]];
        PNRequest *request = [PNRequest requestWithPath:path parameters:parameters
                                           forOperation:operationType
                                         withCompletion:^(PNResult *result, PNStatus *status){

            __strong __typeof(self) strongSelfForResponse = weakSelf;
            [strongSelfForResponse callBlock:[block copy] withResult:result andStatus:status];
        }];
        request.parseBlock = ^id(id rawData) {
            
            __strong __typeof(self) strongSelfForParsing = weakSelf;
            return [strongSelfForParsing processedChannelGroupModificationResponse:rawData];
        };

        // Ensure what all required fields passed before starting processing.
        if ([group length] && (removeAllChannels || [channels count])) {

            [strongSelf processRequest:request];
        }
        // Notify about incomplete parameters set.
        else {

            NSString *description = @"Channel group not specified.";
            if (!removeAllChannels && [channels count] == 0) {

                description = @"Empty channels list.";
            }
            NSError *error = [NSError errorWithDomain:kPNAPIErrorDomain
                                                 code:kPNAPIUnacceptableParameters
                                             userInfo:@{NSLocalizedDescriptionKey:description}];
            [strongSelf handleRequestFailure:request withError:error];
        }
    });
}


#pragma mark - Processing

- (NSArray *)processedChannelGroupAuditionResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSArray *processedResponse = nil;
    
    // Dictionary is valid response type for channel group audition response.
    if ([response isKindOfClass:[NSDictionary class]] && response[@"payload"]) {
        
        if (response[@"payload"][@"channels"]) {
            
            processedResponse = response[@"payload"][@"channels"];
        }
        else if (response[@"payload"][@"groups"]) {
            
            processedResponse = response[@"payload"][@"groups"];
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
