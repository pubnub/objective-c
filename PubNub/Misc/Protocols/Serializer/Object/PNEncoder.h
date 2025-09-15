#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protocol declaration

/// Data encoder protocol.
///
/// Encoders used to preserve data object information during object transition / storage.
/// This protocol describes general interface for communication between user-code and data
/// encoder / serializer.
///
/// Encoders which conform to this protocol will be used by **PubNub** serialization module to serialize
/// objects before using them with **PubNub REST API**.
@protocol PNEncoder <NSObject>


#pragma mark - Properties

/// Encoded object representation in string format.
@property(strong, nullable, nonatomic, readonly) NSString *encodedObjectString;

/// Encoded object representation in binary format.
@property(strong, nullable, nonatomic, readonly) NSData *encodedObjectData;

/// Information about data processing error.
///
/// It is expected that conforming class will stop any data processing in case if error has been signalled.
@property(strong, nullable, nonatomic, readonly) NSError *error;


#pragma mark - Initialization and configuration

/// Initialize data encoder.
///
/// - Returns: Ready to use `encoder` instance.
- (instancetype)init;


#pragma mark - Encoding General Data

/// Creates nested data encoder associated with string key.
///
/// Use this encoder to encode complex nested structures.
///
/// - Parameter key: The key to associated nested encoder with.
- (id<PNEncoder>)nestedEncoderForKey:(NSString *)key;

/// Encodes general `object` as the only data.
///
/// Implementation of this method can hold complicated logic to identify the best approach for data encoding.
/// For example, `NSData` instance can be Base64-encoded and `NSDate` encoded as time interval since 1970.
///
/// Passed object instance may conform to ``PubNub/PNCodable`` protocol which provides assistance with
/// information about what should be encoded. Protocol also provide optional methods which let use custom
/// encoding logic.
///
/// > Note: Implementation may require additional requirements to the type, depending from format into which
/// it will be encoded and may generate ``error`` in case if _`object` data type doesn't fit_.
/// For example, `PNJSONEncoder` will generate an error if the passed object is not an instance of
/// `NSDictionary` or `NSArray`, or custom object because the root object should be `NSDictionary` or
/// `NSArray`.
///
/// - Parameter object: `Object` to encode.
- (void)encodeObject:(id)object;

/// Encodes general `object` and associates it with string key.
///
/// Implementation of this method can hold complicated logic to identify the best approach for data encoding.
/// For example, `NSData` instance can be Base64-encoded and `NSDate` encoded as time interval since 1970.
///
/// Passed object instance may conform to ``PubNub/PNCodable`` protocol which provides assistance with
/// information about what should be encoded. Protocol also provide optional methods which let use custom
/// encoding logic.
///
/// - Parameters:
///   - object: `Object` to encode.
///   - key: The key to associate the value with.
- (void)encodeObject:(id)object forKey:(NSString *)key;

/// Encodes general `object` if not `nil` and associates it with string key.
///
/// Implementation of this method can hold complicated logic to identify the best approach for data encoding.
/// For example, `NSData` instance can be Base64-encoded and `NSDate` encoded as time interval since 1970.
///
/// Passed object instance may conform to ``PubNub/PNCodable`` protocol which provides assistance with
/// information about what should be encoded. Protocol also provide optional methods which let use custom
/// encoding logic.
///
/// - Parameters:
///   - object: `Object` to encode.
///   - key: The key to associate the value with.
- (void)encodeIfPresentObject:(nullable id)object forKey:(NSString *)key;

/// Encodes a `NSString` instance and associates it with string key.
///
/// - Parameters:
///   - string: `NSString` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeString:(NSString *)string forKey:(NSString *)key;

/// Encodes a `NSString` instance if not `nil` and associates it with string key.
///
/// - Parameters:
///   - string: `NSString` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeIfPresentString:(nullable NSString *)string forKey:(NSString *)key;

/// Encodes a `NSNumber` instance and associates it with string key.
///
/// - Parameters:
///   - number: `NSNumber` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeNumber:(NSNumber *)number forKey:(NSString *)key;

/// Encodes a `NSNumber` instance if not `nil` and associates it with string key.
///
/// - Parameters:
///   - number: `NSNumber` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeIfPresentNumber:(nullable NSNumber *)number forKey:(NSString *)key;

/// Encodes a `NSData` instance and associates it with string key.
///
/// - Parameters:
///   - data: `NSData` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeData:(NSData *)data forKey:(NSString *)key;

/// Encodes a `NSData` instance if not `nil` and associates it with string key.
///
/// - Parameters:
///   - data: `NSData` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeIfPresentData:(nullable NSData *)data forKey:(NSString *)key;

/// Encodes a `NSDate` instance and associates it with string key.
///
/// - Parameters:
///   - date: `NSDate` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeDate:(NSDate *)date forKey:(NSString *)key;

/// Encodes a `NSDate` instance if not `nil` and associates it with string key.
///
/// - Parameters:
///   - date: `NSDate` instance to encode.
///   - key: The key to associate the value with.
- (void)encodeIfPresentDate:(nullable NSDate *)date forKey:(NSString *)key;

/// Encodes a `null` value and associates it with string key.
///
/// - Parameter key: The key to associate the value with.
- (void)encodeNilForKey:(NSString *)key;

/// Encodes a `bool` value and associates it with string key.
///
/// - Parameters:
///   - value: `Bool` value to encode.
///   - key: The key to associate the value with.
- (void)encodeBool:(BOOL)value forKey:(NSString *)key;


#pragma mark - Encoding

/// Finalyze encoded data.
- (void)finishEncoding;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
