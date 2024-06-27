#import <PubNub/PNOperationResult.h>
#import <PubNub/PNTimeData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Time request processing result.
@interface PNTimeResult : PNOperationResult


#pragma mark - Properties

/// Time request response from remote service.
@property(strong, nonatomic, readonly) PNTimeData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
