#import "PNTimeData.h"
#import "PNCodable.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Fetch time request response data private extension.
@interface PNTimeData () <PNCodable>


#pragma mark - Properties

/// High-precision **PubNub** time token.
@property(strong, nonatomic) NSNumber *timetoken;


#pragma mark - Initialization and Configuration

/// Initialize time request response object.
///
/// - Parameter timetoken: High-precision **PubNub** time token.
/// - Returns: Initialized time data object.
- (instancetype)initWithTimetoken:(NSNumber *)timetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNTimeData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"timetoken"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    id payload = [coder decodeObjectOfClass:[NSArray class]];
    NSNumber *timeToken = @(-1);
    
    if ([payload isKindOfClass:[NSArray class]] && ((NSArray *)payload).count == 1) timeToken = ((NSArray *)payload)[0];
    if ([timeToken isEqual:@(-1)]) return nil;

    return [self initWithTimetoken:timeToken];
}

- (instancetype)initWithTimetoken:(NSNumber *)timetoken {
    if ((self = [super init])) _timetoken = timetoken;
    return self;
}

#pragma mark -


@end
