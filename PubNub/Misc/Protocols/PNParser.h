#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Interface delcaration for all classes which should be suitable for \b PubNub service response
             processing.
 @discussion Classes which conform to this protocol will be gathered at run-time and used when response on 
             corresponding operation will arrive.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@protocol PNParser <NSObject>


@required

///------------------------------------------------
/// @name Identification
///------------------------------------------------

/**
 @brief  Allow to identify for what kind of operations this parser is suitable.
 
 @return List of \b PNOperationType enum fields to represent operations.
 
 @since 4.0
 */
+ (NSArray<NSNumber *> *)operations;

/**
 @brief  Allow to check whether corresponding parser require additional data from caller to process service
         response or not.
 
 @return \c YES in case if additional client information should be provided.
 
 @since 4.0
 */
+ (BOOL)requireAdditionalData;


@optional

///------------------------------------------------
/// @name Parsing
///------------------------------------------------

/**
 @brief  Process data which has been received from \b PubNub service for \c operation.
 
 @param response De-serialized from JSON Foundation object service response.
 
 @return Parsed service response or \c nil in case if parser unable to handle service response.
 
 @since 4.0
 */
+ (nullable NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response;

/**
 @brief  Process data which has been received from \b PubNub service for \c operation with additional data 
         required to complete processing.
 
 @param response       De-serialized from JSON Foundation object service response.
 @param additionalData Reference on dictionary which stores additional data which can be used by parser to 
                       complete parsing.
 
 @return Parsed service response or \c nil in case if parser unable to handle service response.
 
 @since 4.0
 */
+ (nullable NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response 
   withData:(nullable NSDictionary<NSString *, id> *)additionalData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
