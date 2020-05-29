/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchChannelsMetadataResult.h"
#import "PNChannelMetadata+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNFetchChannelMetadataResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchChannelMetadataData *data;

#pragma mark -


@end


@interface PNFetchAllChannelsMetadataResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchAllChannelsMetadataData *data;

#pragma mark -


@end



@interface PNFetchChannelMetadataData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNChannelMetadata *metadata;

#pragma mark -


@end


@interface PNFetchAllChannelsMetadataData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNChannelMetadata *> *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNFetchChannelMetadataData


#pragma mark - Information

- (PNChannelMetadata *)metadata {
    if (!_metadata) {
        _metadata = [PNChannelMetadata channelMetadataFromDictionary:self.serviceData[@"channel"]];
    }
    
    return _metadata;
}

#pragma mark -


@end


@implementation PNFetchAllChannelsMetadataData


#pragma mark - Information

- (NSUInteger)totalCount {
    return ((NSNumber *)self.serviceData[@"totalCount"]).unsignedIntegerValue;
}

- (NSArray<PNChannelMetadata *> *)metadata {
    if (!_metadata) {
        NSMutableArray *channelsMetadata = [NSMutableArray new];
        
        for (NSDictionary *metadata in self.serviceData[@"channels"]) {
            [channelsMetadata addObject:[PNChannelMetadata channelMetadataFromDictionary:metadata]];
        }

        _metadata = [channelsMetadata copy];
    }
    
    return _metadata;
}

- (NSString *)next {
    return self.serviceData[@"next"];
}

- (NSString *)prev {
    return self.serviceData[@"prev"];
}

#pragma mark -


@end


@implementation PNFetchChannelMetadataResult


#pragma mark - Information

- (PNFetchChannelMetadataData *)data {
    if (!_data) {
        _data = [PNFetchChannelMetadataData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end


@implementation PNFetchAllChannelsMetadataResult


#pragma mark - Information

- (PNFetchAllChannelsMetadataData *)data {
    if (!_data) {
        _data = [PNFetchAllChannelsMetadataData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
