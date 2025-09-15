#import <Foundation/Foundation.h>
#import <PubNub/PNLogger.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Base log entry representation object.
@interface PNLogEntry<__covariant MessageType> : NSObject


#pragma mark - Properties

/// Logged message payload.
@property(strong, nullable, nonatomic, readonly) MessageType message;

/// Additional information about the logger message (object, request, or response).
@property(strong, nullable, nonatomic, readonly) NSString *details;

/// Type of data that is passed as ``message``.
@property(assign, atomic, readonly) PNLogMessageType messageType;

/// Minimum log level with which the **PubNub** client has been configured.
///
/// > Note: This information can be used by logger implementations to show more information from a log message.
@property(assign, atomic, readonly) PNLogLevel minimumLogLevel;

/// Unique identifier of the PubNub client instance which generated the log message.
@property(retain, nonatomic, readonly) NSString *pubNubId;

/// Date and time when the log message has been generated.
@property(strong, nonatomic, readonly) NSDate *timestamp;

/// The call site from which a log message has been sent.
@property(copy, nonatomic, readonly) NSString *location;

/// Target log entry level.
@property(assign, atomic, readonly) PNLogLevel logLevel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
