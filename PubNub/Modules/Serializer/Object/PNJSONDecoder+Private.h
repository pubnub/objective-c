#import <PubNub/PNJSONDecoder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// JSON deserializer private extension.
@interface PNJSONDecoder (Private)


#pragma mark - Properties

/// Additional information which can be used by `aClass` custom initializer.
@property(strong, nullable, nonatomic) NSDictionary *additionalData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
