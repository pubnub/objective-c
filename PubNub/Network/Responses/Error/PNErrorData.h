#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementaation

/// Error status object additional information.
@interface PNErrorData : PNBaseOperationData


#pragma mark - Properties

/// List of channel groups for which error has been triggered.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *channelGroups;

/// List of channels for which error has been triggered.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *channels;

/// Whether service returned error response or not.
@property(assign, nonatomic, readonly, getter = isError) BOOL error;

/// Service-provided information about error.
@property(strong, nonatomic, readonly) NSString *information;

/// Service-provided additional information about error.
@property(strong, nullable, nonatomic, readonly) id data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
