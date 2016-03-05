/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNPushNotificationsStateModificationParser.h"


#pragma mark Interface implementation

@implementation PNPushNotificationsStateModificationParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNAddPushNotificationsOnChannelsOperation),
             @(PNRemovePushNotificationsFromChannelsOperation),
             @(PNRemoveAllPushNotificationsOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return NO;
}


#pragma mark - Parsing

+ (nullable NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    // Array is valid response type for device removal from APNS request.
    if ([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count == 2) {
        
        processedResponse = @{};
    }
    
    return processedResponse;
}

#pragma mark -


@end
