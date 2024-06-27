#import <PubNub/PNOperationResult.h>
#import <PubNub/PNFileListFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `List files` request processing result.
@interface PNListFilesResult : PNOperationResult


#pragma mark - Properties

/// `List files` request processed information.
@property(strong, nonatomic, readonly) PNFileListFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
