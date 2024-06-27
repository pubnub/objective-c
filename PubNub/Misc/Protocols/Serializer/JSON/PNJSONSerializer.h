#import <Foundation/Foundation.h>
#import <PubNub/PNError.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types

/// JSON object deserialization options.
typedef NS_OPTIONS(NSUInteger, PNJSONReadingOptions) {
    /// Make all serialized collections mutable (`NSDictionary`, `NSArray`).
    PNJSONReadingMutableCollections = (1UL << 0)
};

#pragma mark - Protocol interface declaration

/// JSON serializer protocol.
///
/// Protocol for module which will be used by **PubNub** client for sent and received JSON serialization.
@protocol PNJSONSerializer <NSObject>


#pragma mark - Serialization

/// Serialize `object` to JSON data.
///
/// - Throws: Implementation of JSON serializer may throw an exception if passed unsupported data.
///
/// - Parameters:
///   - object: Object for serialization.
///   - error: If an error occurs, upon return contains an `PNError` object that describes the problem.
/// - Returns: `NSData` instance or `nil` in case of serialization error.
- (nullable NSData *)dataWithJSONObject:(id)object error:(PNError * _Nullable * _Nullable)error;

/// Deserialize `object` from JSON `data`.
///
/// - Parameters:
///   - data: JSON data with previously serialized `object`.
///   - error: If an error occurs, upon return contains an `PNError` object that describes the problem.
/// - Returns: Instance restored from JSON data or `nil` in case of deserialization error.
- (id)JSONObjectWithData:(NSData *)data error:(PNError * _Nullable * _Nullable)error;

/// Deserialize `object` from JSON `data`.
///
/// - Parameters:
///   - data: JSON data with previously serialized `object`.
///   - options: JSON data deserialization options.
///   - error: If an error occurs, upon return contains an `PNError` object that describes the problem.
/// - Returns: Instance restored from JSON data or `nil` in case of deserialization error.
- (id)JSONObjectWithData:(NSData *)data
                 options:(PNJSONReadingOptions)options
                   error:(PNError * _Nullable * _Nullable)error;


#pragma mark - Helpers

/// Check `object` contains JSON-friendly data or not.
///
/// - Parameter object: Object which should be checked.
/// - Returns: `YES` if  `object` can be converted to JSON data.
- (BOOL)isValidJSONObject:(id)object;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
