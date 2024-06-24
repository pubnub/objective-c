#import <PubNub/PNOperationResult.h>
#import <PubNub/PNUUIDMetadataFetchAllData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch all UUIDs metadata` request processing result.
@interface PNFetchAllUUIDMetadataResult : PNOperationResult


#pragma mark - Properties

/// `Fetch all UUIDs metadata` request processed information.
@property(strong,nonatomic, readonly) PNUUIDMetadataFetchAllData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
