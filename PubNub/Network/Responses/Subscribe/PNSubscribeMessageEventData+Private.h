#import <PubNub/PNSubscribeMessageEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Message event` data private extension
@interface PNSubscribeMessageEventData (Private)


#pragma mark - Properties

/// Whether decryption error happened during data processing or not.
@property(assign, nonatomic) BOOL decryptionError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
