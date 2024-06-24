#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protocol declaration

/// Data decoder protocol.
///
/// Decoders used to restore data object after it has been received from transition / storage.
/// This protocol describes general interface for communication between user-code and data
/// decoder / de-serializer.
///
/// Decoders which conform to this protocol will be used by **PubNub** serialization module to de-serialize
/// **PubNub REST API** response to objects for proper response representation.
@protocol PNDecoder <NSObject>


#pragma mark - Properties

/// Information about data processing error.
///
/// It is expected that conforming class will stop any data processing in case if error has been signalled.
@property(strong, nullable, nonatomic, readonly) NSError *error;

/// Additional information which can be used by `aClass` custom initializer.
@property(strong, nullable, nonatomic, readonly) NSDictionary *additionalData;


#pragma mark - Initialization and configuration

/// Initialize decoder, which handles data from `binary` data.
///
/// Use suitable deserializes to transform binary data to dictionary.
/// > Note: After initialization, check ``error`` before calling any other methods.
///
/// - Parameter data: Binary serialized data object for processing.
/// - Returns: Ready to use `decoder` instance.
- (instancetype)initForReadingFromData:(NSData *)data;

/// Initialize decoder, which handles data from `dictionary`.
///
/// > Note: After initialization, check ``error`` before calling any other methods.
///
/// - Parameter dictionary: Key / value representation of encoded data.
/// - Returns: Ready to use `decoder` instance.
- (instancetype)initForReadingFromDictionary:(NSDictionary *)dictionary;


#pragma mark - Decode Top-Level Objects

/// Decodes and returns general `object` associated with string key.
///
/// Implementation of this method can hold complicated logic to identify the best approach for data decoding
/// and can affect performance.
///
/// An implementation, for example, may try to parse `NSString` instance as `NSData` by assuming that it is
/// Base64-encoded data string and if it fails, proceed and return `NSString` instance itself.
///
/// > Important: Because of lossy encoding, not all objects can be decoded back automatically because of lack
/// of context. For example, if `NSDate` encoded into `NSNumber` it is hard to figure out without context
/// whether value should be decoded as `NSNumber` or `NSDate` instance. When potential data type confusion is
/// possible, use method dedicated for specific `object` type like: ``decodeNumberForKey:``,
/// ``decodeDataForKey:`` or ``decodeDateForKey:``.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_.
///
/// - Parameters:
///   - key: The key that decoded value is associated with.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeTopLevelObjectForKey:(NSString *)key error:(NSError * _Nullable *)error;

/// Decodes and returns an `object` associated with string key as instance of `aClass`.
///
/// Passed class may conform to ``PubNub/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate `error` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as an instance of specified `class`_.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - key: The key that decoded value is associated with.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeTopLevelObjectOfClass:(Class)aClass
                                    forKey:(NSString *)key
                                     error:(NSError * _Nullable *)error;

/// Decodes and returns an `object` associated with string key as instance of any suitable `classes`.
///
/// Decoder will try instantiate instance from `classes` list one-by-one in same order as they declared and
/// stop if any of them initialized successfully.
///
/// Passed classes may conform to ``PubNub/PNCodable`` protocol which provides assistance with
/// information about what should be decoded. Protocol also provide optional methods which let use custom
/// decoding logic.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate `error` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as any instance of specified `classes` list_.
///
/// - Parameters:
///   - classes: List of expected classes of decoded object.
///   - key: The key that decoded value is associated with.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeTopLevelObjectOfClasses:(NSArray<Class> *)classes
                                      forKey:(NSString *)key
                                       error:(NSError * _Nullable *)error;


#pragma mark - Decoding General Data

/// Nested data decoder associated with string key.
///
/// > Important: It is possible, that nested ``PNDecoder`` can't be instantiated and decoder should generate
/// ``error`` in case if _there is no data associated with `key`_, or _it is `nil`_, or data associated with
/// `key` _is not an instance of `NSDictionary`_.
///
/// - Parameter key: The key that nested data is associated with.
/// - Returns: Instance, which can be used to decode complex nested structures or `nil` in case of ``error``.
- (nullable id<PNDecoder>)nestedDecoderForKey:(NSString *)key;

