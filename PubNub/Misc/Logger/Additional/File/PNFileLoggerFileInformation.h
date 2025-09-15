#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `File`-based logger log file representation model.
@interface PNFileLoggerFileInformation : NSObject


#pragma mark - Properties

/// Whether the log file has been `archived` and the logger doesn't use it anymore or not.
@property(assign, nonatomic, getter = isArchived) BOOL archived;

/// Log file modification date.
@property(strong, nonatomic, readonly) NSDate *modificationDate;

/// Log file creation date.
@property(strong, nonatomic, readonly) NSDate *creationDate;

/// Full path to file location, which is represented by receiver.
@property(copy, nonatomic, readonly) NSString *path;

/// Current log file size.
///
/// This value may change pretty fast in case a receiver has been created for the currently opened log
/// file.
@property(assign, nonatomic) unsigned long long size;

/// Name of referenced log file.
@property(copy, nonatomic, readonly) NSString *name;


#pragma mark - Initialization and Configuration

/// Create `file`-based logger log file representation object.
///
/// - Parameter path: Full path to location of file for which wrapper model should be created.
/// - Returns: Ready-to-use log file representation object.
+ (instancetype)informationForFileAtPath:(NSString *)path;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
