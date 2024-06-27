#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General request for all paginated `App Context` API endpoints.
@interface PNObjectsPaginatedRequest : PNBaseObjectsRequest


#pragma mark - Properties

/// Response results sorting order.
///
/// List of criteria (name of the field) which will be used for sorting in ascending order (by default).
/// To change sorting order, append `:asc` (for ascending) or `:desc` (descending) to field name.
@property(strong, nullable, nonatomic) NSArray<NSString *> *sort;

/// Expression to filter out results basing on specified criteria.
@property(copy, nullable, nonatomic) NSString *filter;

/// Previously-returned cursor bookmark for fetching the next page.
@property(copy, nullable, nonatomic) NSString *start;

/// Previously-returned cursor bookmark for fetching the previous page.
///
/// > Note: Ignored if you also supply the `start` parameter.
@property(copy, nullable, nonatomic) NSString *end;

/// Number of objects to return in response..
///
/// > Note: Will be set to `100` (which is also maximum value) if not specified.
@property(assign, nonatomic) NSUInteger limit;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

