#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNMessageActionFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Add message action` request status.
@interface PNAddMessageActionStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// `Add message action` request processed information.
@property(strong, nonatomic, readonly) PNMessageActionFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
