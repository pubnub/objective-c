#import "PNJSONDecoder+Private.h"
#import <objc/runtime.h>
#import <PubNub/PNFunctions.h>
#import <PubNub/PNCodable.h>
#import <PubNub/PNError.h>
#import "NSNumberFormatter+PNJSONCodable.h"
#import "NSDateFormatter+PNJSONCodable.h"
#import "PNJSONCodableObjects.h"


#pragma mark Static


static Class _decMutableDictionaryClass, _decMutableArrayClass, _decMutableSetClass, _decMutableStringClass;
static Class _decMutableDataClass, _decDictionaryClass, _decArrayClass, _decSetClass, _decStringClass;
static Class _decNumberClass, _decNullClass, _decDataClass, _decDateClass;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNJSONDecoder ()


#pragma mark - Properties

/// Block, which is used for `NSDate` decoding from JSON data.
@property(class, strong, nonatomic, readonly) NSDate * _Nullable (^dateDecodingStrategy)(NSString *date);

/// Block, which is used for `NSData` decoding from JSON data.
@property(class, strong, nonatomic, readonly) NSData * (^dataDecodingStrategy)(NSString *data, BOOL mutable);

/// Map of serialized property name to actual property name in specified class.
@property(strong, nullable, nonatomic) NSDictionary<NSString *, NSString *> *codingKeys;

/// List of object property names, which is optional and can be `nil` in encoded / decoded data.
@property(strong, nullable, nonatomic) NSArray<NSString *> *optionalKeys;

/// Configured foundation object to JSON data deserializer.
@property(strong, nullable, nonatomic) id<PNJSONSerializer> serializer;

/// Additional information which can be used by `aClass` custom initializer.
@property(strong, nullable, nonatomic) NSDictionary *additionalData;

/// Object decoding error.
@property(strong, nullable, nonatomic) NSError *decodingError;

/// Class of instance, which should be decoded from provided data.
@property(strong, nullable, nonatomic) Class instanceClass;

/// Object, which stores JSON deserialized object used for data decoding.
@property(strong, nullable, nonatomic) id decodableValue;


#pragma mark - Initialization and configuration

/// Initialize decoder with JSON data object.
///
/// Decode object of `aClass` type from provided JSON data object.
/// It is possible that passed `data` object is serialized `NSArray`, but in this case, it is **required** from
/// `cClass` to adopt ``PNCodable`` protocol and implement ``PNCodable/initObjectWithCoder:`` method.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - data: JSON data with encoded object.
///   - serializer: JSON serializer which conform to ``PNJSONSerializer`` protocol and can be used to parse
///   JSON binary data. Will fallback to `NSJSONSerialization` if set to `nil`.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Initialized decoder for JSON data processing.
- (instancetype)initForReadingObjectOfClass:(nullable Class)aClass
                                   fromData:(NSData *)data
                             withSerializer:(nullable id<PNJSONSerializer>)serializer
                                      error:(NSError * _Nullable *)error;

/// Initialize decoder with JSON object.
///
/// Decode object of `aClass` type from provided JSON object.
/// It is possible that passed `object` is an instance of `NSArray`, but in this case, it is **required** from
/// `cClass` to adopt ``PNCodable`` protocol and implement ``PNCodable/initObjectWithCoder:`` method.
///
/// - Parameters:
///   - aClass: Expected class of decoded object.
///   - object: One of `NSDictionary` or `NSArray` instances (later possible only with custom decoding).
///   - serializer: JSON serializer which conform to ``PNJSONSerializer`` protocol and can be used to parse
///   JSON binary data. Will fallback to `NSJSONSerialization` if set to `nil`.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Initialized decoder for JSON data processing.
- (instancetype)initForReadingObjectOfClass:(nullable Class)aClass
                                 fromObject:(id)object
                             withSerializer:(nullable id<PNJSONSerializer>)serializer
                                      error:(NSError * _Nullable *)error;


#pragma mark - Helpers

/// Retrieve data associated with string key.
///
/// - Parameter key: The key that decoded value is associated with.
/// - Returns: Encoded object, or `nil` in case if there is no associated data.
- (nullable id<NSObject>)objectForKey:(NSString *)key;

/// Check whether specified key is present in provided data.
///
/// - Parameter key: Key for which presence in data should be checked.
/// - Returns: `YES` if key is present in encoded data.
- (BOOL)hasKey:(NSString *)key;

/// Check whether value associated with string key is _optional_.
///
/// - Parameter key: Key for which _optional_ value should be checked.
/// - Returns: `YES` if key represent _optional_ value.
- (BOOL)isOptionalKey:(NSString *)key;

