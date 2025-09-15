#import <Foundation/Foundation.h>
#import <PubNub/PNLogger.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Console logger.
///
/// Additional logger that will print out log entries to the **Xcode** console.
@interface PNConsoleLogger : NSObject <PNLogger>


#pragma mark -


@end

NS_ASSUME_NONNULL_END
