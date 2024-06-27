#import <PubNub/PNOperationResult.h>
#import <PubNub/PNUUIDMetadataFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch UUID metadata` request processing result.
@interface PNFetchUUIDMetadataResult : PNOperationResult


#pragma mark - Properties

/// `Fetch UUID metadata` request processed information.
@property(strong, nonatomic, readonly) PNUUIDMetadataFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
