/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNCreateSpaceStatus.h"
#import "PNResult+Private.h"
#import "PNSpace+Private.h"


#pragma mark Protected interfaces declaration

@interface PNCreateSpaceStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNCreateSpaceData *data;

#pragma mark -


@end


@interface PNCreateSpaceData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNSpace *space;

#pragma mark -


@end


#pragma mark - Interfaces implementation

@implementation PNCreateSpaceData


#pragma mark - Information

- (PNSpace *)space {
    if (!_space) {
        _space = [PNSpace spaceFromDictionary:self.serviceData[@"space"]];
    }
    
    return _space;
}

#pragma mark -


@end


@implementation PNCreateSpaceStatus


#pragma mark - Information

- (PNCreateSpaceData *)data {
    if (!_data) {
        _data = [PNCreateSpaceData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
