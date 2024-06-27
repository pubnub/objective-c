#import "PNJSONCodableObjects.h"
#import <objc/runtime.h>
#import <PubNub/PNFunctions.h>
#import <PubNub/PNCodable.h>
#import <PubNub/PNLock.h>


#pragma mark Static

/// Key, which is used to associate list of JSON-friendly properties for class.
static char kPNJSONCodableObjectFoundationProperties;

/// Key, which is used to associate list of custom properties for class.
static char kPNJSONCodableObjectCustomProperties;

/// Key, which is used to associate keys with dynamic type for class.
static char kPNJSONCodableObjectDynamicTypeKeys;

/// Key, which is used to associate optional keys for class.
static char kPNJSONCodableObjectOptionalKeys;

/// Key, which is used to associate coding keys for class.
static char kPNJSONCodableObjectCodingKeys;

/// Key, which is used to associate list of known properties for class.
static char kPNJSONCodableProperties;

/// Key, which is used to associate results of custom encoding check for class.
static char kPNJSONCodableHasCustomEncoding;

/// Key, which is used to associate results of custom decoding check for class.
static char kPNJSONCodableHasCustomDecoding;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNJSONCodableObjects ()


#pragma mark - Properties

/// Shared codable objects manager.
@property(class, strong, nullable, nonatomic, readonly) PNJSONCodableObjects *sharedManager;

/// List of `NSObject` own properties, so they will be excluded
@property(strong, nonatomic) NSSet<NSString *> *NSObjectProperties;

/// List of `NSObject` own methods, so they will be excluded
@property(strong, nonatomic) NSSet<NSString *> *NSObjectMethods;

/// List of classes which has been modified.
@property(strong, nonatomic) NSMutableSet<Class> *classes;

/// Resources access lock.
@property(strong, nonatomic) PNLock *lock;


#pragma mark - Helpers

/// Index instance properties list.
///
/// - Parameter aClass: Class for which list of properties should be created.
/// - Returns: List of `aClass` instance properties.
- (NSSet<NSString *> *)propertyListForClass:(Class)aClass;

/// Index class instance methods.
///
/// This method allow to retrieve instance methods of passed class. If meta-class is passed, then static
/// methods will be indexed.
///
/// - Parameter aClass: Class for which list of selectors (stringified) should be created.
/// - Returns: List of `aClass` instance methods.
- (NSSet<NSString *> *)methodsListForClass:(Class)aClass;

/// Identify type of properties.
///
/// Run through known `aClass` instance properties and separate them on properties which hold foundation and
/// custom objects.
/// Identifier properties will be attached to an `aClass` as associated objects and used later for coding.
///
/// - Parameters:
///   - propertyList: List of `aClass` instance properties.
///   - aClass: Class for which properties should be identified.
- (void)identifyAndStoreProperties:(NSSet<NSString *> *)propertyList forClass:(Class)aClass;

/// Ensure that `aClass` adopt ``PNCodable`` protocol.
///
/// Missing implementations from ``PNCodable`` protocol will be stubbed with default implementation.
///
/// - Parameters:
///   - aClass: Class which should conform to ``PNCodable`` protocol.
///   - propertyList: List of `aClass` instance properties.
- (void)ensureCodableClass:(Class)aClass withPropertyList:(NSSet<NSString *> *)propertyList;

/// Clean up any data which has been associated with `aClass`.
///
/// - Parameter aClass: Class for which should be removed associated objects.
- (void)resetInitialStateForClass:(Class)aClass;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNJSONCodableObjects


#pragma mark - Properties

+ (PNJSONCodableObjects *)sharedManager {
    static PNJSONCodableObjects *_sharedManager;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [PNJSONCodableObjects new];
    });

    return _sharedManager;
}


#pragma mark - Initialization and configuration

- (instancetype)init {
    if ((self = [super init])) {
        _NSObjectProperties = [self propertyListForClass:[NSObject class]];
        _NSObjectMethods = [self methodsListForClass:[NSObject class]];
        _classes = [NSMutableSet new];

        _lock = [PNLock lockWithIsolationQueueName:@"objects" subsystemQueueIdentifier:@"com.pubnub.serializer"];
    }

    return self;
}


#pragma mark - Coding / decoding

+ (void)makeCodableClass:(Class)aClass {
    PNJSONCodableObjects *manager = self.sharedManager;

    [manager.lock syncWriteAccessWithBlock:^{
        // Early exit, if class already codable or from Foundation.
        if ([manager.classes containsObject:aClass] || strncmp(class_getName(aClass), "NS", 2) == 0) return;

        [manager.classes addObject:aClass];
        NSSet<NSString *> *propertyList = [manager propertyListForClass:aClass];

        [manager identifyAndStoreProperties:propertyList forClass:aClass];
        [manager ensureCodableClass:aClass withPropertyList:propertyList];
    }];
}

+ (void)clearAllClasses {
    PNJSONCodableObjects *manager = self.sharedManager;

    [manager.lock syncWriteAccessWithBlock:^{
        for (Class aClass in manager.classes) [manager resetInitialStateForClass:aClass];
        [manager.classes removeAllObjects];
    }];
}


