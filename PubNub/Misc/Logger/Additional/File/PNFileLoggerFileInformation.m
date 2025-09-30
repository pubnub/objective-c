#import "PNFileLoggerFileInformation.h"
#import "PNLockSupport.h"
#import <sys/xattr.h>


#pragma mark Statics

/// File extended attribute name which is used to mark file as `archived`.
static NSString * const kPNLArchivedFileAttributeName = @"com.pubnub.logger.archived";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// `File`-based logger log file representation model private extension.
@interface PNFileLoggerFileInformation ()


#pragma mark - Properties

/// Shared resources access protection lock.
@property(assign, nonatomic) pthread_mutex_t accessLock;

/// Log file attributes set.
@property (nonatomic, copy) NSDictionary *attributes;

/// Full path to file location, which is represented by receiver.
@property(copy, nonatomic) NSString *path;

/// Name of referenced log file.
@property(copy, nonatomic) NSString *name;


#pragma mark - Initialization and Configuration

/// Initialize `file`-based logger log file representation object.
///
/// - Parameter path: Full path to location of file for which wrapper model should be created.
/// - Returns: Initialized log file representation object.
- (instancetype)initForFileAtPath:(NSString *)path;


#pragma mark - Misc

/// Exclude represented file from device local and iCloud backups.
- (void)excludeFromBackup;

/**
 @brief  Check whether referenced file has attribute with specified \c name or not.
 
 @since 4.5.0
 
 @param name Reference on attribute name for which check should be done.
 
 @return \c YES in case if attribute with specified \c name is set.
 */
- (BOOL)hasExtendedAttribute:(NSString *)name;

/**
 @brief  Update referenced file extended attributes by adding or removing (depending on \c shouldSetAttribute 
         value) attribute with \c name.
 
 @since 4.5.0
 
 @param shouldSet Whether attribute should be added or removed.
 @param name      Reference on extended attribute \c name for which manipulation should be done.
 */
- (void)setAttribute:(BOOL)shouldSet withName:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileLoggerFileInformation


#pragma mark - Properties

- (NSDictionary *)attributes {

    pn_lock(&_accessLock, ^{
        if (!self->_attributes) {

            self->_attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:nil];
        }
    });
    
    return _attributes;
}

- (NSDate *)creationDate {
    
    return self.attributes[NSFileCreationDate];
}

- (NSDate *)modificationDate {
    
    return self.attributes[NSFileModificationDate];
}

- (unsigned long long)size {
    
    if (_size == 0) { _size = ((NSNumber *)self.attributes[NSFileSize]).unsignedLongLongValue; }
    
    return _size;
}

- (BOOL)isArchived {
    
    return [self hasExtendedAttribute:kPNLArchivedFileAttributeName];
}

- (void)setArchived:(BOOL)archived {
    
    [self setAttribute:archived withName:kPNLArchivedFileAttributeName];
}

#pragma mark - Initialization and Configuration

+ (instancetype)informationForFileAtPath:(NSString *)path {
    return [[self alloc] initForFileAtPath:path];
}

- (instancetype)initForFileAtPath:(NSString *)path {
    if ((self = [super init])) {
        _name = [[path lastPathComponent] copy];
        _path = [path copy];
        
        pthread_mutex_init(&_accessLock, nil);
        
        [self excludeFromBackup];
    }
    
    return self;
}


#pragma mark - Misc

- (BOOL)isEqual:(id)object {
    BOOL isEqual = NO;
    
    if ([object isKindOfClass:[self class]]) {
        isEqual = [((PNFileLoggerFileInformation *)object).path isEqualToString:self.path];
    }
    
    return isEqual;
}

- (void)excludeFromBackup {
    NSError *error = nil;
    
    if (![[NSURL fileURLWithPath:self.path] setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
#if DEBUG
        NSLog(@"PNLLogger: '%@' attribute set did dail for '%@': %@", NSURLIsExcludedFromBackupKey, self.path, error);
#endif // DEBUG
    }
}

- (BOOL)hasExtendedAttribute:(NSString *)name {
    
    return (getxattr([self.path UTF8String], [name UTF8String], NULL, 0, 0, 0) > 0);
}

- (void)setAttribute:(BOOL)shouldSet withName:(NSString *)name {
    
    const char *cPath = [self.path UTF8String];
    const char *cName = [name UTF8String];
    u_int8_t value = 1;
    
    ssize_t result = (shouldSet ? setxattr(cPath, cName, &value, sizeof(u_int8_t), 0, 0) :
                      removexattr(cPath, cName, 0));
    if (result < 0 && errno != ENOATTR) {
#if DEBUG
        NSLog(@"PNLLogger: '%@' attribute %@ did fail for %@: %s", name, (shouldSet ? @"set" : @"removal"), 
              self.name, strerror(errno));
#endif // DEBUG
    }
}

#pragma mark -


@end
