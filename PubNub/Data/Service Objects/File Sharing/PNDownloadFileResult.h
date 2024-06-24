#import <PubNub/PNOperationResult.h>
#import <PubNub/PNFileDownloadData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Download file` request processing result.
@interface PNDownloadFileResult : PNOperationResult


#pragma mark - Properties

/// `Download file` request processed information.
@property (nonatomic, readonly, strong) PNFileDownloadData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
