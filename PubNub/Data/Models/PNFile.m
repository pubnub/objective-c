/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNFile+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNFile ()


#pragma mark - Information

/**
 * @brief URL which can be used to download file.
 */
@property (nonatomic, strong) NSURL *downloadURL;

/**
 * @brief Unique uploaded file identifier.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Date when file has been uploaded.
 */
@property (nonatomic, strong) NSDate *created;

/**
 * @brief Uploaded file size.
 */
@property (nonatomic, assign) NSUInteger size;

/**
 * @brief Name with which file has been uploaded.
 */
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c uploaded \c file data model from dictionary.
 *
 * @param data Dictionary with information about \c uploaded \c file from Files API.
 *
 * @return Initialized and ready to use \c uploaded \c file representation model.
 */
- (instancetype)initFromDictionary:(NSDictionary *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFile


#pragma mark - Initialization & Configuration

+ (instancetype)fileFromDictionary:(NSDictionary *)data {
    return [[self alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    if ((self = [super init])) {
        _size = ((NSNumber *)data[@"size"]).unsignedIntegerValue;
        _downloadURL = [NSURL URLWithString:data[@"downloadURL"]];
        _identifier = [data[@"id"] copy];
        _name = [data[@"name"] copy];

        if (data[@"created"]) {
            NSDateFormatter *formatter = [NSDateFormatter pn_filesDateFormatter];
            _created = [formatter dateFromString:data[@"created"]];
        }
    }
    
    return self;
}

#pragma mark -


@end
