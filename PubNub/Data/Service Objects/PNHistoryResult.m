/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNHistoryResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNHistoryData


#pragma mark - Information

- (NSArray *)messages {
    
    return (self.serviceData[@"messages"]?: @[]);
}

- (NSNumber *)start {
    
    return (self.serviceData[@"start"]?: @0);
}

- (NSNumber *)end {
    
    return (self.serviceData[@"end"]?: @0);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNHistoryResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNHistoryData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNHistoryResult


#pragma mark - Information

- (PNHistoryData *)data {
    
    if (!_data) { _data = [PNHistoryData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
