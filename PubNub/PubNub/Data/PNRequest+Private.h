/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRequest.h"


#pragma mark Private interface declaration

@interface PNRequest ()


#pragma mark - Information

@property (nonatomic, copy) id(^parseBlock)(id rawData);


#pragma mark - Initialization and configuration

/**
 @brief  Construct request instance with predefined configuration (the only way to pass data into 
         this class).
 
 @param resourcePath Stores reference on path which will be used to get access to \b PubNub 
                     services.
 @param parameters   Stores reference on query parameters storage which should be passed along with
                     resource path.
 @param operation    Represent type of operation which should be issued to \b PubNub service.
 @param block        Stores reference on block which should be called at the end of operation 
                     processing.
 
 @return Configured and ready to use request instance.
 
 @since 4.0
 */
+ (instancetype)requestWith:(NSString *)resourcePath parameters:(NSDictionary *)parameters
                        for:(PNOperationType)operation withCompletion:(PNHandlingBlock)block;

/**
 @brief  Initialize request instance with predefined configuration (the only way to pass data into
         this class).
 
 @param resourcePath Stores reference on path which will be used to get access to \b PubNub 
                     services.
 @param parameters   Stores reference on query parameters storage which should be passed along with
                     resource path.
 @param operation    Represent type of operation which should be issued to \b PubNub service.
 @param block        Stores reference on block which should be called at the end of operation 
                     processing.
 
 @return Configured and ready to use request instance.
 
 @since 4.0
 */
- (instancetype)initWith:(NSString *)resourcePath parameters:(NSDictionary *)parameters
                     for:(PNOperationType)operation withCompletion:(PNHandlingBlock)block;

#pragma mark -


@end