/// Decodes and returns general `object` which has been encoded as root object.
///
/// Without information about decoded instance, only following data will be returned:
/// - `NSString`
/// - `NSNumber`
/// - `NSNull`
/// - `NSDictionary`
/// - `NSArray`
///
/// > Important: Because of lossy encoding, not all objects can be decoded back automatically because of lack
/// of context. For example, if `NSDate` encoded into `NSNumber` it is hard to figure out without context
/// whether value should be decoded as `NSNumber` or `NSDate` instance. When potential data type confusion is
/// possible, use method dedicated for specific `object` type like: ``decodeNumber``, ``decodeData`` or
/// ``decodeDate``.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data passed to decoder_.
///
/// - Returns: Decoded `object` instance.
- (nullable id)decodeObject;

/// Decodes and returns a `NSString` instance which has been encoded as root object.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data passed to decoder_, or _data can't be decoded as a `NSString` instance_.
///
/// - Returns: Decoded `NSString` instance or `nil` in case of ``error``.
- (nullable NSString *)decodeString;

/// Decodes and returns a `NSNumber` instance which has been encoded as root object.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data passed to decoder_, or _data can't be decoded as a `NSNumber` instance_.
///
/// - Returns: Decoded `NSNumber` instance or `nil` in case of ``error``.
- (nullable NSNumber *)decodeNumber;

/// Decodes and returns a `NSData` instance which has been encoded as root object.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data passed to decoder_, or _data can't be decoded as a `NSData` instance_.
///
/// - Returns: Decoded `NSData` instance or `nil` in case of ``error``.
- (nullable NSData *)decodeData;

/// Decodes and returns a `NSDate` instance which has been encoded as root object.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data passed to decoder_, or _data can't be decoded as a `NSDate` instance_.
///
/// - Returns: Decoded `NSDate` instance or `nil` in case of ``error``.
- (nullable NSDate *)decodeDate;

/// Decodes and returns a root object as instance of `aClass`.
///
/// Decode object as instance of specified class and fail if serialized object doesn't match it.
///
/// - Parameter aClass: Expected class of decoded object.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeObjectOfClass:(Class)aClass;

/// Decodes and returns a root object as instance of any provided `classes`.
///
/// Decoder will try instantiate instance from `classes` list one-by-one in same order as they declared and
/// stop if any of them initialized successfully.
///
/// > Important: ``PNDecoder`` should generate ``error`` in case if _data can't be decoded as any of specified
/// class instances_.
///
/// - Parameter classes: Expected classes of decoded object.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeObjectOfClasses:(NSArray<Class> *)classes;

/// Decodes and returns general `object` associated with string key.
///
/// Implementation of this method can hold complicated logic to identify the best approach for data decoding
/// and can affect performance.
///
/// An implementation, for example, may try to parse `NSString` instance as `NSData` by assuming that it is
/// Base64-encoded data string and if it fails, proceed and return `NSString` instance itself.
///
/// > Important: Because of lossy encoding, not all objects can be decoded back automatically because of lack
/// of context. For example, if `NSDate` encoded into `NSNumber` it is hard to figure out without context
/// whether value should be decoded as `NSNumber` or `NSDate` instance. When potential data type confusion is
/// possible, use method dedicated for specific `object` type like: ``decodeNumberForKey:``,
/// ``decodeDataForKey:`` or ``decodeDateForKey:``.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `object` instance or `nil` in case of ``error``.
- (nullable id)decodeObjectForKey:(NSString *)key;

/// Decodes and returns general `object` associated with string key, if present.
///
/// Implementation of this method can hold complicated logic to identify the best approach for data decoding
/// and can affect performance.
///
/// An implementation, for example, may try to parse `NSString` instance as `NSData` by assuming that it is
/// Base64-encoded data string and if it fails, proceed and return `NSString` instance itself.
///
/// > Important: Because of lossy encoding, not all objects can be decoded back automatically because of lack
/// of context. For example, if `NSDate` encoded into `NSNumber` it is hard to figure out without context
/// whether value should be decoded as `NSNumber` or `NSDate` instance. When potential data type confusion is
/// possible, use method dedicated for specific `object` type like: ``decodeNumberForKey:``,
/// ``decodeDataForKey:`` or ``decodeDateForKey:``.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `object` instance or `nil` in case of ``error``.
- (nullable id)decodeObjectIfPresentForKey:(NSString *)key;

/// Decodes and returns an object associated with string key as instance of `aClass`.
///
/// Decode object as instance of specified class and fail if serialized object doesn't match it.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - key: The key that decoded value is associated with.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeObjectOfClass:(Class)aClass forKey:(NSString *)key;

/// Decodes and returns an object associated with string key as instance of `aClass`, if present.
///
/// Decode object as instance of specified class and fail if serialized object doesn't match it.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as an `aClass` instance_.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - key: The key that decoded value is associated with.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeObjectOfClass:(Class)aClass ifPresentForKey:(NSString *)key;

