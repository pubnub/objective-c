#import "PNLogEntry+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Base log entry private extension.
@interface PNLogEntry<MessageType> ()


#pragma mark - Properties

/// Contains string which has been prepared for built-in ``PNConsoleLogger``.
@property(strong, nonatomic) NSString *preProcessedString;

/// Logged message payload.
@property(strong, nullable, nonatomic) MessageType message;

/// Additional information about the logger message (object, request, or response).
@property(strong, nullable, nonatomic) NSString *details;

/// Type of data that is passed as ``message``.
@property(assign, atomic) PNLogMessageType messageType;

/// Minimum log level with which the **PubNub** client has been configured.
///
/// > Note: This information can be used by logger implementations to show more information from a log message.
@property(assign, atomic) PNLogLevel minimumLogLevel;

/// Unique identifier of the PubNub client instance which generated the log message.
@property(retain, nonatomic) NSString *pubNubId;

/// Date and time when the log message has been generated.
@property(strong, nonatomic) NSDate *timestamp;

/// The call site from which a log message has been sent.
@property(copy, nonatomic) NSString *location;

/// Target log entry level.
@property(assign, atomic) PNLogLevel logLevel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNLogEntry


#pragma mark - Initialization and Configuration

- (instancetype)initWithMessageType:(PNLogMessageType)messageType message:(id)message {
    if ((self = [super init])) {
        _timestamp = [NSDate date];
        _messageType = messageType;
        _message = message;
        
    }

    return self;
}

#pragma mark -


@end
