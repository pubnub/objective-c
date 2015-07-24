/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNPresenceWhereNowResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceWhereNowData


#pragma mark - Information

- (NSArray *)channels {
    
    return self.serviceData[@"channels"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceWhereNowResult


#pragma mark - Information

- (PNPresenceWhereNowData *)data {
    
    return [PNPresenceWhereNowData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
