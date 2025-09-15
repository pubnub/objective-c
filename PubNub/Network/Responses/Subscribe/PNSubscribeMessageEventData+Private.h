#import <PubNub/PNSubscribeMessageEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Message event` data private extension
@interface PNSubscribeMessageEventData (Private)


#pragma mark - Properties

/// Decryption error happened during data processing or not.
@property(strong, nonatomic) NSError *decryptionError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