#pragma mark - Helpers

+ (BOOL)hasCustomEncodingForClass:(Class)aClass {
    return ((NSNumber *)objc_getAssociatedObject(aClass, &kPNJSONCodableHasCustomEncoding)).boolValue;
}

+ (BOOL)hasCustomDecodingForClass:(Class)aClass {
    return ((NSNumber *)objc_getAssociatedObject(aClass, &kPNJSONCodableHasCustomDecoding)).boolValue;
}

+ (Class)classOfProperty:(NSString *)propertyName forClass:(Class)aClass custom:(BOOL *)customClass dynamic:(BOOL *)dynamicClass; {
    if (!aClass) return nil;
    if (customClass) *customClass = NO;

    if ([[self dynamicTypeKeysForClass:aClass] containsObject:propertyName]) {
        if (dynamicClass) *dynamicClass = YES;
        return nil;
    }

    Class sClass = objc_getAssociatedObject(aClass, &kPNJSONCodableObjectFoundationProperties)[propertyName];

    if (!sClass) {
        sClass = objc_getAssociatedObject(aClass, &kPNJSONCodableObjectCustomProperties)[propertyName];
        if (customClass) *customClass = sClass != nil;
    }

    return sClass;
}

+ (nullable Class)decodingClassOfProperty:(NSString *)propertyName 
                                 forClass:(Class)aClass
                      inDecodedDictionary:(NSDictionary *)decodedDictionary{
    return [(Class<PNCodable>)aClass decodingClassForProperty:propertyName inDecodedDictionary:decodedDictionary];
}

+ (NSSet<NSString *> *)propertyListForClass:(Class)aClass {
    return objc_getAssociatedObject(aClass, &kPNJSONCodableProperties);
}

+ (NSDictionary<NSString *,NSString *> *)codingKeysForClass:(Class)aClass {
    return objc_getAssociatedObject(aClass, &kPNJSONCodableObjectCodingKeys);
}

+ (NSArray<NSString *> *)dynamicTypeKeysForClass:(Class)aClass {
    return objc_getAssociatedObject(aClass, &kPNJSONCodableObjectDynamicTypeKeys);
}

+ (NSArray<NSString *> *)optionalKeysForClass:(Class)aClass {
    return objc_getAssociatedObject(aClass, &kPNJSONCodableObjectOptionalKeys);
}

- (NSSet<NSString *> *)propertyListForClass:(Class)aClass {
    BOOL isNSObjectClass = aClass == [NSObject class];
    NSMutableSet *properties = [NSMutableSet new];
    NSArray<NSString *> *ignoredKeys;
    unsigned int count;


    if ([aClass respondsToSelector:@selector(ignoredKeys)]) {
        ignoredKeys = [(Class<PNCodable>)aClass ignoredKeys];
    } else ignoredKeys = @[];

    objc_property_t *propertyList = class_copyPropertyList(aClass, &count);

    for (int i = 0; i < count; i++) {
        const char *cName = property_getName(propertyList[i]);
        NSString *propertyName = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];

        if (!isNSObjectClass && [self.NSObjectProperties containsObject:propertyName]) continue;
        [properties addObject:propertyName];
    }

    free(propertyList);

    if (!isNSObjectClass && strncmp(class_getName([aClass superclass]), "NS", 2) != 0) {
        [properties unionSet:[self propertyListForClass:[aClass superclass]]];
    }

    if (ignoredKeys.count > 0 && properties.count > 0) {
        [properties minusSet:[NSSet setWithArray:ignoredKeys]];
    }

    return properties;
}

- (NSSet<NSString *> *)methodsListForClass:(Class)aClass {
    BOOL isNSObjectClass = aClass == [NSObject class];
    NSMutableSet *methods = [NSMutableSet new];
    unsigned int count;

    Method *methodsList = class_copyMethodList(aClass, &count);

    for (int i = 0; i < count; i++) {
        NSString *methodName = NSStringFromSelector(method_getName(methodsList[i]));

        if (!isNSObjectClass && [self.NSObjectMethods containsObject:methodName]) continue;
        [methods addObject:methodName];
    }

    free(methodsList);

    // Gather static methods for NSObject.
    if (isNSObjectClass) {
        methodsList = class_copyMethodList(objc_getMetaClass(class_getName(aClass)), &count);

        for (int i = 0; i < count; i++) {
            [methods addObject:NSStringFromSelector(method_getName(methodsList[i]))];
        }

        free(methodsList);
    }

    if (aClass != [NSObject class] && strncmp(class_getName([aClass superclass]), "NS", 2) != 0) {
        Class superClass = [aClass superclass];
        NSSet<NSString *> *superMethodsList = [self methodsListForClass:superClass];
        [methods unionSet:superMethodsList];
    }

    return methods;
}

