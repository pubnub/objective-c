#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNFileGenerateUploadURLData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Generate file upload URL` request processing status.
@interface PNGenerateFileUploadURLStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// `Generate file upload URL` request processed information.
@property(strong, nonatomic, readonly) PNFileGenerateUploadURLData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
