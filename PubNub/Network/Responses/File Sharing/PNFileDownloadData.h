#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Download file` request response.
@interface PNFileDownloadData : PNBaseOperationData


#pragma mark - Properties

/// Whether file is temporary or not.
///
/// > Warning:  Temporary file will be removed as soon as completion block will exit. Make sure to move temporary files
/// (w/o scheduling task on secondary thread) to persistent location.
@property(assign, nonatomic, readonly, getter = isTemporary) BOOL temporary;

/// Location where downloaded file can be found.
@property(strong, nullable, nonatomic, readonly) NSURL *location;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