/// Deserialize encoded object from JSON data.
///
/// - Parameters:
///   - jsonData: JSON data object for deserialization.
///   - serializer: JSON serializer which conform to ``PNJSONSerializer`` protocol and can be used to parse
///   JSON binary data. Will fallback to `NSJSONSerialization` if set to `nil`.
///   - mutableCollections: Whether all collections within `data` should be initialized as mutable or not.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Deserialized object, or `nil` in case of deserialization error.
- (nullable id)objectFromData:(NSData *)jsonData
               withSerializer:(nullable id<PNJSONSerializer>)serializer
                      mutable:(BOOL)mutableCollections
                        error:(PNError **)error;


#pragma mark - Errors

/// The decoder is unable to process empty / non- JSON data.
///
/// - Returns: Empty JSON data error.
- (PNError *)decodingErrorEmptyData;

/// The decoder is unable to process malformed JSON data.
///
/// - Parameter error: Error instance from underlying libraries which deserialize JSON object.
/// - Returns: Malformed JSON data error.
- (PNError *)decodingErrorMalformedDataWithError:(NSError *)error;

/// The decoder is unable to process data because initialized with empty object.
///
/// - Returns: Empty data object error.
- (PNError *)decodingErrorMissingData;

/// The decoder is unable to initialize with unexpected data type.
///
/// The decoder requires that the root element should be an instance of `NSDictionary`.
///
/// - Parameter aClass: Class of instance which has been passed to
/// ``PNDecoder/initForReadingFromDictionary:``.
/// - Returns: Unexpected root object error.
- (PNError *)decodingErrorWrongRootObjectClass:(Class)aClass;

/// The decoder is unable to perform the requested operation.
///
/// - Parameter operation: Name of method which has been called and not supported in current context.
/// - Returns: Unsupported operation error.
- (PNError *)decodingErrorInvalidOperation:(NSString *)operation;

/// The decoder is unable to decode the object as an instance of specified class.
///
/// - Parameters:
///   - value: Object which should be decoded.
///   - aClass: Expected class of decoded object.
/// - Returns: Unable to decode error.
- (PNError *)decodingErrorUnableDecodeValue:(id)value asInstanceOfClass:(nullable Class)aClass;

/// The decoder is unable to decode the object as an instance of any specified classes.
///
/// - Parameters:
///   - value: Object which should be decoded.
///   - classes: Expected classes of decoded object.
/// - Returns: Unable to decode error.
- (PNError *)decodingErrorUnableDecodeValue:(id)value asInstanceOfAnyClass:(NSArray<Class> *)classes;

/// The decoder is unable to decode the object because of type mismatch.
///
/// - Parameters:
///   - objectType: Expected type to which value should be decoded.
///   - unexpectedType: Type of data associated with string key which can't be decoded into expected type.
///   - key: The key that the decoded value is associated with.
/// - Returns: Type mismatch error.
- (PNError *)decodingErrorObjectOfType:(NSString *)objectType
                     forUnexpectedType:(NSString *)unexpectedType
                                   key:(nullable NSString *)key;

/// The decoder is unable to decode error because the value associated with string key is `nil`.
///
/// Error, which signalled when `nil` associated with string `key`.
///
/// - Parameters:
///   - objectType: Data type which is expected to be associated with string key.
///   - key: The key that the decoded value is associated with.
/// - Returns: Missing value error.
- (PNError *)decodingErrorForMissingValueOfType:(NSString *)objectType forKey:(NSString *)key;

/// The decoder is unable to decode error because key is missing.
///
/// Error, which signalled when specified `key` not found in provided data.
///
/// - Parameters:
///   - objectType: Data type which is expected to be associated with string key.
///   - key: The key that the decoded value is associated with.
/// - Returns: Missing key error.
- (PNError *)decodingErrorObjectOfType:(nullable NSString *)objectType forMissingKey:(NSString *)key;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNJSONDecoder


#pragma mark - Properties

+ (NSData * (^)(NSString *, BOOL))dataDecodingStrategy {
    static NSData * (^_dataDecodingStrategy)(NSString *, BOOL);
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _dataDecodingStrategy = ^NSData * (NSString *data, BOOL mutable) {
            Class dataClass = !mutable ? _decDataClass : _decMutableDataClass;
            return [[dataClass alloc] initWithBase64EncodedString:data options:0];
        };
    });

    return _dataDecodingStrategy;
}

+ (NSDate * (^)(NSString *))dateDecodingStrategy {
    static NSDate * (^_dateDecodingStrategy)(id<NSObject>);
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _dateDecodingStrategy = ^NSDate * (id<NSObject> date) {
            NSDate *parsed;

            if ([[date class] isSubclassOfClass:_decNumberClass]) {
                parsed = [NSDate dateWithTimeIntervalSince1970:((NSNumber *)date).doubleValue];
            } else if ([(NSString *)date rangeOfString:@"-"].location != NSNotFound) {
                parsed = [NSDateFormatter.pnjc_iso8601 dateFromString:(NSString *)date];
            } else {
                NSNumber *timestamp = [NSNumberFormatter.pnjc_number numberFromString:(NSString *)date];
                if (timestamp != nil) parsed = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
            }

            return parsed;
        };
    });

    return _dateDecodingStrategy;
}

