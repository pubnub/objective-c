#import <PubNub/PNSubscribeEventData.h>
#import <PubNub/PNFile.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `File event` data.
@interface PNSubscribeFileEventData : PNSubscribeEventData


#pragma mark - Properties

/// User-specified message type.
@property(strong, nullable, nonatomic, readonly) NSString *customMessageType;

/// Information about file which has been uploaded to `channel`.
@property (nonatomic, nullable, readonly, strong) PNFile *file;

/// Message which has been sent along with uploaded `file` to `channel`.
@property (nonatomic, nullable, readonly, strong) id message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
