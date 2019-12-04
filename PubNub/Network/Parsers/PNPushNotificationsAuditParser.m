/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNPushNotificationsAuditParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNPushNotificationsAuditParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNPushNotificationEnabledChannelsOperation),
             @(PNPushNotificationEnabledChannelsV2Operation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    // Array is valid response type for device removal from APNS request.
    if ([response isKindOfClass:[NSArray class]]) {
        
        processedResponse = @{@"channels": (response?: @[])};
    }
    
    return processedResponse;
}

#pragma mark -


@end
