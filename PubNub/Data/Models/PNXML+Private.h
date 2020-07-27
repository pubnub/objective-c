#import "PNXML.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private XML model extension to provide access to initialized.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNXML (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure parser XML representation model.
 *
 * @param data Dictionary with information which has been parsed by \a NSXMLParser.
 *
 * @return Configured and ready to use XML representation model.
 */
+ (instancetype)xmlWithDictionary:(NSDictionary *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
