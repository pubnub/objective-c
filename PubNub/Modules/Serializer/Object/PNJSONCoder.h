#import <Foundation/Foundation.h>
#import <PubNub/PNObjectSerializer.h>
#import <PubNub/PNJSONSerializer.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Module for objects and data serialization to JSON and vice-versa.
///
/// Default module for object / data serialization to JSON which is based ``PNJSONSerialization``.
@interface PNJSONCoder : NSObject <PNObjectSerializer>


#pragma mark - Initialization and configuration

/// Create and configure object `coder`.
///
/// `Coder` instance able to `encode` / `decode` instance to / from JSON data.
///
/// - Parameter serializer: Custom JSON serializer which conform to ``PNJSONSerializer`` protocol and can be
/// used to translate serialized object to JSON data .
/// - Returns: `Coder` instance for data processing.
+ (instancetype)coderWithJSONSerializer:(id<PNJSONSerializer>)serializer;

/// Initialization with convenient ``init`` is not allowed.
///
/// - Throws: `PNInterfaceNotAvailable` (API not available) exception.
- (instancetype)init NS_UNAVAILABLE;


#pragma mark - Helpers

/// Clean up resources used by coder.
///
/// Coder associate additional resources with classes to make encoding / decoding faster. This method allow to
/// release most of resources.
+ (void)cleanUpResources;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
