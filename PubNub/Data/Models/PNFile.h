#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Shared file` data object.
@interface PNFile : NSObject


#pragma mark - Properties

/// Date when file has been uploaded.
///
/// > Note: This information is set only when file retrieved from history.
@property(strong, nullable, nonatomic, readonly) NSDate *created;

/// URL which can be used to download file.
@property(strong, nonatomic, readonly) NSURL *downloadURL;

/// Unique uploaded file identifier.
@property(copy, nonatomic, readonly) NSString *identifier;

/// Uploaded file size.
///
/// > Note: This information is set only when file retrieved from history.
@property(assign, nonatomic, readonly) NSUInteger size;

/// Name with which file has been uploaded.
@property(copy, nonatomic, readonly) NSString *name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
