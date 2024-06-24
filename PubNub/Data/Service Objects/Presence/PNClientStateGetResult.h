#import <PubNub/PNOperationResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaraion

/// `Fetch user presence for channels / channel groups` response.
@interface PNClientStateData : NSObject


#pragma mark - Properties

/// Per-channel user presence state information.
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSDictionary *> *channels;

#pragma mark -


@end


#pragma mark - Interface declaraion

/// `Fetch user presence for channels / channel groups` request processing result.
@interface PNClientStateGetResult : PNOperationResult


#pragma mark - Properties

///  `Fetch user presence for channels / channel groups` request processed information.
@property (nonatomic, readonly, strong) PNClientStateData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
