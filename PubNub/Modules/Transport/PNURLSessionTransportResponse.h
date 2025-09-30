#import <Foundation/Foundation.h>
#import "PNTransportResponse.h"


#pragma mark Interface declaration

/// `NSURLSession`-based transport response module.
@interface PNURLSessionTransportResponse : NSObject <PNTransportResponse>


#pragma mark - Initialization and Configuration

/// Create transport response object from `NSURLResponse`.
///
/// - Parameters:
///   - response: Remote resource request response.
///   - data: Remote resource request response data.
/// - Returns: Initialized and ready to use transport response object.
+ (nonnull instancetype)responseWithNSURLResponse:(nullable NSURLResponse *)response data:(nullable NSData *)data;

#pragma mark -


@end
