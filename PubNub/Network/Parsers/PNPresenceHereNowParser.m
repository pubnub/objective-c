/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNPresenceHereNowParser.h"
#import "PNDictionary.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface

@interface PNPresenceHereNowParser ()


#pragma mark - Misc

/**
 @brief  Extract uuids information from \c service response data.
 
 @param serviceData Reference on response which contains information about channel's participants.
 
 @return Parsed UUIDs data.
 */
+ (NSArray<NSObject *> *)uuidsData:(NSArray<NSObject *> *)serviceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceHereNowParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNHereNowGlobalOperation), @(PNHereNowForChannelOperation),
             @(PNHereNowForChannelGroupOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for here now response.
    if ([response isKindOfClass:[NSDictionary class]]) {
            
        NSDictionary *hereNowData = nil;
        
        // Check whether global here now has been performed or not
        if (response[@"payload"][@"channels"]) {
            
            // Composing initial response content.
            NSMutableDictionary *data = [@{@"totalChannels":response[@"payload"][@"total_channels"],
                                           @"totalOccupancy":response[@"payload"][@"total_occupancy"],
                                           @"channels": [NSMutableDictionary new]} mutableCopy];
            for (NSString *channelName in response[@"payload"][@"channels"]) {
                
                NSDictionary *channelData = response[@"payload"][@"channels"][channelName];
                NSMutableDictionary *parsedChannelData = [@{@"occupancy":channelData[@"occupancy"]
                                                            } mutableCopy];
                if (channelData[@"uuids"]) {
                    
                    parsedChannelData[@"uuids"] = [self uuidsData:channelData[@"uuids"]];
                }
                
                data[@"channels"][channelName] = parsedChannelData;
            }
            hereNowData = data;
        }
        else if (response[@"uuids"]){
            
            hereNowData = @{@"occupancy":response[@"occupancy"], @"uuids":[self uuidsData:response[@"uuids"]]};
        }
        else if (response[@"occupancy"]){ hereNowData = @{@"occupancy":response[@"occupancy"]}; }
        processedResponse = hereNowData;
    }
    
    return processedResponse;
}


#pragma mark - Misc

+ (NSArray<NSObject *> *)uuidsData:(NSArray<NSObject *> *)serviceData {
    
    NSMutableArray *parsedUUIDData = [NSMutableArray new];
    for (id uuidData in serviceData) {
        
        id parsedData = uuidData;
        if ([uuidData respondsToSelector:@selector(count)]) {
            
            NSMutableDictionary *data = [@{@"uuid":uuidData[@"uuid"]} mutableCopy];
            if (uuidData[@"state"]) { data[@"state"] = uuidData[@"state"]; }
            parsedData = data;
        }
        [parsedUUIDData addObject:parsedData];
    }
    
    return [parsedUUIDData copy];
}

#pragma mark -


@end
