#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Wrapper class around parameters which should be applied on resource path and query 
             string.
 @discussion Used to help builder identify what parameters related to resource path components and
             what should be used with request query composition.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNRequestParameters : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on expected HTTP method for request.
 
 @since 4.7.0
 */
@property (nonatomic, copy) NSString *HTTPMethod;

/**
 @brief  Stores reference on key/value pairs which should be expanded in remote resource path.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly) NSDictionary<NSString *, NSString *> *pathComponents;

/**
 @brief  Stores reference on key/value pairs which should be expanded in query string.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly) NSDictionary<NSString *, NSString *> *query;


///------------------------------------------------
/// @name Path components manipulation
///------------------------------------------------

/**
 @brief      Add resource path component for placeholder.
 @discussion Placeholder will be placed in request template with specified value.
 
 @param component            Path component value.
 @param componentPlaceholder Name of placeholder instead of which value should be placed.
 
 @since 4.0
 */
- (void)addPathComponent:(NSString *)component forPlaceholder:(NSString *)componentPlaceholder;

/**
 @brief       Remove resource path component.
 @discusssion Clean placeholder value. This method useful in case if basing on further computations
              code need to remove/unset previously stored value.
 
 @since 4.0.2
 */
- (void)removePathComponentForPlaceholder:(NSString *)componentPlaceholder;

/**
 @brief      Add resource path components in placeholder/value format with dictionary.
 @discussion Corresponding placeholder will be placed in request template with specified value.
 
 @param components Dictionary with placeholder name / value pairs.
 
 @since 4.0
 */
- (void)addPathComponents:(NSDictionary *)components;

/**
 @brief      Remove set of values which has been set earlier for placeholders.
 @discussion Corresponding placeholders will be cleared from request computation.
 
 @param components List of placeholer names which should be unset.
 
 @since 4.0.2
 */
- (void)removePathComponents:(NSArray *)components;


///------------------------------------------------
/// @name Query fields manipulation
///------------------------------------------------

/**
 @brief  Add query parameter value for specified name.
 
 @param parameter          Query parameter value.
 @param parameterFieldName Query parameter field name.
 
 @since 4.0
 */
- (void)addQueryParameter:(NSString *)parameter forFieldName:(NSString *)parameterFieldName;

/**
 @brief  Remove query parameter with it's value.
 
 @param parameterFieldName Name of query parameter which should be removed from request computation.
 
 @since 4.0.2
 */
- (void)removeQueryParameterWithFieldName:(NSString *)parameterFieldName;

/**
 @brief  Add query parameters in field name / value format with dictionary.
 
 @param parameters Dictionary with field name / value pairs.
 
 @since 4.0
 */
- (void)addQueryParameters:(NSDictionary *)parameters;

/**
 @brief  Remove set of query parameter with their value.
 
 @param parameters List of query parameter names which should be removed from request computation.
 
 @since 4.0.2
 */
- (void)removeQueryParameters:(NSArray *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
