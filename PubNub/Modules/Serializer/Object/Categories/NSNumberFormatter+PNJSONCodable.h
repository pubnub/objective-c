#import <Foundation/Foundation.h>


#pragma mark Category interface declaration

/// `NSDateFormatter` support for codable instance support.
///
/// Extension intended to be used with ``PNJSONDecoder`` to restore instance from JSON data.
@interface NSNumberFormatter (PNJSONCodable)


#pragma mark - Properties

/// Pre-configured number formatter compatible with JSON.
@property(class, strong, nonatomic, readonly) NSNumberFormatter *pnjc_number;

#pragma mark -


@end
