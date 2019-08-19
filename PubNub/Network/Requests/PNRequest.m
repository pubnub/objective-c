/**
 * @author Serhii Mamontov
 * @version 4.10.0
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

- (void)setParametersError:(NSError *)parametersError {
    if (!_parametersError) {
        _parametersError = parametersError;
    }
}

- (PNRequestParameters *)requestParameters {
    return [PNRequestParameters new];
}


#pragma mark - Misc

- (void)addIncludedFields:(NSArray<NSString *> *)fields
                toRequest:(PNRequestParameters *)requestParameters {
    
    NSString *include = [requestParameters query][@"include"];
    NSMutableArray *includeFields = [[include componentsSeparatedByString:@","] ?: @[] mutableCopy];
    [includeFields addObjectsFromArray:fields];

    [requestParameters removeQueryParameterWithFieldName:@"include"];
    [requestParameters addQueryParameter:[includeFields componentsJoinedByString:@","]
                            forFieldName:@"include"];
}

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