/// Decodes and returns an object associated with string key as instance of any provided `classes`.
///
/// Decoder will try instantiate instance from `classes` list one-by-one in same order as they declared and
/// stop if any of them initialized successfully.
///
/// - Parameters:
///   - classes: Expected classes of decoded object.
///   - key: The key that decoded value is associated with.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeObjectOfClasses:(NSArray<Class> *)classes forKey:(NSString *)key;

/// Decodes and returns an object associated with string key as instance of any provided `classes`, if
/// present.
///
/// Decoder will try instantiate instance from `classes` list one-by-one in same order as they declared and
/// stop if any of them initialized successfully.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _data can't be
/// decoded as any of specified class instances_.
///
/// - Parameters:
///   - classes: Expected classes of decoded object.
///   - key: The key that decoded value is associated with.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
- (nullable id)decodeObjectOfClasses:(NSArray<Class> *)classes ifPresentForKey:(NSString *)key;

/// Decodes and returns data associated with string key as `NSString` instance.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as a `NSString` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSString` instance or `nil` in case of ``error``.
- (nullable NSString *)decodeStringForKey:(NSString *)key;

/// Decodes and returns data associated with string key as `NSString` instance, if present.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _data associated with `key` can't be decoded as a `NSString` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSString` instance or `nil` in case of ``error``.
- (nullable NSString *)decodeStringIfPresentForKey:(NSString *)key;

/// Decodes and returns data associated with string key as `NSNumber` instance.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as a `NSNumber` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSNumber` instance or `nil` in case of ``error``.
- (nullable NSNumber *)decodeNumberForKey:(NSString *)key;

/// Decodes and returns data associated with string key as `NSNumber` instance, if present.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _data associated with `key` can't be decoded as a `NSNumber` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSNumber` instance or `nil` in case of ``error``.
- (nullable NSNumber *)decodeNumberIfPresentForKey:(NSString *)key;

/// Decodes and returns a `NSData` instance associated with string key.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as a `NSData` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSData` instance or `nil` in case of ``error``.
- (nullable NSData *)decodeDataForKey:(NSString *)key;

/// Decodes and returns a `NSData` instance associated with string key, if present.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _data associated with `key` can't be decoded as a `NSData` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSData` instance or `nil` in case of ``error``.
- (nullable NSData *)decodeDataIfPresentForKey:(NSString *)key;

/// Decodes and returns a `NSDate` instance associated with string key.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as a `NSDate` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSDate` instance or `nil` in case of ``error``.
- (nullable NSDate *)decodeDateForKey:(NSString *)key;

/// Decodes and returns a `NSDate` instance associated with string key, if present.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _data associated with `key` can't be decoded as a `NSDate` instance_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `NSDate` instance or `nil` in case of ``error``.
- (nullable NSDate *)decodeDateIfPresentForKey:(NSString *)key;

/// Decodes and returns a `null` value associated with string key.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or data associated with `key` _can't be decoded as `nil`_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `nil` or `nil` in case of ``error``.
- (nullable NSNull *)decodeNilForKey:(NSString *)key;

/// Decodes and returns a `null` value associated with string key, if present.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _data associated with `key` can't be decoded as a `nil`_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `nil` or `nil` in case of ``error``.
- (nullable NSNull *)decodeNilIfPresentForKey:(NSString *)key;

/// Decodes and returns a `bool` value associated with string key.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _there is no data associated with `key`_, or _it is `nil`_, or data associated with `key` _can't be
/// decoded as a `bool` value_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `bool` value or `NO` in case of ``error``.
- (BOOL)decodeBoolForKey:(NSString *)key;

/// Decodes and returns a `bool` value associated with string key, if present.
///
/// > Important: It is possible, that ``PNDecoder`` can't decode data and should generate ``error`` in case if
/// _data associated with `key` can't be decoded as a `bool` value_.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Decoded `bool` value or `NO` in case of ``error``.
- (BOOL)decodeBoolIfPresentForKey:(NSString *)key;


#pragma mark - Helpers

/// List of encoded object keys.
///
/// > Note: Available only if root object is `NSDictionary`.
///
/// - Returns: List of encoded object keys or `nil` in case if root object is not `NSDictionary` instance.
- (nullable NSArray<NSString *> *)keys;

/// Check if any data associated with `key`.
///
/// - Parameter key: Key for which value should be checked.
/// - Returns: `YES` in case if there is encoded data associated with `key`.
- (BOOL)containsValueForKey:(NSString *)key;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
