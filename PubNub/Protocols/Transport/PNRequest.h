#import <Foundation/Foundation.h>
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNStructures.h>
#import <PubNub/PNError.h>


NS_ASSUME_NONNULL_BEGIN

/// Generic request interface.
@protocol PNRequest <NSObject>


@required

#pragma mark - Properties

/// Transport-independent request.
///
/// Object with all required information needed to use remote origin endpoint.
@property (strong, nonatomic, nullable, readonly) PNTransportRequest *request;

/// Type of request operation.
///
/// One of PubNub REST API endpoints or third-party endpoint.
@property (assign, nonatomic, readonly) PNOperationType operation;


#pragma mark - Prepare

/// Validate provided request parameters.
///
/// - Returns: Error message if request can't be sent without missing or malformed parameters.
- (nullable PNError *)validate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
