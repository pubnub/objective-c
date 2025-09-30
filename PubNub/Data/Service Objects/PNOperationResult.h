#import <Foundation/Foundation.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General operation (request or client generated) result object.
///
/// Object contain information about type of operation and its outcome (processed data object).
@interface PNOperationResult: NSObject


#pragma mark - Properties

/// Stringify request operation type.
///
/// Stringify request `operation` field (one of the `PNOperationType` enum).
@property(strong, nonatomic, readonly) NSString *stringifiedOperation;

/// Type of operation for which result object has been created.
@property(assign, nonatomic, readonly) PNOperationType operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
