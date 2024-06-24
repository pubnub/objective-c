#import <PubNub/PNHistoryFetchData.h>
#import <Pubnub/PNCryptoProvider.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Fetch history request response data private extension.
@interface PNHistoryFetchData (Private)


#pragma mark - Properties

/// Whether there were decryption error or not.
@property(assign, nonatomic, readonly) BOOL decryptError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
