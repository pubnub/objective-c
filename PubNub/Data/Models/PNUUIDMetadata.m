#import "PNUUIDMetadata.h"
#import "PNBaseAppContextObject+Private.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `UUID Metadata` object private extension.
@interface PNUUIDMetadata () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNUUIDMetadata


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"name": @"name",
        @"email": @"email",
        @"profileUrl": @"profileUrl",
        @"externalId": @"externalId",
        @"status": @"status",
        @"type": @"type",
        @"uuid": @"id",
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"name", @"email", @"profileUrl", @"externalId", @"status", @"type"];
}


#pragma mark - Misc

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [super dictionaryRepresentation];
    dictionary[@"uuid"] = self.uuid;

    if (self.externalId) dictionary[@"externalId"] = self.externalId;
    if (self.profileUrl) dictionary[@"profileUrl"] = self.profileUrl;
    if (self.email) dictionary[@"email"] = self.email;
    if (self.name) dictionary[@"name"] = self.name;
    if (self.status) dictionary[@"status"] = self.status;
    if (self.type) dictionary[@"type"] = self.type;

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
