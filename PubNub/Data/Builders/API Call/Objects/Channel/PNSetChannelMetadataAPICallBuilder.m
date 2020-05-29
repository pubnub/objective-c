/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSetChannelMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSetChannelMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSetChannelMetadataAPICallBuilder * (^)(PNChannelFields includeFields))includeFields {
    return ^PNSetChannelMetadataAPICallBuilder * (PNChannelFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetChannelMetadataAPICallBuilder * (^)(NSString *information))information {
    return ^PNSetChannelMetadataAPICallBuilder * (NSString *information) {
        if ([information isKindOfClass:[NSString class]] && information.length) {
            [self setValue:information forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetChannelMetadataAPICallBuilder * (^)(NSDictionary *custom))custom {
    return ^PNSetChannelMetadataAPICallBuilder * (NSDictionary *custom) {
        if ([custom isKindOfClass:[NSDictionary class]] && custom.count) {
            [self setValue:custom forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetChannelMetadataAPICallBuilder * (^)(NSString *name))name {
    return ^PNSetChannelMetadataAPICallBuilder * (NSString *name) {
        if ([name isKindOfClass:[NSString class]] && name.length) {
            [self setValue:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNSetChannelMetadataCompletionBlock block))performWithCompletion {
    return ^(PNSetChannelMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
