/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSetChannelMetadataStatus.h"
#import "PNChannelMetadata+Private.h"
#import "PNOperationResult+Private.h"
#import "PNServiceData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNSetChannelMetadataStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNSetChannelMetadataData *data;

#pragma mark -


@end


@interface PNSetChannelMetadataData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNChannelMetadata *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNSetChannelMetadataData


#pragma mark - Information

- (PNChannelMetadata *)metadata {
    if (!_metadata) {
        _metadata = [PNChannelMetadata channelMetadataFromDictionary:self.serviceData[@"channel"]];
    }
    
    return _metadata;
}

#pragma mark -


@end


@implementation PNSetChannelMetadataStatus


#pragma mark - Information

- (PNSetChannelMetadataData *)data {
    if (!_data) {
        _data = [PNSetChannelMetadataData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
