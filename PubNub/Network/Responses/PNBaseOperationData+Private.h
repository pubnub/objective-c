#import "PNBaseOperationData.h"
#import "PNStructures.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General operation outcome data object private extension.
@interface PNBaseOperationData () <PNCodable>


#pragma mark - Properties

/// Whether service returned error response or not.
@property(assign, nonatomic, getter = isError) BOOL error;

/// Represent request processing status object using `PNStatusCategory` enum fields.
@property(assign, nonatomic) PNStatusCategory category;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
