/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNPresebceHereNowParser.h"


#pragma mark Interface implementation

@implementation PNPresebceHereNowParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNHereNowGlobalOperation), @(PNHereNowOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Dictionary is valid response type for here now response.
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSArray *(^uuidParseBlock)(NSArray *) = ^NSArray *(NSArray *uuids) {
            
            NSMutableArray *parsedUUIDData = [NSMutableArray new];
            for (id uuidData in uuids) {
                
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
        };
        
        // Check whether global here now has been performed or not
        if (response[@"payload"][@"channels"]) {
            
            // Composing initial response content.
            NSMutableDictionary *data = [@{@"total_channels":response[@"payload"][@"total_channels"],
                                           @"total_occupancy":response[@"payload"][@"total_occupancy"],
                                           @"channels": [NSMutableDictionary new]} mutableCopy];
            for (NSDictionary *channelName in response[@"payload"][@"channels"]) {
                
                NSDictionary *channelData = response[@"payload"][@"channels"][channelName];
                NSMutableDictionary *parsedChannelData = [@{@"occupancy":channelData[@"occupancy"]
                                                            } mutableCopy];
                if (channelData[@"uuids"]) {
                    
                    parsedChannelData[@"uuids"] = uuidParseBlock(channelData[@"uuids"]);
                }
                
                data[@"channels"][channelName] = parsedChannelData;
            }
            processedResponse = data;
        }
        else if (response[@"uuids"]){
            
            processedResponse = @{@"occupancy":response[@"occupancy"],
                                  @"uuids":uuidParseBlock(response[@"uuids"])};
        }
        else if (response[@"occupancy"]){
            
            processedResponse = @{@"occupancy":response[@"occupancy"]};
        }
    }
    
    return processedResponse;
}

#pragma mark -


@end
