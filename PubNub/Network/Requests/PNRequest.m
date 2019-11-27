/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNRequest ()

#pragma mark - Information

/**
 * @brief Object with information which should be used for request URI composition.
 *
 * @since 4.12.0
 */
@property (nonatomic, strong) PNRequestParameters *requestParameters;

/**
 * @brief Error which represent any request parameters error.
 */
@property (nonatomic, nullable, strong) NSError *parametersError;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRequest


#pragma mark - Information

- (NSString *)httpMethod {
    return @"GET";
}

- (BOOL)returnsResponse {
    return [self.httpMethod.uppercaseString isEqualToString:@"GET"] ? YES : NO;
}

- (void)setParametersError:(NSError *)parametersError {
    if (!_parametersError) {
        _parametersError = parametersError;
    }
}

- (PNRequestParameters *)requestParameters {
    if (!_requestParameters) {
        _requestParameters = [PNRequestParameters new];
    }
    
    return _requestParameters;
}


#pragma mark - Misc

- (NSError *)missingParameterError:(NSString *)parameter forObjectRequest:(NSString *)objectType {
    NSString *reason = [NSString stringWithFormat:@"%@'s '%@' parameter is missing or empty.",
                        objectType.capitalizedString, parameter];
    NSDictionary *errorInformation = @{
        NSLocalizedDescriptionKey: @"Request parameters error",
        NSLocalizedFailureReasonErrorKey: reason
    };
    
    return [NSError errorWithDomain:kPNAPIErrorDomain
                               code:kPNAPIUnacceptableParameters
                           userInfo:errorInformation];
}

- (NSError *)valueTooLongErrorForParameter:(NSString *)parameter
                           ofObjectRequest:(NSString *)objectType
                                withLength:(NSUInteger)actualLength
                             maximumLength:(NSUInteger)maximumLength {
    NSString *reason = [NSString stringWithFormat:@"%@'s '%@' parameter is too long (%@ when %@ "
                        "maximum allowed).", objectType.capitalizedString, parameter,
                        @(actualLength), @(maximumLength)];
    NSDictionary *errorInformation = @{
        NSLocalizedDescriptionKey: @"Request parameters error",
        NSLocalizedFailureReasonErrorKey: reason
    };
    
    return [NSError errorWithDomain:kPNAPIErrorDomain
                               code:kPNAPIUnacceptableParameters
                           userInfo:errorInformation];
}

- (void)throwUnavailableInitInterface {
    NSDictionary *errorInformation = @{
        NSLocalizedRecoverySuggestionErrorKey: @"Use provided request constructor"
    };

    @throw [NSException exceptionWithName:@"PNInterfaceNotAvailable"
                                   reason:@"+new or -init methods unavailable."
                                 userInfo:errorInformation];
}

#pragma mark -


@end
