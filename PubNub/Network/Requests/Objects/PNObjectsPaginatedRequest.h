#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base class for Object API endpoints which return list of items and allow to navigate
 * between pages.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNObjectsPaginatedRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief Results sorting order.
 *
 * @discussion List of criteria (name of field) which should be used for sorting in ascending order.
 * To change sorting order, append \c :asc (for ascending) or \c :desc (descending) to field name.
 */
@property (nonatomic, nullable, strong) NSArray<NSString *> *sort;

/**
 * @brief Expression to filter out results basing on specified criteria.
 */
@property (nonatomic, nullable, copy) NSString *filter;

/**
 * @brief Previously-returned cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, copy) NSString *start;

/**
 * @brief Previously-returned cursor bookmark for fetching the previous page.
 *
 * @note Ignored if you also supply the \c start parameter.
 */
@property (nonatomic, nullable, copy) NSString *end;

/**
 * @brief Number of objects to return in response.
 *
 * @note Will be set to \c 100 (which is also maximum value) if not specified.
 */
@property (nonatomic, assign) NSUInteger limit;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

