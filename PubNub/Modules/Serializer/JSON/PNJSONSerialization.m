#import "PNJSONSerialization.h"
#import "PNFunctions.h"


#pragma mark Interface implementation

@implementation PNJSONSerialization


#pragma mark - Serialization

- (NSData *)dataWithJSONObject:(id)object error:(PNError **)error {
    NSError *eError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&eError];

    if (error && eError) {
        NSDictionary *userInfo = PNErrorUserInfo(
            @"Unable serialize object to JSON",
            PNStringFormat(@"'%@' has unsupported type. Check underlying error for more information.",
                           NSStringFromClass([object class])),
            nil,
            eError
        );
        *error = [PNError errorWithDomain:PNJSONSerializationErrorDomain
                                     code:PNJSONSerializationErrorType
                                 userInfo:userInfo];
    }

    return data;
}

- (id)JSONObjectWithData:(NSData *)data error:(PNError **)error {
    return [self JSONObjectWithData:data options:0 error:error];
}

- (id)JSONObjectWithData:(NSData *)data options:(PNJSONReadingOptions)options error:(PNError **)error {
    NSError *dError;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:(NSJSONReadingOptions)options
                                                  error:&dError];

    if (error && dError) {
        NSDictionary *userInfo = PNErrorUserInfo(
            @"Unable de-serialize object to JSON",
            @"Potentially malformed JSON data. Check underlying error for more information.",
            nil,
            dError
        );
        *error = [PNError errorWithDomain:PNJSONSerializationErrorDomain
                                     code:PNJSONSerializationErrorMalformedJSON
                                 userInfo:userInfo];
    }

    return object;
}

- (BOOL)isValidJSONObject:(id)object {
    return [NSJSONSerialization isValidJSONObject:object];
}

#pragma mark -


@end
