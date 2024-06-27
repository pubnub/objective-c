#import <PubNub/PNSubscribeFileEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `File event` data private extension.
@interface PNSubscribeFileEventData (Private)


#pragma mark - Properties

/// Whether decryption error happened during data processing or not.
@property(assign, nonatomic) BOOL decryptionError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
