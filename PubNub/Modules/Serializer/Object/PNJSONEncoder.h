#import <Foundation/Foundation.h>
#import <PubNub/PNJSONSerializer.h>
#import <PubNub/PNEncoder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// A encoder that stores an object's data to an JSON.
///
/// ``PubNub Core`` is bundled with set of modules to provide minimal support for rest of modules.
/// This `JSON` decoder rely on ``PNJSONSerialization`` for JSON data de-serialization.
///
/// Default module for object / data serialization to JSON which is based on
/// ``PubNub Core/PNJSONSerialization``.
@interface PNJSONEncoder : NSObject <PNEncoder>


#pragma mark - Initialization and configuration

/// Initialize JSON encoder.
///
/// - Parameter serializer: JSON serializer which should be used for JSON data generation.
/// - Returns: Ready to use object encoder.
- (instancetype)initWithJSONSerializer:(nullable id<PNJSONSerializer>)serializer NS_DESIGNATED_INITIALIZER;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
