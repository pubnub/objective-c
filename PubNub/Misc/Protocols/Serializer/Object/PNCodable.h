#import <Foundation/Foundation.h>
#import <PubNub/PNEncoder.h>
#import <PubNub/PNDecoder.h>


#pragma mark Classes forward

@class PNJSONEncoder, PNJSONDecoder;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protocol interface declaration

/// Codable object protocol.
///
/// If object adopt this protocol, it is able to specify what properties should be encoded / decoded
/// (including their mapping name in serialized object).
///
/// With optional methods it is possible to customize how ``PubNub/PNEncoder`` and
/// ``PubNub/PNDecoder`` will handle object encoding / decoding.
@protocol PNCodable <NSObject>


#pragma mark - Properties

@optional

/// Map of object property names to name of keys in serialized object and vice-versa.
@property(class, strong, nullable, nonatomic, readonly) NSDictionary<NSString *, NSString *> *codingKeys;

/// List of object property names, which may have different type depending from processed payload for example.
@property(class, strong, nullable, nonatomic, readonly) NSArray<NSString *> *dynamicTypeKeys;

/// List of object property names, which is optional and can be `nil` in encoded / decoded data.
///
/// By default, decoders require that values for all properties to be present in provided data. Decoding error will be generated if value for property
/// not found in data.
@property(class, strong, nullable, nonatomic, readonly) NSArray<NSString *> *optionalKeys;

/// List of object property names, which is not used in encoded / decoded data.
@property(class, strong, nullable, nonatomic, readonly) NSArray<NSString *> *ignoredKeys;


#pragma mark - Instance custom encoding / decoding

/// Restores and returns instance using data provided by decoder.
///
/// When default key / value mapping is not enough and more complex decoding required (for example
/// collection of custom objects) then this method will become in handy.
///
/// This method should be used if previously instance has been encoded using ``encodeObjectWithCoder:``.
///
/// - Parameter coder: Decoder instance with previously encoded information.
/// - Returns: Receiver's instance with data mapped from `coder` or `nil` in case of decoding error.
- (nullable instancetype)initObjectWithCoder:(id<PNDecoder>)coder;

/// Encode receiver's data into encoder.
///
/// With adoption of this protocol, it is possible to customize how an object will be serialized if default
/// key / value mapping is not enough. Also, it is possible to provide more complex serialization logic here
/// (for example, encode a list of objects).
///
/// - Parameter coder: Decoder instance with previously encoded information.
- (void)encodeObjectWithCoder:(id<PNEncoder>)coder;


#pragma mark - Types

/// Dynamic data type for `propertyName`.
///
/// - Parameters:
///   - propertyName: Name of the propery in receiving class for which dynamic data type should be retrieved.
///   - decodedDictionary: Decoded object data.
/// - Returns: Class which should be used to decode object stored in as `propertyName` field.
+ (nullable Class)decodingClassForProperty:(NSString *)propertyName
                       inDecodedDictionary:(NSDictionary *)decodedDictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
