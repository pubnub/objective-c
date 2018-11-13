/**
 @author Sergey Mamontov
 @since 4.5.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNLLogFileInformation.h"
#import "PNLockSupport.h"
#import <sys/xattr.h>


#pragma mark Static

/**
 @brief  Stores reference of file extended attribute name which is used to mark file as \c archived.
 
 @since 4.5.0
 */
static NSString * const kPNLArchivedFileAttributeName = @"com.pubnub.logger.archived";


#pragma mark Private interface declaration

@interface PNLLogFileInformation ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *extension;

/**
 @brief  Stores referenced log file attributes set.
 
 @since 4.5.0
 */
@property (nonatomic, copy) NSDictionary *attributes;

/**
 @brief  Lock which is used to protect access to shared resources from multiple threads.

 @since 4.7.5
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
@property (nonatomic, assign) os_unfair_lock accessLock;
#pragma clang diagnostic pop


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize information model object for file at specified \c path.
 
 @since 4.5.0
 
 @param path Full path to location of file for which wrapper model should be created.
 
 @return Initialized and ready to use file information model.
 */
- (instancetype)initForFileAtPath:(NSString *)path;


#pragma mark - Misc

/**
 * @brief  Exclude represented file from device local and iCloud backups.
 *
 * @since 4.7.7
 */
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


#pragma mark - Interface implementation

@implementation PNLLogFileInformation


#pragma mark - Information

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
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        _accessLock = OS_UNFAIR_LOCK_INIT;
#pragma clang diagnostic pop
        _path = [path copy];
        _name = [[_path lastPathComponent] copy];
        _extension = ([_path pathExtension].length ? [_path pathExtension] : nil);
        
        [self excludeFromBackup];
    }
    
    return self;
}


#pragma mark - Misc

- (BOOL)isEqual:(id)object {
    
    BOOL isEqual = NO;
    if ([object isKindOfClass:[self class]]) {
        
        isEqual = [((PNLLogFileInformation *)object).path isEqualToString:self.path];
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
