/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNSetChannelMetadataRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNDictionary.h"


#pragma mark Interface implementation

@implementation PNSetChannelMetadataRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNSetChannelMetadataOperation;
}

- (NSString *)httpMethod {
    return @"PATCH";
}

- (NSData *)bodyData {
    NSArray<Class> *clss = @[[NSString class], [NSNumber class]];

    if (self.custom.count && ![PNDictionary isDictionary:self.custom containValueOfClasses:clss]) {
        NSString *reason = [NSString stringWithFormat:@"'custom' object for '%@' channel metadata "
                            "contain not allowed data types (only NSString and NSNumber allowed).",
                            self.identifier];
        NSDictionary *errorInformation = @{
                NSLocalizedDescriptionKey: @"Channel metadata additional information serialization "
                                           "did fail",
                NSLocalizedFailureReasonErrorKey: reason,
        };

        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }

    if (self.parametersError) {
        return nil;
    }

    NSMutableDictionary *info = [NSMutableDictionary new];
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
                NSLocalizedDescriptionKey: @"Channel metadata information serialization did fail",
                NSUnderlyingErrorKey: error
        };

        self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                   code:kPNAPIUnacceptableParameters
                                               userInfo:errorInformation];
    }

    return data;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithObject:@"Channel" identifier:channel];
}

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) {
        _includeFields = PNChannelCustomField;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
