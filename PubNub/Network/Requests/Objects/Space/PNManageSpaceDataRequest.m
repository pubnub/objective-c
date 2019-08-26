/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNManageSpaceDataRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNManageSpaceDataRequest


#pragma mark - Information

- (void)setName:(NSString *)name {
    if (_name.length == 0 && name.length) {
        _name = [name copy];
    }
}

- (NSData *)bodyData {
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];
    
    if (self.name && self.name.length == 0) {
        self.parametersError = [self missingParameterError:@"name" forObjectRequest:@"Space"];
    }
    
    if (self.custom.count && ![PNDictionary isDictionary:self.custom containValueOfClasses:clss]) {
        NSString *reason = [NSString stringWithFormat:@"'custom' object for '%@' space contain not "
                            "allowed data types (only NSString and NSNumber allowed).",
                            self.identifier];
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Space additional information serialization did fail",
            NSLocalizedFailureReasonErrorKey: reason,
        };

        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }
    
    if (self.parametersError) {
        return nil;
    }

    NSMutableDictionary *info = [@{ @"id": self.identifier } mutableCopy];
    NSError *error = nil;
    NSData *data = nil;
    
    if (self.name) {
        info[@"name"] = self.name;
    }

    if (self.information.length) {
        info[@"description"] = self.information;
    }

    if (self.custom.count) {
        info[@"custom"] = self.custom;
    }
    
    if ([NSJSONSerialization isValidJSONObject:info]) {
        data = [NSJSONSerialization dataWithJSONObject:info
                                               options:(NSJSONWritingOptions)0
                                                 error:&error];
    } else {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Unable to serialize to JSON string",
            NSLocalizedFailureReasonErrorKey: @"Provided object contains unsupported data type instances."
        };
        
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:NSPropertyListWriteInvalidError
                                userInfo:errorInformation];
    }

    if (error) {
        NSDictionary *errorInformation = @{
            NSLocalizedDescriptionKey: @"Space information serialization did fail",
            NSUnderlyingErrorKey: error
        };

        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }

    return data;
}

#pragma mark -


@end