- (NSError *)error {
    return self.decodingError;
}


#pragma mark - Initialization and Configuration

+ (void)load {
    _decMutableDictionaryClass = [NSMutableDictionary class];
    _decMutableStringClass = [NSMutableString class];
    _decMutableArrayClass = [NSMutableArray class];
    _decMutableDataClass = [NSMutableData class];
    _decMutableSetClass = [NSMutableSet class];
    _decDictionaryClass = [NSDictionary class];
    _decStringClass = [NSString class];
    _decNumberClass = [NSNumber class];
    _decArrayClass = [NSArray class];
    _decNullClass = [NSNull class];
    _decDataClass = [NSData class];
    _decDateClass = [NSDate class];
    _decSetClass = [NSSet class];
}

+ (instancetype)decoderForClass:(Class)aClass fromDictionary:(NSDictionary *)dictionary {
    return [self decoderForClass:aClass fromDictionary:dictionary withSerializer:nil];
}

+ (instancetype)decoderForClass:(Class)aClass
                 fromDictionary:(NSDictionary *)dictionary
                 withSerializer:(id<PNJSONSerializer>)serializer {
    return [[self alloc] initForReadingObjectOfClass:aClass
                                          fromObject:dictionary
                                      withSerializer:serializer
                                               error:nil];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"PNInterfaceNotAvailable"
                                   reason:@"+new or -init methods unavailable."
                                 userInfo:PNErrorUserInfo(nil, nil, @"Use proper -init* method.", nil)];

    return nil;
}

- (instancetype)initForReadingFromData:(NSData *)data {
    if ((self = [super init])) {
        NSError *error;
        _decodableValue = [self objectFromData:data withSerializer:nil mutable:NO error:&error];

        if (error) {
            _decodingError = error;
        } else if ([[_decodableValue class] isSubclassOfClass:_decDictionaryClass]) {
            NSMutableDictionary *keys = [NSMutableDictionary new];

            for (NSString *property in ((NSDictionary *)_decodableValue).allKeys) keys[property] = property;
            _codingKeys = keys;
        }
    }

    return self;
}

- (instancetype)initForReadingFromDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        if (![[dictionary class] isSubclassOfClass:_decDictionaryClass]) {
            _decodingError = [self decodingErrorWrongRootObjectClass:[dictionary class]];
        } else {
            NSMutableDictionary *keys = [NSMutableDictionary new];
            _decodableValue = dictionary;

            for (NSString *property in dictionary.allKeys) keys[property] = property;
            _codingKeys = keys;
        }
    }

    return self;
}

- (instancetype)initForReadingObjectOfClass:(Class)aClass
                                   fromData:(NSData *)data
                             withSerializer:(id<PNJSONSerializer>)serializer
                                      error:(NSError **)error {
    NSError *jsonError;
    id object = [self objectFromData:data withSerializer:serializer mutable:NO error:&jsonError];

    if ((self = [self initForReadingObjectOfClass:aClass
                                       fromObject:object
                                   withSerializer:serializer
                                            error:&jsonError])) {
        if (error) *error = jsonError;
    }

    return self;
}

- (instancetype)initForReadingObjectOfClass:(Class)aClass
                                 fromObject:(id)object
                             withSerializer:(nullable id<PNJSONSerializer>)serializer
                                      error:(NSError **)error {
    if ((self = [super init])) {
        NSError *initError = error ? *error : nil;
        _decodableValue = object;
        _instanceClass = aClass;

        if (!initError && !object) initError = [self decodingErrorMissingData];
        _decodingError = initError;

        if (!initError) {
            [PNJSONCodableObjects makeCodableClass:aClass];

            _optionalKeys = [PNJSONCodableObjects optionalKeysForClass:aClass];
            _codingKeys = [PNJSONCodableObjects codingKeysForClass:aClass];
            _serializer = serializer;
        } else if (error) {
            *error = initError;
        }
    }

    return self;
}


#pragma mark - Decode Top-Level Objects

+ (id)decodedObjectFromData:(NSData *)data error:(NSError **)error {
    return [[[self alloc] initForReadingObjectOfClass:nil
                                             fromData:data
                                       withSerializer:nil
                                                error:error] decodeObject];
}

+ (id)decodedObjectOfClass:(Class)aClass fromData:(NSData *)data error:(NSError **)error {
    return [self decodedObjectOfClass:aClass fromData:data withSerializer:nil additionalData:nil error:error];
}

