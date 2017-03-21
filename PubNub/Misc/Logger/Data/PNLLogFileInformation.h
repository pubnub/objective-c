#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      PubNub logger file representation model.
 @discussion Logger's log file wrapper model which simplify manipulation with it.
 
 @author Sergey Mamontov
 @since 4.5.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNLLogFileInformation : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on full path to file location which is represented by receiver.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, copy) NSString *path;

/**
 @brief  Stores reference on name of referenced log file.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 @brief  Stores reference on extension of referenced log file.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, copy) NSString *extension;

/**
 @brief  Stores reference on log file creation date.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, strong) NSDate *creationDate;

/**
 @brief  Stores reference on log file modification date.
 
 @since 4.5.0
 */
@property (nonatomic, readonly, strong) NSDate *modificationDate;

/**
 @brief      Stores information about current log file size.
 @discussion This value may changes pretty fast in case if receiver has been created for currently opened log
             file.
 
 @since 4.5.0
 */
@property (nonatomic, assign) unsigned long long size;

/**
 @brief  Stores whether referenced file has been archived and logger doesn't use it anymore or not.
 
 @since 4.5.0
 */
@property (nonatomic, assign, getter = isArchived) BOOL archived;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Create and configure information model object for file at specified \c path.
 
 @since 4.5.0
 
 @param path Full path to location of file for which wrapper model should be created.
 
 @return Configured and ready to use file information model.
 */
+ (instancetype)informationForFileAtPath:(NSString *)path;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
