/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRequest.h"


#pragma mark Class forward

@class PNResult, PNStatus;


#pragma mark - Private interface declaration

@interface PNRequest ()


#pragma mark - Information

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSData *body;


#pragma mark - Handling and processing

/**
 @brief  Stores reference on block which is called to translate RAW service response to acceptable
         format which can be processed further.
 
 @since 4.0
 */
@property (nonatomic, copy) id(^parseBlock)(id rawData);


#pragma mark - Initialization and configuration

/**
 @brief  Construct request instance with predefined configuration (the only way to pass data into 
         this class).
 
 @param resourcePath    Stores reference on path which will be used to get access to \b PubNub
                        services.
 @param queryParameters Stores reference on query parameters storage which should be passed along 
                        with resource path.
 @param type            Represent type of operation which should be issued to \b PubNub service.
 @param block           Stores reference on block which should be called at the end of operation
                        processing.
 
 @return Configured and ready to use request instance.
 
 @since 4.0
 */
+ (instancetype)requestWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                   forOperation:(PNOperationType)type withCompletion:(PNCompletionBlock)block;

/**
 @brief  Initialize request instance with predefined configuration (the only way to pass data into
         this class).
 
 @param resourcePath    Stores reference on path which will be used to get access to \b PubNub
                        services.
 @param queryParameters Stores reference on query parameters storage which should be passed along 
                        with resource path.
 @param type            Represent type of operation which should be issued to \b PubNub service.
 @param block           Stores reference on block which should be called at the end of operation
                        processing.
 
 @return Configured and ready to use request instance.
 
 @since 4.0
 */
- (instancetype)initWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                forOperation:(PNOperationType)type withCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
