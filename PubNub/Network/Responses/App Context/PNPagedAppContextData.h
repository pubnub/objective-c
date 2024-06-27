#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Multipage App Context` request response.
///
/// Data object represent response for multipage app context REST API response.
@interface PNPagedAppContextData : PNBaseOperationData


#pragma mark - Properties

/// Cursor bookmark for fetching the next page.
@property(strong, nullable, nonatomic, readonly) NSString *next;

/// Cursor bookmark for fetching the previous page.
@property(strong, nullable, nonatomic, readonly) NSString *prev;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
