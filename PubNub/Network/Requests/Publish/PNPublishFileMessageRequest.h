#import <PubNub/PNBasePublishRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Publish file message` request.
@interface PNPublishFileMessageRequest : PNBasePublishRequest


#pragma mark - Properties

/// Unique identifier provided during file upload.
@property(copy, nonatomic, readonly) NSString *identifier;

/// Name with which uploaded data has been stored.
@property(copy, nonatomic, readonly) NSString *filename;


#pragma mark - Initialization and Configuration

/// Create `File message publish` request.
///
/// - Parameters:
///   - channel: Name of channel to which `file message` should be published.
///   - identifier: Unique identifier provided during file upload.
///   - filename: Name with which uploaded data has been stored.
/// - Returns: Ready to use `publish message` request.
+ (instancetype)requestWithChannel:(NSString *)channel fileIdentifier:(NSString *)identifier name:(NSString *)filename;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
