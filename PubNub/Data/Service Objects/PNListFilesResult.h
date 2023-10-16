#import <PubNub/PNServiceData.h>
#import <PubNub/PNOperationResult.h>
#import <PubNub/PNFile.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Files API response for \c list \c files request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNListFilesData : PNServiceData


#pragma mark - Information

/**
 * @brief List of channel \c files.
 */
@property (nonatomic, nullable, readonly, strong) NSArray<PNFile *> *files;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief How many \c files has been returned.
 */
@property (nonatomic, readonly, assign) NSUInteger count;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c list \c files request results.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNListFilesResult : PNOperationResult


#pragma mark - Information

/**
 * @brief \c List \c files request processed information.
 */
@property (nonatomic, readonly, strong) PNListFilesData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
