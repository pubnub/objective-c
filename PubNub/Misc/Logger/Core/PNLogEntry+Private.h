#import <PubNub/PNLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Base log entry private extension.
@interface PNLogEntry<MessageType> (Protected)


#pragma mark - Properties

/// Contains string which has been prepared for built-in ``PNConsoleLogger``.
@property(strong, nonatomic) NSString *preProcessedString;

/// Additional information about the logger message (object, request, or response).
@property(strong, nullable, nonatomic) NSString *details;

/// Minimum log level with which the **PubNub** client has been configured.
///
/// > Note: This information can be used by logger implementations to show more information from a log message.
@property(assign, atomic) PNLogLevel minimumLogLevel;

/// Unique identifier of the PubNub client instance which generated the log message.
@property(retain, nonatomic) NSString *pubNubId;

/// The call site from which a log message has been sent.
@property(copy, nonatomic) NSString *location;

/// Target log entry level.
@property(assign, atomic) PNLogLevel logLevel;


#pragma mark - Initialization and Configuration

/// Initialize log entry object.
///
/// - Parameters:
///   - messageType: Type of data that is passed as ``message``.
///   - message: Logged message payload.
/// - Returns: Initialized log entry.
///
- (instancetype)initWithMessageType:(PNLogMessageType)messageType message:(MessageType)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