+ (id)decodedObjectOfClass:(Class)aClass
                  fromData:(NSData *)data
            withSerializer:(id<PNJSONSerializer>)serializer
            additionalData:(NSDictionary *)additionalData
                     error:(NSError **)error {
    PNJSONDecoder *decoder = [[self alloc] initForReadingObjectOfClass:aClass
                                                              fromData:data
                                                        withSerializer:serializer
                                                                 error:error];
     decoder.additionalData = additionalData;

    id decodedObject = [decoder decodeObject];
    if (decoder.error && error) *error = decoder.error;

    return decodedObject;
}

+ (nullable id)decodedObjectOfClass:(Class)aClass fromDictionary:(NSDictionary *)dictionary withError:(NSError **)error {
    return [self decodedObjectOfClass:aClass fromDictionary:dictionary withAdditionalData:nil error:error];
}

+ (id)decodedObjectOfClass:(Class)aClass 
            fromDictionary:(NSDictionary *)dictionary
        withAdditionalData:(NSDictionary *)additionalData
                     error:(NSError **)error {
    PNJSONDecoder *decoder = [[self alloc] initForReadingObjectOfClass:aClass
                                                            fromObject:dictionary
                                                        withSerializer:nil
                                                                 error:error];
     decoder.additionalData = additionalData;

    id decodedObject = [decoder decodeObject];
    if (decoder.error && error) *error = decoder.error;

    return decodedObject;
}

+ (NSArray *)decodedObjectsOfClass:(Class)aClass fromArray:(NSArray *)array withError:(NSError **)error {
    return [self decodedObjectsOfClass:aClass fromArray:array withAdditionalData:nil error:error];
}

+ (NSArray *)decodedObjectsOfClass:(Class)aClass 
                         fromArray:(NSArray *)array
                withAdditionalData:(NSDictionary *)additionalData
                             error:(NSError **)error {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:array.count];
    NSError *decodingError;

    for (id object in array) {
        id decodedObject = [self decodedObjectOfClass:aClass 
                                       fromDictionary:object
                                   withAdditionalData:additionalData
                                                error:&decodingError];

        if (decodedObject && !decodingError) {
            [objects addObject:decodedObject];
        } else {
            objects = nil;
            break;
        }
    }

    if (decodingError && error) *error = decodingError;

    return objects;
}

- (id)decodeTopLevelObjectOfClass:(Class)aClass forKey:(NSString *)key error:(NSError **)error {
    id decodedObject = [self decodeObjectOfClass:aClass forKey:key];

    if (self.decodingError && error) {
        *error = self.decodingError;
        self.decodingError = nil;
    };

    return decodedObject;
}

- (id)decodeTopLevelObjectOfClasses:(NSArray<Class> *)classes forKey:(NSString *)key error:(NSError **)error {
    id decodedObject = [self decodeObjectOfClasses:classes forKey:key];

    if (self.decodingError && error) {
        *error = self.decodingError;
        self.decodingError = nil;
    }

    return decodedObject;
}

- (id)decodeTopLevelObjectForKey:(NSString *)key error:(NSError **)error {
    id decodedObject = [self decodeObjectForKey:key];

    if (self.decodingError && error) {
        *error = self.decodingError;
        self.decodingError = nil;
    }

    return decodedObject;
}


#pragma mark - Decoding General Data

- (id<PNDecoder>)nestedDecoderForKey:(NSString *)key {
    id value = [self objectForKey:key];
    PNJSONDecoder *decoder;
    NSError *error;

    if ([[value class] isSubclassOfClass:_decDictionaryClass]) {
        decoder = [[PNJSONDecoder alloc] initForReadingFromDictionary:value];
    } else if (!value && [self hasKey:key] ) {
        error = [self decodingErrorObjectOfType:@"PNJSONDecoder" forMissingKey:key];
    } else if (!value) {
        error = [self decodingErrorForMissingValueOfType:@"PNJSONDecoder" forKey:key];
    }

    if (error && ![self isOptionalKey:key]) self.decodingError = error;

    return decoder;
}

- (id)decodeObject {
    return !self.decodingError ? [self decodeObjectOfClass:self.instanceClass] : nil;
}

- (NSString *)decodeString {
    self.decodingError = [self decodingErrorInvalidOperation:@"-decodeString"];
    return nil;
}

- (NSNumber *)decodeNumber {
    self.decodingError = [self decodingErrorInvalidOperation:@"-decodeNumber"];
    return nil;
}

- (NSData *)decodeData {
    self.decodingError = [self decodingErrorInvalidOperation:@"-decodeData"];
    return nil;
}

