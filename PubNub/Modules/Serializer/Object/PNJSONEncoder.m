#import "PNJSONEncoder.h"
#import <objc/runtime.h>
#import <PubNub/PNFunctions.h>
#import <PubNub/PNCodable.h>
#import <PubNub/PNError.h>
#import "PNJSONCodableObjects.h"


#pragma mark Static

static Class _encDictionaryClass, _encEncoderClass, _encStringClass, _encNumberClass, _encArrayClass;
static Class _encSetClass, _encDataClass, _encNullClass, _encDateClass;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNJSONEncoder ()


#pragma mark - Properties

/// Block which is used for `NSData` encoding to JSON-friendly data type.
@property (class, strong, readonly, nonatomic) NSString * (^dataEncodingStrategy)(NSData *data);

/// Block which is used for `NSDate` encoding to JSON-friendly data type.
@property (class, strong, readonly, nonatomic) NSNumber * (^dateEncodingStrategy)(NSDate *date);

/// Reference on encoder and it's location in encoded hierarchy.
///
/// Map used for performance optimisation during nested ``PNJSONEncoder`` encoding.
@property(strong, nullable, nonatomic) NSMutableArray<NSArray *> *encodersMap;

/// Configured foundation object to JSON data serializer.
@property(strong, nullable, nonatomic) id<PNJSONSerializer> serializer;

/// Object encoding error.
@property(strong, nullable, nonatomic) NSError *encodingError;

/// JSON-encodable representation of encoded object.
///
/// > Important: After ``finishEncoding`` method call all non-encodable values will be replaced with encodable
/// (if possible).
@property (strong, nullable, nonatomic) id encodableValue;


#pragma mark - Encoding

/// Encodes and returns JSON-friendly data type for `value`.
///
/// - Parameter value: Data which should be encoded into JSON-friendly data type.
/// - Returns: JSON-friendly data or `nil` if passed `value` can't be converted to JSON-friendly data type.
- (nullable id)encodableObjectFrom:(id)value;

/// Encodes provided `value` as `NSDictionary`.
///
/// Recursively pre-process all values of provided dictionary to be encoded into JSON-friendly data type.
///
/// - Parameter value: Dictionary who's values should be encoded into JSON-friendly data types.
/// - Returns: Dictionary where all values encoded into JSON-friendly data types or `nil` if passed `value`
/// can't be converted to JSON-friendly data type.
- (nullable NSMutableDictionary *)encodedNSDictionary:(NSDictionary *)value;

/// Encodes provided `value` and associates with string `key`  in `storage`.
///
/// - Parameters:
///   - value: Data which should be encoded.
///   - key: Key with which encoded value should be associated.
///   - storage: Store in which encoded data will be stored.
- (void)encodeObject:(id)value forKey:(NSString *)key in:(NSMutableDictionary *)storage;

/// Encodes provided `value` as `NSArray`.
///
/// Recursively pre-process all elements of provided array to be encoded into JSON-friendly data type.
///
/// - Parameter value: Array who's elements should be encoded into JSON-friendly data types.
/// - Returns: Array where all elements encoded into JSON-friendly data types or `nil` if passed `value` can't
/// be converted to JSON-friendly data type.
- (nullable NSMutableArray *)encodedNSArray:(NSArray *)value;

/// Encodes provided `value` as custom object.
///
/// With default implementation custom object will be encoded into `NSDictionary` instance, but if it conforms
/// to ``PNCodable`` protocol, then it is possible to specify custom encoding algorithm, which should be used
/// to decode object later.
///
/// Pre-process custom object with it's properties to be encoded into JSON-friendly data type.
///
/// - Parameter value: Array who's elements should be encoded into JSON-friendly data types.
/// - Returns: Encoded custom object in preferred data type of `nil` if passed `value` can't be converted to
/// JSON-friendly data type.
- (nullable id)encodedCustomObject:(id)value;


#pragma mark - Serialization

/// Serialize encoded object into JSON data.
///
/// - Parameter serializer: JSON serializer which should be used to handle encoded object.
/// - Returns: `NSData` with JSON data or `nil` in case of serialization error.
- (nullable NSData *)jsonDataWithJSONSerializer:(nullable id<PNJSONSerializer>)serializer;

/// Serialize encoded object into JSON string.
///
/// - Parameter serializer: JSON serializer which should be used to handle encoded object.
/// - Returns: `NSString` with JSON or `nil` in case of serialization error.
- (nullable NSString *)jsonStringWithJSONSerializer:(nullable id<PNJSONSerializer>)serializer;


#pragma mark - Errors

