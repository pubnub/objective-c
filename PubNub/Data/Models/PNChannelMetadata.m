#import "PNChannelMetadata.h"
#import "PNBaseAppContextObject+Private.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Channel Metadata` object private extension.
@interface PNChannelMetadata () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelMetadata


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"name": @"name",
        @"information": @"description",
        @"status": @"status",
        @"type": @"type",
        @"channel": @"id",
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"name", @"information", @"status", @"type"];
}


#pragma mark - Misc

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [super dictionaryRepresentation];
    dictionary[@"channel"] = self.channel;
    
    if (self.information) dictionary[@"information"] = self.information;
    if (self.status) dictionary[@"status"] = self.status;
    if (self.type) dictionary[@"type"] = self.type;
    if (self.name) dictionary[@"name"] = self.name;

    return dictionary;
}

- (NSString *)debugDescription {
    return [self dictionaryRepresentation].description;
}

#pragma mark -


@end
