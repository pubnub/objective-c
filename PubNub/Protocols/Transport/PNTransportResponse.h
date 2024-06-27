#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protocol declaration

/// General transport response interface.
///
/// Transport module is responsible for providing implementation for this protocol.
@protocol PNTransportResponse <NSObject>


#pragma mark - Properties

/// Service response headers.
///
/// > Important: Header names are in lowercase.
@property(strong, nullable, nonatomic, readonly) NSDictionary<NSString *, NSString *> *headers;

/// Service response body as stream.
@property(strong, nullable, nonatomic, readonly) NSInputStream *bodyStream;

/// Response content MIME type.
@property(strong, nullable, nonatomic, readonly) NSString *MIMEType;

/// Whether response `body` available as bytes stream or not.
@property(assign, nonatomic, readonly) BOOL bodyStreamAvailable;

/// Service response body.
@property(strong, nullable, nonatomic, readonly) NSData *body;

/// Service response status code.
@property(assign, nonatomic, readonly) NSUInteger statusCode;

/// Full remote resource URL used to retrieve response.
@property(strong, nonatomic, readonly) NSString *url;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
