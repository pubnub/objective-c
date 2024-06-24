#import <Foundation/Foundation.h>
#import <PubNub/PNJSONSerializer.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protocol interface declaration

/// Object serialization protocol.
@protocol PNObjectSerializer <NSObject>


@required

#pragma mark - Properties

/// Pre-configured JSON serializer.
@property(strong, nonatomic, readonly) id<PNJSONSerializer> jsonSerializer;


#pragma mark - Data serialization

/// Serialize `object` instance into different data type.
///
/// - Parameters:
///   - aClass: Expected data type of serialized object data (allowed: `NSString` or `NSData`).
///   - object: Custom or native object which should be serialized.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Serialized `object` data.
- (nullable id)dataOfClass:(Class)aClass fromObject:(id<NSObject>)object withError:(NSError * _Nullable *)error;


@optional

/// De-serialize `data` and populate it to instance of specified class.
///
/// - Parameters:
///   - aClass: Expected class of de-serialized object.
///   - object: Custom or native object which should be serialized.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: De-serialized object, or `nil` in case of decoding failure.
- (nullable id)objectOfClass:(Class)aClass fromData:(id)data withError:(NSError * _Nullable *)error;


@required

/// De-serialize `data` and populate it to instance of specified class.
///
/// - Parameters:
///   - aClass: Expected class of de-serialized object.
///   - object: Custom or native object which should be serialized.
///   - additionalData: Additional information which can be used by `aClass` custom initializer.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: De-serialized object, or `nil` in case of decoding failure.
- (nullable id)objectOfClass:(Class)aClass
                    fromData:(id)data
              withAdditional:(nullable NSDictionary *)additionalData
                       error:(NSError * _Nullable *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
