#import <Foundation/Foundation.h>
#import "PNXML.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief XML data parser.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNXMLParser : NSObject


#pragma mark - Information

/**
 * @brief XML processing error.
 */
@property (nonatomic, nullable, readonly, strong) NSError *parserError;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure XML parser.
 *
 * @param data Data which should be parsed.
 *
 * @return Configured and ready to use XML parser.
 */
+ (instancetype)parserWithData:(NSData *)data;


#pragma mark - Parse

/**
 * @brief Parse provided XML data and create XML representation model.
 *
 * @return Parsed XML data representation model or \c nil in case of parsing error
 * (check \c parseError for error details).
 */
- (nullable PNXML *)parse;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
