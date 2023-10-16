#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Category interface declaration

/// `NSArray` extension which provides `map` functionality.
@interface NSArray<Type> (PNMap)


#pragma mark - Mapping

/// Map each array entry to a different type.
///
/// Iterate through the list of elements and call `block` for each entry to apply the transformation.
///
/// - Parameter block: GCD block, which passes `object` and its index for mapping and uses the returned value as an
/// entry in an array.
/// - Returns: New `NSArray` instance with entries created by `block` call.
- (NSArray *)pn_mapWithBlock:(nullable id (^)(Type object, NSUInteger index))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