/// Unable to encode property error.
///
/// Error which signalled when specified `name` from `codingKeys` is missing in a `aClass` interface.
///
/// - Parameters:
///   - name: Name of property from `codingKeys`.
///   - aClass: Class for which property encoding failed.
/// - Returns: Missing property error.
- (PNError *)encodingErrorForMissingProperty:(NSString *)name inClass:(Class)aClass;

/// Unable to encode value error.
///
/// Encoder wasn't able to handle provider `value`. Error may happen, when encoder doesn't have implementation
/// to handle specific type of data.
///
/// - Parameters:
///   - value: Object which wasn't encoded.
///   - key: Name of property with encoded value.
/// - Returns: Value encoding error.
- (PNError *)encodingErrorUnsupportedTypeOfValue:(id)value forKey:(nullable NSString *)key;

/// Unable to serialize encoded object to JSON.
///
/// Error which signalled when resulting object has unexpected root object or any it's nested values has
/// unsupported data type.
///
/// - Parameter error: Error instance from underlying libraries which serialize JSON object.
/// - Returns: Encoded object serialization error.
- (PNError *)encodingErrorForJSONSerializationWithError:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNJSONEncoder


#pragma mark - Properties

+ (NSString * (^)(NSData *))dataEncodingStrategy {
    static NSString * (^_dataEncodingStrategy)(NSData *);
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _dataEncodingStrategy = ^NSString *(NSData *data) {
            return [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
        };
    });

    return _dataEncodingStrategy;
}

+ (NSNumber * (^)(NSDate *))dateEncodingStrategy {
    static NSNumber * (^_dateEncodingStrategy)(NSDate *);
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _dateEncodingStrategy = ^NSNumber *(NSDate *date) {
            return [NSNumber numberWithDouble:date.timeIntervalSince1970];
        };
    });

    return _dateEncodingStrategy;
}

- (NSError *)error {
    return self.encodingError;
}

- (NSData *)encodedObjectData {
    return [self jsonDataWithJSONSerializer:self.serializer];
}

- (NSString *)encodedObjectString {
    return [self jsonStringWithJSONSerializer:self.serializer];
}


#pragma mark - Initialization and Configuration

+ (void)load {
    _encDictionaryClass = [NSDictionary class];
    _encEncoderClass = [PNJSONEncoder class];
    _encStringClass = [NSString class];
    _encNumberClass = [NSNumber class];
    _encArrayClass = [NSArray class];
    _encDateClass = [NSDate class];
    _encDataClass = [NSData class];
    _encNullClass = [NSNull class];
    _encSetClass = [NSSet class];
}

- (instancetype)init {
    return [self initWithJSONSerializer:nil];
}

- (instancetype)initWithJSONSerializer:(id<PNJSONSerializer>)serializer {
    if ((self = [super init])) {
        _encodableValue = [NSMutableDictionary new];
        _encodersMap = [NSMutableArray new];
        _serializer = serializer;
    }

    return self;
}


#pragma mark - Encoding General Data

- (id<PNEncoder>)nestedEncoderForKey:(NSString *)key {
    PNJSONEncoder *encoder = [[PNJSONEncoder alloc] initWithJSONSerializer:self.serializer];
    [self.encodersMap addObject:@[encoder, key, self.encodableValue]];

    return encoder;
}

- (void)encodeObject:(id)object {
    id encodableObject = [self encodableObjectFrom:object];

    if (!encodableObject) {
        self.encodableValue = nil;
        return;
    }

    if (!PNNSObjectIsKindOfAnyClass(encodableObject, @[_encDictionaryClass, _encArrayClass])) {
        self.encodingError = [self encodingErrorForJSONSerializationWithError:nil];
        self.encodableValue = nil;
    } else {
        self.encodableValue = encodableObject;
    }
}

- (void)encodeObject:(id)object forKey:(NSString *)key {
    id encodedObject = [self encodableObjectFrom:object];

    if (encodedObject) {
        [self encodeObject:encodedObject forKey:key in:self.encodableValue];
    } else if (!self.encodingError) {
        self.encodingError = [self encodingErrorUnsupportedTypeOfValue:object forKey:key];
    }
}

- (void)encodeIfPresentObject:(id)object forKey:(NSString *)key {
    if (object) [self encodeObject:object forKey:key];
}

- (void)encodeString:(NSString *)string forKey:(NSString *)key {
    if (string) {
        self.encodableValue[key] = string;
    } else {
        self.encodingError = [self encodingErrorUnsupportedTypeOfValue:@"NSString" forKey:key];
    }
}

- (void)encodeIfPresentString:(NSString *)string forKey:(NSString *)key {
    if (string != nil) [self encodeString:string forKey:key];
}