- (NSDate *)decodeDate {
    self.decodingError = [self decodingErrorInvalidOperation:@"-decodeDate"];
    return nil;
}

- (id)decodeObjectForKey:(NSString *)key {
    id decodableObject = [self objectForKey:key];

    NSError *error;

    if (!decodableObject && ![self hasKey:key]) {
        error = [self decodingErrorObjectOfType:nil forMissingKey:key];
    } else if (!decodableObject) {
        error = [self decodingErrorForMissingValueOfType:@"object" forKey:key];
    }

    if (error && ![self isOptionalKey:key]) {
        self.decodingError = error;
        return nil;
    }

    if (!self.instanceClass) return decodableObject;
    BOOL isDynamic = NO;
    Class aClass = [PNJSONCodableObjects classOfProperty:key forClass:self.instanceClass custom:nil dynamic:&isDynamic];

    if (!aClass && isDynamic) {
        aClass = [PNJSONCodableObjects decodingClassOfProperty:key
                                                      forClass:self.instanceClass
                                           inDecodedDictionary:decodableObject];
    }

    return [self decodedObject:decodableObject ofClass:aClass withError:YES];
}

- (id)decodeObjectIfPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeObjectForKey:key];

    return decodedObject;
}

- (NSString *)decodeStringForKey:(NSString *)key {
    return [self decodeObjectOfClass:_decStringClass forKey:key];
}

- (NSString *)decodeStringIfPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeStringForKey:key];

    return decodedObject;
}

- (NSNumber *)decodeNumberForKey:(NSString *)key {
    return [self decodeObjectOfClass:_decNumberClass forKey:key];
}

- (NSNumber *)decodeNumberIfPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeNumberForKey:key];

    return decodedObject;
}

- (NSData *)decodeDataForKey:(NSString *)key {
    return [self decodeObjectOfClass:_decDataClass forKey:key];
}

- (NSData *)decodeDataIfPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeDataForKey:key];

    return decodedObject;
}

- (NSDate *)decodeDateForKey:(NSString *)key {
    return [self decodeObjectOfClass:_decDateClass forKey:key];
}

- (NSDate *)decodeDateIfPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeDateForKey:key];

    return decodedObject;
}

- (NSNull *)decodeNilForKey:(NSString *)key {
    return [self decodeObjectOfClass:_decNullClass forKey:key];
}

- (NSNull *)decodeNilIfPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeNilForKey:key];

    return decodedObject;
}

- (BOOL)decodeBoolForKey:(NSString *)key {
    id value = [self objectForKey:key];
    NSError *error;

    if (!value && ![self hasKey:key]) {
        error = [self decodingErrorObjectOfType:@"BOOL" forMissingKey:key];
    } else if (!value) {
        error = [self decodingErrorForMissingValueOfType:@"BOOL" forKey:key];
    } else if (![(id<NSObject>)value isKindOfClass:_decNumberClass]) {
        error = [self decodingErrorObjectOfType:@"BOOL"
                              forUnexpectedType:NSStringFromClass([value class])
                                            key:key];
    }

    if (error && ![self isOptionalKey:key]) self.decodingError = error;

    return self.decodingError == nil ? ((NSNumber *)value).boolValue : NO;
}

- (BOOL)decodeBoolIfPresentForKey:(NSString *)key {
    BOOL decodedObject = NO;
    if ([self hasKey:key]) decodedObject = [self decodeBoolForKey:key];

    return decodedObject;
}

- (id)decodeObjectOfClass:(Class)aClass {
    return [self decodedObject:self.decodableValue ofClass:aClass withError:YES];
}

- (id)decodeObjectOfClass:(Class)aClass forKey:(NSString *)key {
    id value = [self objectForKey:key];
    NSError *error;

    if (!value && ![self hasKey:key]) {
        error = [self decodingErrorObjectOfType:NSStringFromClass(aClass) forMissingKey:key];
    } else if (!value) {
        error = [self decodingErrorForMissingValueOfType:NSStringFromClass(aClass) forKey:key];
    }

    if (error && ![self isOptionalKey:key]) self.decodingError = error;

    return !error ? [self decodedObject:value ofClass:aClass withError:YES] : nil;
}

- (id)decodeObjectOfClass:(Class)aClass ifPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeObjectOfClass:aClass forKey:key];

    return decodedObject;
}

- (id)decodeObjectOfClasses:(NSArray<Class> *)classes {
    id decodedObject;

    for (Class aClass in classes) {
        decodedObject = [self decodedObject:self.decodableValue ofClass:aClass withError:NO];
        if (decodedObject) break;
    }

    if (!decodedObject) {
        self.decodingError = [self decodingErrorUnableDecodeValue:self.decodableValue
                                             asInstanceOfAnyClass:classes];
    }

    return decodedObject;
}

