/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchAllChannelsMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"


#pragma mark Interface implementation

@implementation PNFetchAllChannelsMetadataRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchAllChannelsMetadataOperation;
}

- (BOOL)isIdentifierRequired {
    return NO;
}


#pragma mark - Initialization & Configuration

- (instancetype)init {
    if ((self = [super init])) {
        self.includeFields = PNChannelTotalCountField;
    }
    
    return self;
}

#pragma mark -


@end
