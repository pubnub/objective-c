#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General `App Context` data object.
@interface PNBaseAppContextObject : NSObject


#pragma mark - Properties

/// Additional data associated with `App Context` object.
///
/// > Important: Values must be scalars; only arrays or objects are supported. App Context filtering language doesn’t
/// support filtering by custom properties.
@property(strong, nullable, nonatomic, readonly) NSDictionary *custom;

/// Last `App Context` object update date.
@property(strong, nonatomic, readonly) NSDate *updated;

/// `App Context` object version identifier.
@property(copy, nonatomic, readonly) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