- (id)decodeObjectOfClasses:(NSArray<Class> *)classes forKey:(NSString *)key {
    id value = [self objectForKey:key];
    id decodedObject;
    NSError *error;

    if (value != nil) {
        for (Class aClass in classes) {
            decodedObject = [self decodedObject:value ofClass:aClass withError:NO];
            if (decodedObject) break;
        }

        if (!decodedObject) {
            error = [self decodingErrorUnableDecodeValue:self.decodableValue asInstanceOfAnyClass:classes];
        }
    } else if (!value && ![self hasKey:key]) {
        error = [self decodingErrorObjectOfType:classes.description forMissingKey:key];
    } else if (!value) {
        error = [self decodingErrorForMissingValueOfType:classes.description forKey:key];
    }

    if (error && ![self isOptionalKey:key]) self.decodingError = error;

    return decodedObject;
}

- (id)decodeObjectOfClasses:(NSArray<Class> *)classes ifPresentForKey:(NSString *)key {
    id decodedObject = nil;
    if ([self hasKey:key]) decodedObject = [self decodeObjectOfClasses:classes forKey:key];

    return decodedObject;
}


#pragma mark - Decoding

- (id)decodedObject:(id)object ofClass:(Class)aClass withError:(BOOL)generateError {
    if (!aClass) return object;

    id decodedObject;

    if ([aClass isSubclassOfClass:_decStringClass]) {
        BOOL mutableString = [aClass isSubclassOfClass:_decMutableStringClass];
        decodedObject = [self decodedAsMutableNSString:mutableString fromValue:object];
    } else if ([aClass isSubclassOfClass:_decNumberClass]) {
        decodedObject = [self decodedAsNSNumber:object];
    } else if ([aClass isSubclassOfClass:_decNullClass]) {
        decodedObject = [self decodedAsNSNull:object];
    } else if ([aClass isSubclassOfClass:_decDictionaryClass]) {
        BOOL mutableDictionary = [aClass isSubclassOfClass:_decMutableDictionaryClass];
        decodedObject = [self decodedAsMutableNSDictionary:mutableDictionary fromValue:object];
    } else if ([aClass isSubclassOfClass:_decArrayClass]) {
        BOOL mutableArray = [aClass isSubclassOfClass:_decMutableArrayClass];
        decodedObject = [self decodedAsMutableNSArray:mutableArray fromValue:object];
    } else if ([aClass isSubclassOfClass:_decSetClass]) {
        BOOL mutableSet = [aClass isSubclassOfClass:_decMutableSetClass];
        Class setClass = !mutableSet ? _decSetClass : _decMutableSetClass;
        decodedObject = [setClass setWithArray:[self decodedAsMutableNSArray:NO fromValue:object]];
    } else if ([aClass isSubclassOfClass:_decDataClass]) {
        BOOL mutableData = [aClass isSubclassOfClass:_decMutableDataClass];
        decodedObject = [self decodedAsMutableNSData:mutableData fromValue:object];
    } else if ([aClass isSubclassOfClass:_decDateClass]) {
        decodedObject = [self decodedAsNSDate:object];
    } else if (strncmp(class_getName(aClass), "NS", 2) != 0) {
        decodedObject = [self decodedCustomObject:object asInstanceOfClass:aClass];
    }

    if (!decodedObject && generateError && !self.decodingError) {
        self.decodingError = [self decodingErrorUnableDecodeValue:object asInstanceOfClass:aClass];
    }

    return decodedObject;
}

- (nullable id)decodedAsMutableNSString:(BOOL)mutable fromValue:(id)value {
    if (![[value class] isSubclassOfClass:_decStringClass]) return nil;
    return !mutable ? value : [value mutableCopy];
}

- (nullable NSNumber *)decodedAsNSNumber:(id)object {
    if ([[object class] isSubclassOfClass:_decNumberClass]) return object;
    if (![[object class] isSubclassOfClass:_decStringClass]) return nil;
    return [NSNumberFormatter.pnjc_number numberFromString:object];
}

- (nullable NSNull *)decodedAsNSNull:(id)object {
    if ([object isKindOfClass:_decNullClass]) return object;
    if (![[object class] isSubclassOfClass:_decStringClass]) return nil;
    return [object isEqual:@"null"] ? [NSNull null] : nil;
}

- (nullable id)decodedAsMutableNSData:(BOOL)mutable fromValue:(id)value {
    if (![[value class] isSubclassOfClass:_decStringClass]) return nil;
    return [self class].dataDecodingStrategy(value, mutable);
}

- (nullable NSDate *)decodedAsNSDate:(id)object {
    if (![object isKindOfClass:_decNumberClass] && ![object isKindOfClass:_decStringClass]) return nil;
    return [self class].dateDecodingStrategy(object);
}

