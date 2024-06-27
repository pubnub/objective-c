#import "PNJSONCoder.h"
#import "PNFunctions.h"
#import "PNJSONCodableObjects.h"
#import "PNJSONEncoder.h"
#import "PNJSONDecoder.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNJSONCoder ()


#pragma mark - Properties

/// Configured foundation object to JSON data serializer.
@property(strong, nonatomic) id<PNJSONSerializer> serializer;


#pragma mark - Initialization and configuration

/// Initialize objects `coder`.
///
/// - Parameter serializer: Custom JSON serializer which conform to ``PNJSONSerializer`` protocol and can be
/// used to translate serialized object to JSON data .
/// - Returns: Initialized `coder` instance for data processing.
- (instancetype)initWithJSONSerializer:(id<PNJSONSerializer>)serializer NS_DESIGNATED_INITIALIZER;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNJSONCoder


#pragma mark - Properties

- (id)jsonSerializer {
    return self.serializer;
}


#pragma mark - Initialization and configuration

+ (instancetype)coderWithJSONSerializer:(id)serializer {
    return [[self alloc] initWithJSONSerializer:serializer];
}

- (instancetype)init {

    @throw [NSException exceptionWithName:@"PNInterfaceNotAvailable"
                                   reason:@"+new or -init methods unavailable."
                                 userInfo:PNErrorUserInfo(nil, nil, @"Use provided builder constructor", nil)];

    return nil;
}

- (instancetype)initWithJSONSerializer:(id)serializer {
    if ((self = [super init])) _serializer = serializer;
    return self;
}


#pragma mark - Data serialization

- (id)dataOfClass:(Class)cls fromObject:(id<NSObject>)object withError:(NSError **)error {
    PNJSONEncoder *encoder = [[PNJSONEncoder alloc] initWithJSONSerializer:self.serializer];
    id data;

    [encoder encodeObject:object];
    [encoder finishEncoding];

    if (encoder.error && error) {
        *error = encoder.error;
    } else if (!encoder.error) {
        data = cls == [NSString class] ? encoder.encodedObjectString : encoder.encodedObjectData;
    }

    return data;
}

- (id)objectOfClass:(Class)aClass fromData:(id)data withError:(NSError **)error {
    return [self objectOfClass:aClass fromData:data withAdditional:nil error:error];
}

- (id)objectOfClass:(Class)aClass 
           fromData:(id)data
     withAdditional:(NSDictionary *)additionalData
              error:(NSError **)error {
    id decodedObject;

    // PNJSONDecoder requires 'data' to be instance of NSData.
    if ([[(id<NSObject>)data class] isSubclassOfClass:[NSString class]]) {
        data = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
    } else if([[(id<NSObject>)data class] isSubclassOfClass:[NSDictionary class]]) {
        return [PNJSONDecoder decodedObjectOfClass:aClass
                                    fromDictionary:data
                                withAdditionalData:additionalData
                                             error:error];
    }

    decodedObject = [PNJSONDecoder decodedObjectOfClass:aClass
                                               fromData:data
                                         withSerializer:self.serializer
                                         additionalData:additionalData
                                                  error:error];

    return decodedObject;
}


#pragma mark - Helpers

+ (void)cleanUpResources {
    [PNJSONCodableObjects clearAllClasses];
}

#pragma mark -


@end
