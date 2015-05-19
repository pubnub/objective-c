/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult.h"


#pragma mark Class forward

@class PNRequest;


#pragma mark - Private interface declaration

@interface PNResult ()


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on request object which has been used as template for network request to
         \b PubNub services.

 @since 4.0
*/
@property (nonatomic, strong) PNRequest *requestObject;
\
@property (nonatomic, copy) NSURLRequest *clientRequest;
@property (nonatomic, copy) NSDictionary *headers;
@property (nonatomic, copy) id response;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, assign) PNOperationType operation;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) id data;


///------------------------------------------------
/// @name Initialization and configuration
///------------------------------------------------

/**
 @brief  Create operation result object with pre-defined set of parameters.

 @param request  Reference on base request instance which hold information about operation type and
                 real network request built from it.
 
 @return Initialized and ready to use status object.
 
 @since 4.0
 */
+ (instancetype)resultForRequest:(PNRequest *)request;

/**
 @brief  Extract result information from status object and populate it with new data.
 @discussion This method moslty used by API endpoints which should provide operation status, but
             also may receive additional data which should be converted to result.
 
 @param status \b PNStatus instance which should be used to pulk out data.
 @param data   Pre-parsed data which should be bound to result object.
 
 @return Created and ready to use status instance
 
 @since 4.0
 */
+ (instancetype)resultFromStatus:(PNStatus *)status withData:(id)data;

/**
 @brief  Initialize operation result object with pre-defined set of parameters.
 
 @param request  Reference on base request instance which hold information about operation type and
                 real network request built from it.
 
 @return Ready to use status object.
 
 @since 4.0
 */
- (instancetype)initForRequest:(PNRequest *)request;

/**
 @brief      Make copy of current status object with data to store in it.
 @discussion Method can be used to create sub-events (for example one for each message or presence 
             event).
 
 @param data Reference on data which should be stored within status object.
 
 @return Copy of receiver with modified data.
 
 @since 4.0
 */
- (instancetype)copyWithData:(id)data;


///------------------------------------------------
/// @name Processing
///------------------------------------------------

/**
 @brief      Try parse received data as error response.
 @discussion In case if initial parsing using suggested processing block failed this method is used
             to try process data as error.
 
 @param data Reference on data which should be parsed.
 
 @return Error information stored in \a NSDIctionary or \c nil in case if error format not 
         recognized.
 
 @since 4.0
 */
- (NSDictionary *)dataParsedAsError:(id)data;


///------------------------------------------------
/// @name Misc
///------------------------------------------------

/**
 @brief  Convert result object to dictionary which can be used to print out structured data
 
 @return Object in dictionary representation.
 
 @since 4.0
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 @brief  Convert result object to string which can be used to print out data
 
 @return Stringified object representation.
 
 @since 4.0
 */
- (NSString *)stringifiedRepresentation;

#pragma mark -


@end
