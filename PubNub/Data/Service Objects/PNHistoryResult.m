/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNHistoryResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"
#import "PNStructures.h"


#pragma mark Private interface declaration

@interface PNHistoryResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNHistoryData *data;

#pragma mark -


@end


#pragma mark - Interfaces implementation

@implementation PNHistoryData


#pragma mark - Information

- (NSArray *)messages {
    return self.serviceData[@"messages"] ?: @[];
}

- (NSDictionary<NSString *,NSArray *> *)channels {
    return self.serviceData[@"channels"] ?: @{};
}

- (NSNumber *)start {
    return self.serviceData[@"start"] ?: @0;
}

- (NSNumber *)end {
    return self.serviceData[@"end"] ?: @0;
}

#pragma mark -


@end


@implementation PNHistoryResult


#pragma mark - Information

- (PNHistoryData *)data {
    if (!_data) {
        _data = [PNHistoryData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
