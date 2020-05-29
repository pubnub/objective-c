/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSetUUIDMetadataStatus.h"
#import "PNUUIDMetadata+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNSetUUIDMetadataStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNSetUUIDMetadataData *data;

#pragma mark -


@end


@interface PNSetUUIDMetadataData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNUUIDMetadata *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNSetUUIDMetadataData


#pragma mark - Information

- (PNUUIDMetadata *)metadata {
    if (!_metadata) {
        _metadata = [PNUUIDMetadata uuidMetadataFromDictionary:self.serviceData[@"uuid"]];
    }
    
    return _metadata;
}

#pragma mark -


@end


@implementation PNSetUUIDMetadataStatus


#pragma mark - Information

- (PNSetUUIDMetadataData *)data {
    if (!_data) {
        _data = [PNSetUUIDMetadataData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
