#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelMetadataFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch channel metadata` request processing result.
@interface PNFetchChannelMetadataResult : PNOperationResult


#pragma mark - Properties

/// `Fetch channel metadata` request processed information.
@property(strong, nonatomic, readonly) PNChannelMetadataFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
