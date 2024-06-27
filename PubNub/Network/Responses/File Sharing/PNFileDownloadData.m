#import "PNFileDownloadData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration
/// `Download file` request response private extension.
@interface PNFileDownloadData ()


#pragma mark - Properties

/// Whether file is temporary or not.
///
/// > Warning:  Temporary file will be removed as soon as completion block will exit. Make sure to move temporary files
/// (w/o scheduling task on secondary thread) to persistent location.
@property(assign, nonatomic, getter = isTemporary) BOOL temporary;

/// Location where downloaded file can be found.
@property(strong, nullable, nonatomic) NSURL *location;


#pragma mark - Initialization and Configuration

/// Initialize `Download file` request response.
///
/// - Parameters:
///   - location: Location where downloaded file can be found.
///   - temporarily: Whether file is temporary or not.
/// - Returns: Initialized `Download File` request response.
- (instancetype)initForFileAtLocation:(NSURL *)location temporarily:(BOOL)temporarily;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileDownloadData


#pragma mark - Initialization and Configuration

+ (instancetype)dataForFileAtLocation:(NSURL *)location temporarily:(BOOL)temporarily {
    return [[self alloc] initForFileAtLocation:location temporarily:temporarily];
}

- (instancetype)initForFileAtLocation:(NSURL *)location temporarily:(BOOL)temporarily {
    if ((self = [super init])) {
        _temporary = temporarily;
        _location = location;
    }

    return self;
}


#pragma mark -


@end
