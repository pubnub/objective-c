#import "PNRequestParameters.h"
#import "PNStructures.h"
#import "PNRequest.h"



NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private extension of base class for request based API interface.
 *
 * @discussion Extension with additional information which can be used by older SDK infrastructure.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNRequest (Private)


#pragma mark - Information

/**
 * @brief Object with information which should be used for request URI composition.
 */
@property (nonatomic, readonly, strong) PNRequestParameters *requestParameters;

/**
 * @brief Binary payload which should be sent with request.
 */
@property (nonatomic, nullable, readonly, strong) NSData *bodyData;

/**
 * @brief Type of operation performed with use of request object.
 */
@property (nonatomic, readonly, assign) PNOperationType operation;

/**
 * @brief Error which represent any request parameters error.
 */
@property (nonatomic, nullable, strong) NSError *parametersError;

/**
 * @brief HTTP method which should be used to perform target request.
 *
 * @note Will be set to \c GET if not implemented.
 */
@property (nonatomic, readonly, strong) NSString *httpMethod;


#pragma mark - Misc

/**
 * @brief Add another data field to 'include' query fields set.
 *
 * @param fields List of names of data fields which should be added to 'include' list.
 * @param requestParameters Request's parameters object which is used to build actual network
 * request.
 */
- (void)addIncludedFields:(NSArray<NSString *> *)fields
                toRequest:(PNRequestParameters *)requestParameters;

/**
 * @brief Create error which will provide information about missing required request parameter.
 *
 * @param parameter Name of missed of empty parameter.
 * @param objectType Name of object type (so far known: \c Space and \c User).
 *
 * @return Error with information about missing parameter.
 */
- (NSError *)missingParameterError:(NSString *)parameter forObjectRequest:(NSString *)objectType;

/**
 * @brief Create error which will provide information about that one of request parameter values is
 * too long.
 *
 * @param parameter Name of parameter who's length exceed maximum value.
 * @param objectType Name of object type (so far known: \c Space and \c User).
 * @param actualLength Actual value length.
 * @param maximumLength Maximum allowed value length.
 *
 * @return Error with information about missing parameter.
 */
- (NSError *)valueTooLongErrorForParameter:(NSString *)parameter
                           ofObjectRequest:(NSString *)objectType
                                withLength:(NSUInteger)actualLength
                             maximumLength:(NSUInteger)maximumLength;

/**
 * @brief Helper method to throw exception in case if request instance require constructor usage but
 * has been called with \c -init or \c +new.
 *
 * @throws \c PNInterfaceNotAvailable exception.
 */
- (void)throwUnavailableInitInterface;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
