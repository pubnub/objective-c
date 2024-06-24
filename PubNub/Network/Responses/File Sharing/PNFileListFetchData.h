#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNFile.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `List files` request response.
@interface PNFileListFetchData : PNBaseOperationData


#pragma mark - Properties

/// List of channel `files`.
@property(strong, nullable, nonatomic, readonly) NSArray<PNFile *> *files;

/// Cursor bookmark for fetching the next page.
@property(strong, nullable, nonatomic, readonly) NSString *next;

/// How many `files` has been returned.
@property(assign, nonatomic, readonly) NSUInteger count;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
