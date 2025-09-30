#import "PNPublishData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Data publish request response private extension.
@interface PNPublishData () <PNCodable>


#pragma mark - Properties

/// High-precision **PubNub** time token of published data.
@property(strong, nonatomic) NSNumber *timetoken;


#pragma mark - Initialization and Configuration

/// Initialize publish request response object.
///
/// - Parameter timetoken: High-precision **PubNub** time token of published data.
/// - Returns: Initialized publish data object.
- (instancetype)initWithTimetoken:(NSNumber *)timetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPublishData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"timetoken"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithTimetoken:(NSNumber *)timetoken {
    if ((self = [super init])) _timetoken = timetoken;
    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    id payload = [coder decodeObjectOfClass:[NSArray class]];
    NSNumber *timeToken = @(-1);
    
    if ([payload isKindOfClass:[NSArray class]]) {
        NSArray *array = payload;

        if(array.count == 3 && [array[0] isEqual:@1] && [array[2] isKindOfClass:[NSString class]]) {
            const char *token = [array[2] cStringUsingEncoding:NSUTF8StringEncoding];
            timeToken = @(strtoull(token, NULL, 0));
        }
    }

    if ([timeToken isEqual:@(-1)]) return nil;
    
    return [self initWithTimetoken:timeToken];
}

#pragma mark -


@end
