#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Parsed XML data representation model.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNXML : NSObject


#pragma mark - Reading

/**
 * @brief Access to parser XML element value by it's name.
 *
 * @param key Name of XML element for which value should be retrieved.
 *
 * @return Parsed XML element value or \c nil if element doesn't exists.
 */
- (nullable id)valueForKey:(NSString *)key;

/**
 * @brief Access to nested XML element value.
 *
 * @note It is possible to access element attribute value by prepending it's name with \c @.
 *
 * @param keyPath Path which consist from nested element names.
 *
 * @return Parsed XML element / attribute value or \c nil if element / attribute doesn't exists.
 */
- (nullable id)valueForKeyPath:(NSString *)keyPath;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
