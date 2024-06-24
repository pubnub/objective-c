#import <Foundation/Foundation.h>
#import <PubNub/PNJSONSerializer.h>
#import <PubNub/PNDecoder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// A decoder that restores from JSON.
///
/// ``PubNub Core`` is bundled with set of modules to provide minimal support for rest of modules.
/// This `JSON` decoder rely on ``PNJSONSerialization`` for JSON data de-serialization.
@interface PNJSONDecoder : NSObject <PNDecoder>


#pragma mark - Properties

/// Additional information which can be used by `aClass` custom initializer.
@property(strong, nullable, nonatomic, readonly) NSDictionary *additionalData;

/// Data decoding error.
@property(strong, nullable, nonatomic, readonly) NSError *error;


#pragma mark - Initialization and configuration

/// Create and configure decoder to work with data for specified class.
///
/// Decoder will be configured with `NSJSONSerialization` serializer by-default.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - dictionary: Dictionary with encoded object.
///   - serializer: JSON serializer which conform to ``PNJSONSerializer`` protocol and can be used to parse
///   JSON binary data. Will fallback to `NSJSONSerialization` if set to `nil`.
/// - Returns: Ready to use decoder instance.
+ (instancetype)decoderForClass:(Class)aClass fromDictionary:(NSDictionary *)dictionary;

/// Create and configure decoder to work with data for specified class.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - dictionary: Dictionary with encoded object.
///   - serializer: JSON serializer which conform to ``PNJSONSerializer`` protocol and can be used to parse
///   JSON binary data. Will fallback to `NSJSONSerialization` if set to `nil`.
/// - Returns: Ready to use decoder instance.
+ (instancetype)decoderForClass:(Class)aClass
                 fromDictionary:(NSDictionary *)dictionary
                 withSerializer:(nullable id<PNJSONSerializer>)serializer;

/// Initialization with convenient ``init`` is not allowed.
///
/// - Throws: `PNInterfaceNotAvailable` (API not available) exception.
- (instancetype)init NS_UNAVAILABLE;


#pragma mark - Decode Top-Level Objects

/// Decodes and returns an `object` from JSON data.
///
/// Decode object from JSON data using `NSJSONSerialization` by-default.
///
/// Without information about decoded instance, only following data will be returned:
/// - `NSString`
/// - `NSNumber`
/// - `NSNull`
/// - `NSDictionary`
/// - `NSArray`
///
/// - Parameters:
///   - data: JSON data with encoded object.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
+ (nullable id)decodedObjectFromData:(NSData *)data error:(NSError * _Nullable *)error;

/// Decodes and returns an `object` as instance of `aClass` from JSON data.
///
/// Decode object from JSON data using `NSJSONSerialization` by-default.
///
/// Passed class may conform to ``PubNub Core/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - data: JSON data with encoded object.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
+ (nullable id)decodedObjectOfClass:(Class)aClass fromData:(NSData *)data error:(NSError * _Nullable *)error;

/// Decodes and returns an `object` as instance of `aClass` from JSON data.
///
/// Passed class may conform to ``PubNub Core/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - data: JSON data with encoded object.
///   - serializer: JSON serializer which conform to ``PNJSONSerializer`` protocol and can be used to parse
///   JSON binary data. Will fallback to `NSJSONSerialization` if set to `nil`.
///   - additionalData: Additional information which can be used by `aClass` custom initializer.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
+ (nullable id)decodedObjectOfClass:(Class)aClass
                           fromData:(NSData *)data
                     withSerializer:(nullable id<PNJSONSerializer>)serializer
                     additionalData:(nullable NSDictionary *)additionalData
                              error:(NSError * _Nullable *)error;

/// Decodes and returns an `object` as instance of `aClass` from dictionary.
///
/// Passed class may conform to ``PubNub Core/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - dictionary: Dictionary with encoded object.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
+ (nullable id)decodedObjectOfClass:(Class)aClass
                     fromDictionary:(NSDictionary *)dictionary
                          withError:(NSError * _Nullable *)error;

/// Decodes and returns an `object` as instance of `aClass` from dictionary.
///
/// Passed class may conform to ``PubNub Core/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - dictionary: Dictionary with encoded object.
///   - additionalData: Additional information which can be used by `aClass` custom initializer.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decoded object, or `nil` in case of decoding failure.
+ (nullable id)decodedObjectOfClass:(Class)aClass
                     fromDictionary:(NSDictionary *)dictionary
                 withAdditionalData:(nullable NSDictionary *)additionalData
                              error:(NSError * _Nullable *)error;

/// Decodes and returns a list with `objects` of `aClass` class from array.
///
/// Passed class may conform to ``PubNub Core/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// - Parameters:
///   - cls: Expected class of decoded object in array.
///   - array: Array with encoded objects.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: List of decoded objects, or `nil` in case of decoding failure.
+ (nullable NSArray *)decodedObjectsOfClass:(Class)aClass
                                  fromArray:(NSArray *)array
                                  withError:(NSError * _Nullable *)error;

/// Decodes and returns a list with `objects` of `aClass` class from array.
///
/// Passed class may conform to ``PubNub Core/PNCodable`` protocol which provides assistance with information
/// about what should be decoded. Protocol also provide optional methods which let use custom decoding logic.
///
/// - Parameters:
///   - cls: Expected class of decoded object in array.
///   - array: Array with encoded objects.
///   - additionalData: Additional information which can be used by `aClass` custom initializer.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: List of decoded objects, or `nil` in case of decoding failure.
+ (nullable NSArray *)decodedObjectsOfClass:(Class)aClass
                                  fromArray:(NSArray *)array
                         withAdditionalData:(nullable NSDictionary *)additionalData
                                      error:(NSError * _Nullable *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
