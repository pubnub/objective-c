#import "PNMessageActionsFetchData.h"
#import <PubNub/PNJSONDecoder.h>
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Fetch message actions request response data private extension.
@interface PNMessageActionsFetchData () <PNCodable>


#pragma mark - Properties

/// List of fetched `messages actions`.
@property(strong, nonatomic) NSArray<PNMessageAction *> *actions;


#pragma mark - Initialization and Configuration

/// Initialize actions data object
///
/// - Parameter actions: List of message actions which has been fetched for specific message.
/// - Returns: Initialized actions data object.
- (instancetype)initWithActions:(NSArray<PNMessageAction *> *)actions;

#pragma mark -


@end


NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMessageActionsFetchData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"actions": @"data"
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"start", @"end"];
}

- (NSNumber *)start {
    return self.actions.count > 0 ? self.actions.firstObject.actionTimetoken : @0;
}

- (NSNumber *)end {
    return self.actions.count > 0 ? self.actions.lastObject.actionTimetoken : @0;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithActions:(NSArray<PNMessageAction *> *)actions {
    if ((self = [super init])) _actions = actions;
    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSArray<PNMessageAction *> *actions = [PNJSONDecoder decodedObjectsOfClass:[PNMessageAction class]
                                                                     fromArray:[coder decodeObjectForKey:@"actions"]
                                                                     withError:nil];

    return actions ? [self initWithActions:actions] : nil;
}

#pragma mark -


@end
