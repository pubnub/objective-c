/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNUpdateSpaceStatus.h"
#import "PNResult+Private.h"
#import "PNSpace+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNUpdateSpaceStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNUpdateSpaceData *data;

#pragma mark -


@end


@interface PNUpdateSpaceData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNSpace *space;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNUpdateSpaceData


#pragma mark - Information

- (PNSpace *)space {
    if (!_space) {
        _space = [PNSpace spaceFromDictionary:self.serviceData[@"space"]];
    }
    
    return _space;
}

#pragma mark -


@end


@implementation PNUpdateSpaceStatus


#pragma mark - Information

- (PNUpdateSpaceData *)data {
    if (!_data) {
        _data = [PNUpdateSpaceData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
