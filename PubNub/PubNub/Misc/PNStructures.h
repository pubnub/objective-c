/**
 @brief Set of types and structures which is used as part of API calls in \b PubNub client.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNResult, PNStatus;


#ifndef PNStructures_h
#define PNStructures_h

/**
 @brief      Type which specify possible operations for \b PNResult/ \b PNStatus event objects.
 @discussion This fields allow to identify for what kind of API this object arrived.
 
 @since 4.0
 */
typedef NS_OPTIONS(NSInteger, PNOperationType){
    PNSubscribeOperation,
    PNUnsubscribeOperation,
    PNPublishOperation,
    PNHistoryOperation,
    PNWhereNowOperation,
    PNHereNowOperation,
    PNHeartbeatOperation,
    PNUpdateStateOperation,
    PNFetchStateOperation,
    PNAddChannelsToGroupOperation,
    PNRemoveChannelFromGroupOperation,
    PNFetchGroupsOperation,
    PNRemoveGroupOperation,
    PNFetchGroupChannelsOperation,
    PNFetchRegisteredAPNSChannelsOperation,
    PNRegisterChannelsForAPNSOperation,
    PNUnregisterChannelsFromAPNSOperation,
    PNUnregisterDeviceFromAPNSOperation,
    PNTimeOperation
};

typedef void(^PNHandlingBlock)(PNResult *result, PNStatus *status);
typedef void(^PNEventHandlingBlock)(PNResult *result);


#endif // PNStructures_h