- (nullable id)decodedAsMutableNSDictionary:(BOOL)mutable fromValue:(id)value {
    if (![[value class] isSubclassOfClass:_decDictionaryClass]) return nil;
    return !mutable ? value : [value mutableCopy];
}

- (nullable id)decodedAsMutableNSArray:(BOOL)mutable fromValue:(id)value {
    if (![[value class] isSubclassOfClass:_decArrayClass]) return nil;
    return !mutable ? value : [value mutableCopy];
}

- (id)decodedCustomObject:(id)value asInstanceOfClass:(Class)aClass {
    [PNJSONCodableObjects makeCodableClass:aClass];
    BOOL hasCustomDecoding = [PNJSONCodableObjects hasCustomDecodingForClass:aClass];
    __block id decodedObject = nil;

    if (!hasCustomDecoding && ![[value class] isSubclassOfClass:_decDictionaryClass]) {
        self.decodingError = [self decodingErrorObjectOfType:@"NSDictionary"
                                           forUnexpectedType:NSStringFromClass([value class])
                                                         key:nil];
        return nil;
    }

    if (hasCustomDecoding) {
        NSError *decodeError;
        PNJSONDecoder *decoder = [[PNJSONDecoder alloc] initForReadingObjectOfClass:aClass
                                                                         fromObject:value
                                                                     withSerializer:self.serializer
                                                                              error:&decodeError];
        decodedObject = [(id<PNCodable>)[aClass alloc] initObjectWithCoder:decoder];
    } else {
        NSDictionary *dictionaryValue = (NSDictionary *)value;
        NSDictionary *codingKeys = self.codingKeys;
        NSArray *optionalKeys = self.optionalKeys;
        __block id instance = [aClass new];

        if (aClass != self.instanceClass) {
            optionalKeys = [PNJSONCodableObjects optionalKeysForClass:aClass];
            codingKeys = [PNJSONCodableObjects codingKeysForClass:aClass];
        }

        // Early exit in case if passed class can't be instantiated.
        if (!instance) return nil;

        [codingKeys enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *mName, BOOL *stop) {
            BOOL isDynamic = NO;
            BOOL customClass;
            Class class = [PNJSONCodableObjects classOfProperty:name
                                                       forClass:aClass
                                                         custom:&customClass
                                                        dynamic:&isDynamic];
            if (!class && isDynamic) {
                class = [PNJSONCodableObjects decodingClassOfProperty:mName
                                                             forClass:aClass
                                                  inDecodedDictionary:dictionaryValue];
            }

            BOOL optional = [optionalKeys containsObject:name];
            id encodedObject = dictionaryValue[mName];

            if (encodedObject) {
                id property;

                if (customClass) {
                    property = [self decodedCustomObject:encodedObject asInstanceOfClass:class];
                } else {
                    property = [self decodedObject:encodedObject ofClass:class withError:YES];
                }

                if (property) {
                    [instance setValue:property forKey:name];
                } else if (self.decodingError) {
                    instance = nil;
                    *stop = YES;
                }
            } else if (!optional) {
                NSString *className = class ? NSStringFromClass(class) : @"unknown";
                self.decodingError = [self decodingErrorObjectOfType:className forMissingKey:name];
                instance = nil;
                *stop = YES;
            }
        }];

        decodedObject = instance;
    }

    return decodedObject;
}


#pragma mark - Helpers

- (NSArray<NSString *> *)keys {
    if (![self.decodableValue isKindOfClass:_decDictionaryClass]) return nil;
    return ((NSDictionary *)self.decodableValue).allKeys;
}

- (BOOL)containsValueForKey:(NSString *)key {
    return [self hasKey:key] && [self objectForKey:key] != nil;
}

- (id<NSObject>)objectForKey:(NSString *)key {
    NSString *mappedName = self.codingKeys[key];
    return mappedName ? self.decodableValue[mappedName] : nil;
}

- (BOOL)hasKey:(NSString *)key {
    return self.codingKeys[key] != nil;
}

- (BOOL)isOptionalKey:(NSString *)key {
    return [self.optionalKeys containsObject:key];
}

- (id)objectFromData:(NSData *)jsonData
      withSerializer:(id<PNJSONSerializer>)serializer
             mutable:(BOOL)mutableCollections
               error:(PNError **)error {
    if (!jsonData || ![[jsonData class] isSubclassOfClass:_decDataClass] || jsonData.length == 0) {
        *error = [self decodingErrorEmptyData];
    }

    // Early exit in case if data object is missing or empty.
    if (error && *error) return nil;

    PNJSONReadingOptions options = mutableCollections ? PNJSONReadingMutableCollections : 0;
    id data = serializer ? [serializer JSONObjectWithData:jsonData options:options error:error]
                         : [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:(NSJSONReadingOptions)options
                                                             error:error];

    if (!data && error) {
        NSError *jsonError = *error;
        *error = [self decodingErrorMalformedDataWithError:jsonError];
    }

    return data;
}