- (void)identifyAndStoreProperties:(NSSet<NSString *> *)propertyList forClass:(Class)aClass {
    NSMutableDictionary<NSString *, Class> *foundation = [NSMutableDictionary new];
    NSMutableDictionary<NSString *, Class> *custom = [NSMutableDictionary new];

    for (NSString *name in propertyList) {
        objc_property_t property = class_getProperty(aClass, [name cStringUsingEncoding:NSUTF8StringEncoding]);
        char *type = property_copyAttributeValue(property, "T");
        unsigned long typeLength = strlen(type);
        BOOL isFoundationObject = YES;
        char *className = NULL;
        Class objectClass;

        if (type[0] == '@' && typeLength > 3) {
            className = strndup(type + 2, typeLength - 3);
            isFoundationObject = strncmp(className, "NS", 2) == 0;
            objectClass = objc_lookUpClass(className);
            free((void *)className);
        }

        free(type);

        if (!objectClass) continue;

        if (!isFoundationObject) {
            custom[name] = objectClass;
        } else {
            foundation[name] = objectClass;
        }
    }
    objc_setAssociatedObject(
                             aClass,
                             &kPNJSONCodableObjectFoundationProperties,
                             foundation,
                             OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectCustomProperties, custom, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableProperties, propertyList, OBJC_ASSOCIATION_RETAIN);
}

- (void)ensureCodableClass:(Class)aClass withPropertyList:(NSSet<NSString *> *)propertyList {
    Class metaClass = objc_getMetaClass(class_getName(aClass));
    NSSet<NSString *> *methodsList = [self methodsListForClass:aClass];
    BOOL encoding = [methodsList containsObject:NSStringFromSelector(@selector(encodeObjectWithCoder:))];
    BOOL decoding = [methodsList containsObject:NSStringFromSelector(@selector(initObjectWithCoder:))];
    methodsList = [self methodsListForClass:metaClass];
    BOOL isNSObjectClass = aClass == [NSObject class];
    NSDictionary<NSString *, NSString *> *codingKeys;
    NSArray<NSString *> *dynamicTypeKeys;
    NSArray<NSString *> *optionalKeys;

    if ([methodsList containsObject:NSStringFromSelector(@selector(codingKeys))]) {
        codingKeys = [(Class<PNCodable>)aClass codingKeys];
    } else {
        NSMutableDictionary *propertyMap = [NSMutableDictionary new];

        for (NSString *propertyName in propertyList) propertyMap[propertyName] = propertyName;

        codingKeys = propertyMap;
    }

    if ([methodsList containsObject:NSStringFromSelector(@selector(optionalKeys))]) {
        optionalKeys = [(Class<PNCodable>)aClass optionalKeys];
    } else {
        optionalKeys = @[];
    }

    if ([methodsList containsObject:NSStringFromSelector(@selector(dynamicTypeKeys))]) {
        dynamicTypeKeys = [(Class<PNCodable>)aClass dynamicTypeKeys];
    } else {
        dynamicTypeKeys = @[];
    }

    if (!isNSObjectClass && strncmp(class_getName([aClass superclass]), "NS", 2) != 0) {
        Class superClass = [aClass superclass];
        NSSet<NSString *> *superPropertyList = [self propertyListForClass:superClass];
        
        // Process super class keys information.
        [self ensureCodableClass:superClass withPropertyList:superPropertyList];
        NSDictionary<NSString *,NSString *> *superCodingKeys = [[self class] codingKeysForClass:superClass];
        NSArray<NSString *> *superDynamicTypeKeys = [[self class] dynamicTypeKeysForClass:superClass];
        NSArray<NSString *> *superOptionalKeys = [[self class] optionalKeysForClass:superClass];

        if (superCodingKeys.count) {
            NSMutableDictionary *updatedCodingKeys = [codingKeys mutableCopy];
            [updatedCodingKeys addEntriesFromDictionary:superCodingKeys];
            codingKeys = updatedCodingKeys;
        }

        if (superOptionalKeys.count) {
            NSMutableSet *updatedOptionalKeys = [NSMutableSet setWithArray:optionalKeys];
            [updatedOptionalKeys addObjectsFromArray:superOptionalKeys];
            optionalKeys = updatedOptionalKeys.allObjects;
        }

        if (superDynamicTypeKeys.count) {
            NSMutableSet *updatedDynamicTypeKeys = [NSMutableSet setWithArray:dynamicTypeKeys];
            [updatedDynamicTypeKeys addObjectsFromArray:superDynamicTypeKeys];
            dynamicTypeKeys = updatedDynamicTypeKeys.allObjects;
        }
    }

    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectDynamicTypeKeys, dynamicTypeKeys, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectOptionalKeys, optionalKeys, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableHasCustomEncoding, @(encoding), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableHasCustomDecoding, @(decoding), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectCodingKeys, codingKeys, OBJC_ASSOCIATION_RETAIN);
}

- (void)resetInitialStateForClass:(Class)aClass {
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectFoundationProperties, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectCustomProperties, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectDynamicTypeKeys, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectOptionalKeys, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableHasCustomEncoding, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableHasCustomDecoding, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableObjectCodingKeys, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(aClass, &kPNJSONCodableProperties, nil, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark -


@end
