/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */

#import "PNObjectsAPICallBuilder.h"
#import "PNFetchAllUUIDMetadataAPICallBuilder.h"
#import "PNRemoveUUIDMetadataAPICallBuilder.h"
#import "PNFetchUUIDMetadataAPICallBuilder.h"
#import "PNSetUUIDMetadataAPICallBuilder.h"

#import "PNFetchAllChannelsMetadataAPICallBuilder.h"
#import "PNRemoveChannelMetadataAPICallBuilder.h"
#import "PNFetchChannelMetadataAPICallBuilder.h"
#import "PNSetChannelMetadataAPICallBuilder.h"

#import "PNSetMembershipsAPICallBuilder.h"
#import "PNRemoveMembershipsAPICallBuilder.h"
#import "PNManageMembershipsAPICallBuilder.h"
#import "PNFetchMembershipsAPICallBuilder.h"
#import "PNSetChannelMembersAPICallBuilder.h"
#import "PNRemoveChannelMembersAPICallBuilder.h"
#import "PNManageChannelMembersAPICallBuilder.h"
#import "PNFetchChannelMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNObjectsAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {

    if (self == [PNObjectsAPICallBuilder class]) {
        [self copyMethodsFromClasses:@[
            [PNSetUUIDMetadataAPICallBuilder class],
            [PNRemoveUUIDMetadataAPICallBuilder class],
            [PNFetchUUIDMetadataAPICallBuilder class],
            [PNFetchAllUUIDMetadataAPICallBuilder class],
            [PNSetChannelMetadataAPICallBuilder class],
            [PNRemoveChannelMetadataAPICallBuilder class],
            [PNFetchChannelMetadataAPICallBuilder class],
            [PNFetchAllChannelsMetadataAPICallBuilder class],
            [PNSetMembershipsAPICallBuilder class],
            [PNRemoveMembershipsAPICallBuilder class],
            [PNManageMembershipsAPICallBuilder class],
            [PNFetchMembershipsAPICallBuilder class],
            [PNSetChannelMembersAPICallBuilder class],
            [PNRemoveChannelMembersAPICallBuilder class],
            [PNManageChannelMembersAPICallBuilder class],
            [PNFetchChannelMembersAPICallBuilder class]]
        ];
    }
}


#pragma mark - UUID metadata management / audit

- (PNSetUUIDMetadataAPICallBuilder * (^)(void))setUUIDMetadata {
    return ^PNSetUUIDMetadataAPICallBuilder * {
        object_setClass(self, [PNSetUUIDMetadataAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNSetUUIDMetadataAPICallBuilder *)self;
    };
}

- (PNRemoveUUIDMetadataAPICallBuilder * (^)(void))removeUUIDMetadata {
    return ^PNRemoveUUIDMetadataAPICallBuilder * {
        object_setClass(self, [PNRemoveUUIDMetadataAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNRemoveUUIDMetadataAPICallBuilder *)self;
    };
}

- (PNFetchUUIDMetadataAPICallBuilder * (^)(void))uuidMetadata {
    return ^PNFetchUUIDMetadataAPICallBuilder * {
        object_setClass(self, [PNFetchUUIDMetadataAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNFetchUUIDMetadataAPICallBuilder *)self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder *(^)(void))allUUIDMetadata {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * {
        object_setClass(self, [PNFetchAllUUIDMetadataAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNFetchAllUUIDMetadataAPICallBuilder *)self;
    };
}


#pragma mark - Channel metadata management / audit

- (PNSetChannelMetadataAPICallBuilder *(^)(NSString *channel))setChannelMetadata {
    return ^PNSetChannelMetadataAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNSetChannelMetadataAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNSetChannelMetadataAPICallBuilder *)self;
    };
}

- (PNRemoveChannelMetadataAPICallBuilder *(^)(NSString *channel))removeChannelMetadata {
    return ^PNRemoveChannelMetadataAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNRemoveChannelMetadataAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNRemoveChannelMetadataAPICallBuilder *)self;
    };
}

- (PNFetchChannelMetadataAPICallBuilder *(^)(NSString *channel))channelMetadata {
    return ^PNFetchChannelMetadataAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNFetchChannelMetadataAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNFetchChannelMetadataAPICallBuilder *)self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder *(^)(void))allChannelsMetadata {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * {
        object_setClass(self, [PNFetchAllChannelsMetadataAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNFetchAllChannelsMetadataAPICallBuilder *)self;
    };
}


#pragma mark - Members / memberships management / audit

- (PNSetMembershipsAPICallBuilder *(^)(void))setMemberships {
    return ^PNSetMembershipsAPICallBuilder * {
        object_setClass(self, [PNSetMembershipsAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNSetMembershipsAPICallBuilder *)self;
    };
}

- (PNRemoveMembershipsAPICallBuilder *(^)(void))removeMemberships {
    return ^PNRemoveMembershipsAPICallBuilder * {
        object_setClass(self, [PNRemoveMembershipsAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNRemoveMembershipsAPICallBuilder *)self;
    };
}

- (PNManageMembershipsAPICallBuilder *(^)(void))manageMemberships {
    return ^PNManageMembershipsAPICallBuilder * {
        object_setClass(self, [PNManageMembershipsAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNManageMembershipsAPICallBuilder *)self;
    };
}

- (PNFetchMembershipsAPICallBuilder *(^)(void))memberships {
    return ^PNFetchMembershipsAPICallBuilder * {
        object_setClass(self, [PNFetchMembershipsAPICallBuilder class]);

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNFetchMembershipsAPICallBuilder *)self;
    };
}

- (PNSetChannelMembersAPICallBuilder *(^)(NSString *channel))setChannelMembers {
    return ^PNSetChannelMembersAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNSetChannelMembersAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNSetChannelMembersAPICallBuilder *)self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder *(^)(NSString *channel))removeChannelMembers {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNRemoveChannelMembersAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNRemoveChannelMembersAPICallBuilder *)self;
    };
}

- (PNManageChannelMembersAPICallBuilder *(^)(NSString *channel))manageChannelMembers {
    return ^PNManageChannelMembersAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNManageChannelMembersAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNManageChannelMembersAPICallBuilder *)self;
    };
}

- (PNFetchChannelMembersAPICallBuilder *(^)(NSString *channel))channelMembers {
    return ^PNFetchChannelMembersAPICallBuilder * (NSString *channel) {
        object_setClass(self, [PNFetchChannelMembersAPICallBuilder class]);

        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:@"channel"];
        }

        [self setFlag:NSStringFromSelector(_cmd)];
        return (PNFetchChannelMembersAPICallBuilder *)self;
    };
}

#pragma mark -


@end