#pragma mark - Errors

- (PNError *)decodingErrorEmptyData {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode an object from empty data.",
        @"'nil' or empty NSData instance has been passed to the decoder.",
        @"Ensure that proper value passed to the decoder.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorEmptyData
                           userInfo:userInfo];
}

- (PNError *)decodingErrorMalformedDataWithError:(NSError *)error {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode object from malformed data.",
        @"Malformed JSON data has been passed to the decoder.",
        @"Ensure that the passed data object contains a proper and complete JSON object. The root object "
         "should be an instance of NSDictionary or NSArray.",
        error
    );
    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorMalformedJSONData
                           userInfo:userInfo];
}

- (PNError *)decodingErrorMissingData {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode 'nil' object.",
        @"'nil' object has been passed to the decoder.",
        @"Ensure that an object properly deserialized before passing it.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorMissingData
                                userInfo:userInfo];
}

- (PNError *)decodingErrorWrongRootObjectClass:(Class)aClass {
    NSString *clsName = NSStringFromClass(aClass);
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable initialize decoder.",
        PNStringFormat(@"Decoder should be initialized with 'NSDictionary' instance, but got '%@' instead.",
                       clsName),
        @"Ensure that decoder initialized with proper data type.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorTypeMismatch
                           userInfo:userInfo];
}

- (PNError *)decodingErrorInvalidOperation:(NSString *)operation {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode an object.",
        PNStringFormat(@"'%@' can't be used to decode object.", operation),
        @"Requested operation maybe not be supported in current context.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorInvalid
                           userInfo:userInfo];
}

- (NSError *)decodingErrorUnableDecodeValue:(id)value asInstanceOfClass:(Class)aClass {
    NSString *clsName = aClass ? NSStringFromClass(aClass) : nil;
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode an object from JSON.",
        PNStringFormat(@"Unable to decode an object%@: %@",
                       clsName ? PNStringFormat(@" of '%@' class", clsName) : @"", value),
        @"Check whether target class properly implemented PNCodable protocol or whether data in source "
         "object correspond to object structure.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorTypeMismatch
                           userInfo:userInfo];
}

- (PNError *)decodingErrorUnableDecodeValue:(id)value asInstanceOfAnyClass:(NSArray<Class> *)classes {
    NSMutableArray *classNames = [NSMutableArray new];
    for (Class aClass in classes) [classNames addObject:NSStringFromClass(aClass)];

    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode an object from JSON.",
        PNStringFormat(@"Unable to decode an object as an instance any of %@: %@",
                       [classNames componentsJoinedByString:@", "], value),
        @"Check suitable classes and / or encoded data passed to the decoder.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorTypeMismatch
                           userInfo:userInfo];
}

- (PNError *)decodingErrorObjectOfType:(NSString *)objectType
                     forUnexpectedType:(NSString *)unexpectedType
                                   key:(NSString *)key {
    NSDictionary *userInfo = PNErrorUserInfo(
        @"Unable to decode an object from JSON.",
        PNStringFormat(@"Unable to decode and object associated with '%@' as %@ (got '%@' instead)",
                       key ? key : @"some key", objectType, unexpectedType),
        @"Make sure to use proper methods to decode object associated with specified key.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorTypeMismatch
                           userInfo:userInfo];
}

- (PNError *)decodingErrorForMissingValueOfType:(NSString *)objectType forKey:(NSString *)key {
    NSDictionary *userInfo = PNErrorUserInfo(
        PNStringFormat(@"Unable decode %@ from JSON.", objectType),
        PNStringFormat(@"%@ can't be decoded from 'nil' associated with '%@' key.", objectType, key),
        @"Ensure that the value associated with the specified key is not specified as optional.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorValueNotFound
                           userInfo:userInfo];
}

- (PNError *)decodingErrorObjectOfType:(NSString *)objectType forMissingKey:(NSString *)key {
    NSDictionary *userInfo = PNErrorUserInfo(
        PNStringFormat(@"Unable decode %@ from JSON.", objectType ? objectType : @"value"),
        PNStringFormat(@"Encoded object doesn't have %@ associated with '%@' key.",
                       objectType ? objectType : @"any value", key),
        @"Check name of key which used to decode value from JSON.",
        nil
    );

    return [PNError errorWithDomain:PNJSONDecoderErrorDomain
                               code:PNJSONDecodingErrorKeyNotFound
                           userInfo:userInfo];
}

#pragma mark -


@end
