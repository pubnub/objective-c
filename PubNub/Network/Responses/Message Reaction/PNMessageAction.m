#import "PNMessageAction.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNMessageAction () <PNCodable>


#pragma mark - Misc

/// Translate `message action` data model to dictionary.
///
/// - Returns: Dictionary `message action` representation.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMessageAction


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"type": self.type,
        @"uuid": self.uuid,
        @"actionTimetoken": self.actionTimetoken,
        @"messageTimetoken": self.messageTimetoken,
        @"value": self.value
    };
}

- (NSString *)debugDescription {
    return [[self dictionaryRepresentation] description];
}

#pragma mark -


@end
