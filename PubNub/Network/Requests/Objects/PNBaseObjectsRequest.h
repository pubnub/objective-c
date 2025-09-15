#import <PubNub/PNBaseRequest.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General request for all `App Context` API endpoints.
@interface PNBaseObjectsRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
