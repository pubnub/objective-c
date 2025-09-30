#import "PNPagedAppContextData.h"
#import "PNBaseAppContextObject.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Multipage App Context` request response private extensino.
@interface PNPagedAppContextData (Private)


#pragma mark - Properties

/// List of the fetched `App Context` objects.
@property(strong, nonatomic, readonly) NSArray<PNBaseAppContextObject *> *objects;

/// Total number of the `App Context` objects.
@property(assign, nonatomic, readonly) NSUInteger totalCount;

/// Class of the object which should be instantiated for ``objects`` array.
@property(class, strong, nonatomic, readonly) Class appContextObjectClass;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