- (void)encodeNumber:(NSNumber *)number forKey:(NSString *)key {
    if (number != nil) {
        self.encodableValue[key] = number;
    } else {
        self.encodingError = [self encodingErrorUnsupportedTypeOfValue:@"NSNumber" forKey:key];
    }
}

- (void)encodeIfPresentNumber:(NSNumber *)number forKey:(NSString *)key {
    if (number != nil) [self encodeNumber:number forKey:key];
}

- (void)encodeData:(NSData *)data forKey:(NSString *)key {
    id encodedObject = [self encodableObjectFrom:data];

    if (encodedObject) {
        self.encodableValue[key] = encodedObject;
    } else if (!self.encodingError) {
        self.encodingError = [self encodingErrorUnsupportedTypeOfValue:data forKey:key];
    }
}

- (void)encodeIfPresentData:(NSData *)data forKey:(NSString *)key {
    if (data) [self encodeData:data forKey:key];
}

- (void)encodeDate:(NSDate *)date forKey:(NSString *)key {
    id encodedObject = [self encodableObjectFrom:date];

    if (encodedObject) {
        self.encodableValue[key] = encodedObject;
    } else if (!self.encodingError) {
        self.encodingError = [self encodingErrorUnsupportedTypeOfValue:date forKey:key];
    }
}

- (void)encodeIfPresentDate:(NSDate *)date forKey:(NSString *)key {
    if (date) [self encodeDate:date forKey:key];
}

- (void)encodeNilForKey:(NSString *)key {
    self.encodableValue[key] = [NSNull null];
}

- (void)encodeBool:(BOOL)value forKey:(NSString *)key {
    NSNumber *boolValue = [NSNumber numberWithBool:value];
    self.encodableValue[key] = boolValue;
}


#pragma mark - Encoding

- (id)encodableObjectFrom:(id<NSObject>)value {
    if (value == nil) return nil;

    Class aClass = [value class];
    id encodableObject = nil;

    if (PNNSObjectIsSubclassOfAnyClass(value, @[_encStringClass, _encNumberClass, _encNullClass])) {
        encodableObject = value;
    } else if ([aClass isSubclassOfClass:_encDictionaryClass]) {
        encodableObject = [self encodedNSDictionary:(id)value];
    } else if ([aClass isSubclassOfClass:_encArrayClass]) {
        encodableObject = [self encodedNSArray:(id)value];
    } else if ([aClass isSubclassOfClass:_encSetClass]) {
        encodableObject = [self encodedNSArray:((NSSet *)value).allObjects];
    } else if ([aClass isSubclassOfClass:_encEncoderClass]) {
        [(PNJSONEncoder *)value finishEncoding];
        encodableObject = ((PNJSONEncoder *)value).encodableValue;
    } else if ([aClass isSubclassOfClass:_encDataClass]) {
        encodableObject = PNJSONEncoder.dataEncodingStrategy((id)value);
    } else if ([aClass isSubclassOfClass:_encDateClass]) {
        encodableObject = PNJSONEncoder.dateEncodingStrategy((id)value);
    } else if (strncmp(class_getName(aClass), "NS", 2) != 0) {
        encodableObject = [self encodedCustomObject:(id)value];
    }

    return encodableObject;
}

- (NSMutableDictionary *)encodedNSDictionary:(NSDictionary *)value {
    NSMutableDictionary *storage = [NSMutableDictionary new];
    __block BOOL encodingFailed = NO;

    [value enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [self encodeObject:obj forKey:key in:storage];

        encodingFailed = self.encodingError != nil;
        *stop = encodingFailed;
    }];

    return !encodingFailed ? storage : nil;
}

- (void)encodeObject:(id)value forKey:(NSString *)key in:(NSMutableDictionary *)storage {
    id encodedObject = [self encodableObjectFrom:value];

    if (encodedObject) {
        storage[key] = encodedObject;
    } else if (!self.encodingError) {
        self.encodingError = [self encodingErrorUnsupportedTypeOfValue:value forKey:key];
    }
}

- (NSMutableArray *)encodedNSArray:(NSArray *)value {
    NSMutableArray *storage = [NSMutableArray new];
    __block BOOL encodingFailed = NO;

    [value enumerateObjectsUsingBlock:^(id obj, NSUInteger __unused idx, BOOL *stop) {
        id encodedObject = [self encodableObjectFrom:obj];

        if (encodedObject) {
            [storage addObject:encodedObject];
        } else if (!self.encodingError) {
            self.encodingError = [self encodingErrorUnsupportedTypeOfValue:obj forKey:nil];
        }

        encodingFailed = self.encodingError != nil;
        *stop = encodingFailed;
    }];

    return !encodingFailed ? storage : nil;
}

