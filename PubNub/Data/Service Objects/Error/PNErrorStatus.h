#import <PubNub/PNStatus.h>
#import <PubNub/PNErrorData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// Operation error status object.
@interface PNErrorStatus : PNStatus


#pragma mark - Properties

/// Additional error information.
///
/// Additional information related to the context can be stored here. For example, source message will be stored here
/// if decryption will fail.
@property (nonatomic, nullable, readonly, strong) id associatedObject;

/// Error status object additional information.
@property (nonatomic, readonly, strong) PNErrorData *errorData;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
