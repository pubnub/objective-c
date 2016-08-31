/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Types

/**
 @brief      API call completion block declaration.
 @discussion Block pass two arguments: \c flags - list of user-configured API flags; \c parameters - list of
             API request query and URI parameter-value pairs.
 
 @since <#version#>
 */
typedef void(^PNAPICallCompletionBlock)(NSArray<NSString *> * _Nullable flags, 
                                        NSDictionary * _Nullable parameters);


#pragma mark Private interface declaration

@interface PNAPICallBuilder (Private)


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Copy method and their implementations from API group classes to base class.
 @discussion This approach allow to re-use same instance when user navigated between different options of API 
             call.
 
 @since <#version#>
 
 @param classes Reference on list of classes which describe builders for API from same API group. Classes 
                information will be used to copy methods and implementations to base API call builder class.
 */
+ (void)copyMethodsFromClasses:(NSArray<Class> *)classes;

/**
 @brief  Create and configure builder which will allow to configure furure API call.
 
 @since <#version#>
 
 @param block Reference on block which will be called in response \c -performWithBlock: method call. Block 
              pass two arguments: \c flags - list of user-configured API flags; \c parameters - list of API 
              request query and URI parameter-value pairs.
 
 @return Configured and ready to use API call builder instance.
 */
+ (instancetype)builderWithExecutionBlock:(PNAPICallCompletionBlock)block;

/**
 @brief      Enable specified \c flag for API call.
 @discussion Method can be used during builder initialization to help identify method from API group which 
             should be called.
 
 @since <#version#>
 
 @param flag Reference on \c flag which should be set for API call. 
 */
- (void)setFlag:(NSString *)flag;

/**
 @brief      Set provided \c value for API call \c parameter.
 @discussion Method can be used during builder initialization to provide required parameters for constructed 
             API call.
 
 @since <#version#>
 
 @param value     Reference on value which should be set for \c parameter.
 @param parameter Reference on parameter name for which value should be set.
 */
- (void)setValue:(nullable id)value forParameter:(NSString *)parameter;


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Execute configured API call.
 @discussion Try to use user-provided information to execute target API.
 
 @since <#version#>
 
 @param block Reference on API execution completion block to which \b PubNub client will pass execution 
        results.
 */
- (void)performWithBlock:(id)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
