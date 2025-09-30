#import "PNPagedAppContextData+Private.h"
#import "PNJSONDecoder.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Multipage App Context` request response private extensino.
@interface PNPagedAppContextData () <PNCodable>


#pragma mark - Properties

/// List of the fetched `App Context` objects.
@property(strong, nonatomic) NSArray<PNBaseAppContextObject *> *objects;

/// Cursor bookmark for fetching the next page.
@property(strong, nullable, nonatomic) NSString *next;

/// Cursor bookmark for fetching the previous page.
@property(strong, nullable, nonatomic) NSString *prev;

/// Total number of the `App Context` objects.
@property(assign, nonatomic) NSUInteger totalCount;


#pragma mark - Initialization and Configuration

/// Initialize multipage `App Context` response object.
///
/// - Parameter objects: List of the `App Context` objects.
/// - Returns: Initialized multipage `App Context` response object.
- (instancetype)initWithObjects:(NSArray<PNBaseAppContextObject *> *)objects;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation PNPagedAppContextData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"prev", @"next"];
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"objects"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithObjects:(NSArray<PNBaseAppContextObject *> *)objects {
    if ((self = [super init])) _objects = objects;
    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *payload = [coder decodeObjectOfClass:[NSDictionary class]];

    if (![payload isKindOfClass:[NSDictionary class]] || !payload[@"data"]) return nil;
    if (![payload[@"data"] isKindOfClass:[NSArray class]]) return nil;

    NSError *error;
    NSArray *objects = [PNJSONDecoder decodedObjectsOfClass:[self class].appContextObjectClass
                                                  fromArray:payload[@"data"]
                                                  withError:&error];
    if (error) return nil;

    PNPagedAppContextData *data = [self initWithObjects:objects];
    data.totalCount = ((NSNumber *)payload[@"totalCount"]).unsignedIntegerValue;
    data.prev = payload[@"prev"];
    data.next = payload[@"next"];

    return data;
}

#pragma mark -


@end