- (id)encodedCustomObject:(id<PNCodable>)value {
    Class objectClass = [value class];
    __block BOOL encodingFailed = NO;
    id encodedObject = nil;

    [PNJSONCodableObjects makeCodableClass:objectClass];

    if ([PNJSONCodableObjects hasCustomEncodingForClass:objectClass]) {
        PNJSONEncoder *encoder = [[PNJSONEncoder alloc] initWithJSONSerializer:self.serializer];
        [(id<PNCodable>)value encodeObjectWithCoder:encoder];
        [encoder finishEncoding];

        encodedObject = encoder.encodableValue;
    } else {
        NSSet<NSString *> *properties = [PNJSONCodableObjects propertyListForClass:objectClass];
        NSDictionary *codingKeyMap = [PNJSONCodableObjects codingKeysForClass:objectClass];
        NSMutableDictionary *storage = [NSMutableDictionary new];

        [codingKeyMap enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *map, BOOL *stop) {
            if ([properties containsObject:name]) {
                id object = [(id)value valueForKey:name];
                // Runtime can't detect optional properties, so encode them if they are present.
                if (object) [self encodeObject:object forKey:map in:storage];
            } else {
                self.encodingError = [self encodingErrorForMissingProperty:name inClass:objectClass];
            }

            encodingFailed = self.encodingError != nil;
            *stop = encodingFailed;
        }];

        if (!self.encodingError) encodedObject = storage;
    }

    return encodedObject;
}

- (NSData *)jsonDataWithJSONSerializer:(id<PNJSONSerializer>)serializer {
    // Early exit if encoding error already generated.
    if (self.encodingError) return nil;

    return serializer ? [serializer dataWithJSONObject:self.encodableValue error:nil]
                      : [NSJSONSerialization dataWithJSONObject:self.encodableValue options:0 error:nil];
}

- (NSString *)jsonStringWithJSONSerializer:(id<PNJSONSerializer>)serializer {
    // Early exit if encoding error already generated.
    if (self.encodingError) return nil;

    NSString *json;
    NSData *jsonData = [self jsonDataWithJSONSerializer:serializer];
    if (jsonData) json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return json;
}

- (void)finishEncoding {
    for (NSArray *encodersMap in self.encodersMap) {
        PNJSONEncoder *nestedEncoder = encodersMap[0];
        [nestedEncoder finishEncoding];
        encodersMap[2][encodersMap[1]] = nestedEncoder.encodableValue;
    }

    self.encodersMap = nil;
}


#pragma mark - Errors

- (PNError *)encodingErrorForMissingProperty:(NSString *)name inClass:(Class)aClass {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to encode object to JSON.",
        PNStringFormat(@"'%@' property not found in %@ class.", name, NSStringFromClass(aClass)),
        @"Ensure that property name is not miss-typed in -codingKeys method.",
        nil
    );

    return [PNError errorWithDomain:PNJSONEncoderErrorDomain
                               code:PNJSONEncodingErrorPropertyNotFound
                           userInfo:userInfo];
}

- (PNError *)encodingErrorUnsupportedTypeOfValue:(id)value forKey:(NSString *)key {
    NSCharacterSet *trimmingCharset = [NSCharacterSet punctuationCharacterSet];
    NSString *type = [NSStringFromClass([value class]) stringByTrimmingCharactersInSet:trimmingCharset];
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to encode object to JSON.",
        PNStringFormat(@"Unable encode object%@: %@ (%@)", key ? PNStringFormat(@" for '%@' key", key) : @"", value,
                       type),
        @"Make sure that object or it's properties has supported data type (NSNumber, NSString, NSData, "
         "NSDate, NSDictionary, NSArray, NSSet, custom object) or exclude it by adopting PNCodable and "
         "instructing on fields for encoding with `-codingKeys`.",
        nil
    );

    return [PNError errorWithDomain:PNJSONEncoderErrorDomain code:PNJSONEncodingErrorType userInfo:userInfo];
}

- (PNError *)encodingErrorForJSONSerializationWithError:(NSError *)error {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to encode object to JSON.",
        @"One of few properties of encoded object has unsupported data type.",
        @"Make sure that all properties has supported data types (NSNumber, NSString, NSData, NSDate, "
         "NSDictionary, NSArray) or exclude fields by adopting PNCodable and instructing on fields for "
         "encoding with `-codingKeys`.",
        error
    );

    return [PNError errorWithDomain:PNJSONEncoderErrorDomain code:PNJSONEncodingErrorType userInfo:userInfo];
}

#pragma mark -


@end
