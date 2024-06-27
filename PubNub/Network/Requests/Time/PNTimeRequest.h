#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN


#pragma mark Interface implementation

/// `PubNub high-precision time` request.
@interface PNTimeRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
