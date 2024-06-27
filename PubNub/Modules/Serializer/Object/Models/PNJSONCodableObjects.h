#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Codable objects manager.
///
/// Manager allows to track instances which has been adopted and used with encode / decoder.
@interface PNJSONCodableObjects : NSObject


#pragma mark - Coding / decoding

/// Make provider class codable.
///
/// ``PNJSONCoder`` allows to process custom classes which doesn't conform to ``PNCodable`` protocol, which
/// requires for some implementations to be attached at runtime.
///
/// - Parameter aClass: Custom object class which should be codable.
+ (void)makeCodableClass:(Class)aClass;

/// Clean up all modified custom classes.
///
/// Remove any information which has been attached by code at run-time for all custom classes.
+ (void)clearAllClasses;


#pragma mark - Helpers

/// Check whether `aClass` has custom encoding.
///
/// `aClass` can adopt ``PNCodable/encodeObjectWithCoder:`` method to has more control over object encoding
/// process.
///
/// - Parameter aClass: Class for which check should be done.
/// - Returns: `YES` in case if `aClass` implements ``PNCodable/encodeObjectWithCoder:``.
+ (BOOL)hasCustomEncodingForClass:(Class)aClass;

/// Check whether `aClass` has custom decoding.
///
/// `aClass` can adopt ``PNCodable/initObjectWithCoder:`` method to has more control over object decoding
/// process.
///
/// - Parameter aClass: Class for which check should be done.
/// - Returns: `YES` in case if `aClass` implements ``PNCodable/initObjectWithCoder:``.
+ (BOOL)hasCustomDecodingForClass:(Class)aClass;

/// Retrieve class of property for `aClass`.
///
/// - Parameters:
///   - propertyName: Name of property for which type is required.
///   - aClass: Class for which lookup should be done.
///   - customClass: Upon return can be set to `YES` if property represent custom type.
///   - dynamicClass: Upon return can be set to `YES` if property represent dynamic type (actual type will require
///   passing decoded object to the `aClass`.
+ (nullable Class)classOfProperty:(NSString *)propertyName
                         forClass:(Class)aClass
                           custom:(BOOL * _Nullable)customClass
                          dynamic:(BOOL * _Nullable)dynamicClass;

/// Dynamic data type for `propertyName`.
///
/// - Parameters:
///   - propertyName: Name of the propery in receiving class for which dynamic data type should be retrieved.
///   - aClass: Class for which lookup should be done.
///   - decodedDictionary: Decoded object data.
/// - Returns: Class which should be used to decode object stored in as `propertyName` field.
+ (nullable Class)decodingClassOfProperty:(NSString *)propertyName
                                 forClass:(Class)aClass
                      inDecodedDictionary:(NSDictionary *)decodedDictionary;

/// Property list of instance of `aClass` class.
///
/// - Parameter aClass: Class for which list of properties should be created.
/// - Returns: List of `aClass` instance properties.
+ (NSSet<NSString *> *)propertyListForClass:(Class)aClass;

/// Coding keys for custom class.
///
/// Retrieve coding keys provided by `aClass` implementation or generated from properties list.
///
/// - Parameter aClass: Class for which coding keys map should be retrieved.
/// - Returns: `aClass` coding keys map.
+ (NSDictionary<NSString *, NSString*> *)codingKeysForClass:(Class)aClass;

/// Dynamically typed keys for custom class.
///
/// Retrieve properties provided by `aClass` which may have different type depending from root object type.
///
/// - Parameter aClass: Class for which dynamic type keys list should be retrieved.
/// - Returns: `aClass` dynamic type keys list.
+ (NSArray<NSString *> *)dynamicTypeKeysForClass:(Class)aClass;

/// Optional keys for custom class.
///
/// Retrieve optional keys provided by `aClass` implementation or empty list.
///
/// - Parameter aClass: Class for which optional keys list should be retrieved.
/// - Returns: `aClass` optional keys list.
+ (NSArray<NSString *> *)optionalKeysForClass:(Class)aClass;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
