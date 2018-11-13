/**
 * @author Serhii Mamontov
 * @since 4.8.3
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNClientStateGetResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNClientStateData


#pragma mark - Information

- (NSDictionary<NSString *, NSDictionary *> *)channels {

    return (self.serviceData[@"channels"] ?: @{});
}

#pragma mark -

@end


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNClientStateGetResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNClientStateData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNClientStateGetResult


#pragma mark - Information

- (PNClientStateData *)data {

    if (!_data) {
        _data = [PNClientStateData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -

@end
