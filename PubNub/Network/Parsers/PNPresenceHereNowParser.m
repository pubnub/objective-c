/**
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNPresenceHereNowParser.h"
#import "PNDictionary.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface

@interface PNPresenceHereNowParser ()


#pragma mark - Misc

/**
 * @brief Extract uuids information from \c service response data.
 *
 * @param serviceData Reference on response which contains information about channel's participants.
 *
 * @return Parsed UUIDs data.
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
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response withData:(NSDictionary *)data {
    NSDictionary *processedResponse = nil;
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSDictionary *hereNowData = nil;
        NSString *channel = nil;
        
        if (response[@"uuids"] || response[@"occupancy"]) {
            NSString *requestURLString = ((NSURL *)data[@"url"]).absoluteString;
            
            if (requestURLString) {
                NSString *pattern = @"channel\\/(.*)\\?";
                NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                       options:options
                                                                                         error:nil];
                
                NSRange matchRange = NSMakeRange(0, requestURLString.length);
                NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:requestURLString
                                                                          options:(NSMatchingOptions)0
                                                                            range:matchRange];
                
                if (matches.count > 0 && matches.firstObject.numberOfRanges > 1) {
                    NSRange matchedRange = [matches.firstObject rangeAtIndex:1];
                    channel = [requestURLString substringWithRange:matchedRange];
                }
            }
        }
        
        if (response[@"payload"][@"channels"]) {
            NSMutableDictionary *data = [@{
                @"totalChannels": response[@"payload"][@"total_channels"],
                @"totalOccupancy": response[@"payload"][@"total_occupancy"],
                @"channels": [NSMutableDictionary new]
            } mutableCopy];
            
            for (NSString *channelName in response[@"payload"][@"channels"]) {
                NSDictionary *channelData = response[@"payload"][@"channels"][channelName];
                NSMutableDictionary *parsedChannelData = [@{
                    @"occupancy": channelData[@"occupancy"]
                } mutableCopy];
                
                if (channelData[@"uuids"]) {
                    parsedChannelData[@"uuids"] = [self uuidsData:channelData[@"uuids"]];
                }
                
                data[@"channels"][channelName] = parsedChannelData;
            }
            
            hereNowData = data;
        } else if (response[@"uuids"]) {
            hereNowData = @{
                @"occupancy": response[@"occupancy"],
                @"uuids": [self uuidsData:response[@"uuids"]]
            };
            
            if (channel) {
                hereNowData = @{
                    @"channels": @{ channel: hereNowData }
                };
            }
        } else if (response[@"occupancy"]) {
            hereNowData = @{ @"occupancy": response[@"occupancy"] };
            
            if (channel) {
                hereNowData = @{
                    @"channels": @{ channel: hereNowData }
                };
            }
        }
        
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
            
            if (uuidData[@"state"]) {
                data[@"state"] = uuidData[@"state"];
            }
            
            parsedData = data;
        }
        
        [parsedUUIDData addObject:parsedData];
    }
    
    return [parsedUUIDData copy];
}

#pragma mark -


@end
