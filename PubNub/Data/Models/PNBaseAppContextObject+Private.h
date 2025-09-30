#import "PNBaseAppContextObject.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General `App Context` data object private extension.
@interface PNBaseAppContextObject (Private)


#pragma mark - Properties

/// Additional data associated with App Context object.
///
/// > Important: Values must be scalars; only arrays or objects are supported. App Context filtering language doesn’t
/// support filtering by custom properties.
@property(strong, nullable, nonatomic) NSDictionary *custom;


#pragma mark - Misc

/// Translate `App Context` data model to dictionary.
- (NSMutableDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
