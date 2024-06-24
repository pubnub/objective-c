#import <Foundation/Foundation.h>


#pragma mark Category interface declaration

/// `NSDateFormatter` support for codable instance support.
///
/// Extension intended to be used with ``PNJSONEncoder`` / ``PNJSONDecoder`` to serialize / restore instance
/// to / from JSON data.
@interface NSDateFormatter (PNJSONCodable)


#pragma mark - Properties

/// Pre-configured ISO8601 date formatter.
@property(class, strong, nonatomic, readonly) NSDateFormatter *pnjc_iso8601;

#pragma mark -


@end
