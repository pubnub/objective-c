#import <Foundation/Foundation.h>
#import "PNTransport.h"


NS_ASSUME_NONNULL_BEGIN

/// `NSURLSession`-based transport module.
///
/// Transport module utilize `NSURLSession` to make network calls to the remote origin.
@interface PNURLSessionTransport : NSObject <PNTransport>

#pragma mark -

@end

NS_ASSUME_NONNULL_END
