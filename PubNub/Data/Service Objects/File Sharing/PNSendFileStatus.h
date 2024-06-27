#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNFileSendData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Send file` request provessing status.
@interface PNSendFileStatus : PNAcknowledgmentStatus


#pragma mark - Information

/// `Send file` request processed information.
@property(strong, nonatomic, readonly) PNFileSendData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
