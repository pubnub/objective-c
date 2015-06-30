/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNPushNotificationsAuditParser.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNPushNotificationsAuditParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNPushNotificationEnabledChannelsOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for device removal from APNS request.
    if ([response isKindOfClass:[NSArray class]]) {
        
        processedResponse = @{@"channels": response};
    }
    
    return processedResponse;
}

#pragma mark -


@end
