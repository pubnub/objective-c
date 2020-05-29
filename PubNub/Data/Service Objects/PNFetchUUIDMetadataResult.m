/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchUUIDMetadataResult.h"
#import "PNUUIDMetadata+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNFetchUUIDMetadataResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchUUIDMetadataData *data;

#pragma mark -


@end


@interface PNFetchAllUUIDMetadataResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchAllUUIDMetadataData *data;

#pragma mark -


@end


@interface PNFetchUUIDMetadataData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNUUIDMetadata *metadata;

#pragma mark -


@end


@interface PNFetchAllUUIDMetadataData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNUUIDMetadata *> *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNFetchUUIDMetadataData


#pragma mark - Information

- (PNUUIDMetadata *)metadata {
    if (!_metadata) {
        _metadata = [PNUUIDMetadata uuidMetadataFromDictionary:self.serviceData[@"uuid"]];
    }
    
    return _metadata;
}

#pragma mark -


@end


@implementation PNFetchAllUUIDMetadataData


#pragma mark - Information

- (NSArray<PNUUIDMetadata *> *)metadata {
    if (!_metadata) {
        NSMutableArray *uuidsMetadata = [NSMutableArray new];
        
        for (NSDictionary *metadata in self.serviceData[@"uuids"]) {
            [uuidsMetadata addObject:[PNUUIDMetadata uuidMetadataFromDictionary:metadata]];
        }

        _metadata = [uuidsMetadata copy];
    }
    
    return _metadata;
}

- (NSUInteger)totalCount {
    return ((NSNumber *)self.serviceData[@"totalCount"]).unsignedIntegerValue;
}

- (NSString *)next {
    return self.serviceData[@"next"];
}

- (NSString *)prev {
    return self.serviceData[@"prev"];
}

#pragma mark -


@end


@implementation PNFetchUUIDMetadataResult


#pragma mark - Information

- (PNFetchUUIDMetadataData *)data {
    if (!_data) {
        _data = [PNFetchUUIDMetadataData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end


@implementation PNFetchAllUUIDMetadataResult


#pragma mark - Information

- (PNFetchAllUUIDMetadataData *)data {
    if (!_data) {
        _data = [PNFetchAllUUIDMetadataData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
