/**
 * @author Serhii Mamontov
 * @version 4.15.6
 * @since 4.0.2
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNNetworkResponseSerializer.h"


#pragma mark Externs

NSString * const kPNNetworkErrorResponseDataKey = @"PNNetworkErrorResponseDataKey";


#pragma mark - Private interface declaration

@interface PNNetworkResponseSerializer ()


#pragma mark - Properties

/**
 * @brief Stores reference on list of expected MIME types which can be handled by serialiser.
 */
@property (nonatomic) NSArray *expectedMIMETypes;


#pragma mark - Serialisation

/**
 * @brief Try fix serialised response if required.
 *
 * @discussion Server may send malformed response, which may cause troubles in JSON parser,
 * so binary data should be fixed before sending to JSON parser.
 *
 * @param response Reference on HTTP response object which has metadata which should be used in
 *   pre-processing to identify whether body should be processed or not.
 * @param serialisedResponse Output of initial response serialisation code.
 * @param data Server response binary data which should be adjusted if required.
 * @param serialisationError Error which has been generated during initial response
 *   serialisation code call.
 * @param error Pointer to error which should be passed to caller for further parse issues
 *   handling.
 *
 * @return Serialised response after service response binary data has been adjusted.
 *
 * @since 4.15.6
 */
- (id)fixedSerialisedResponse:(nullable id)serialisedResponse
              forHTTPResponse:(nullable NSHTTPURLResponse *)response
                     fromData:(NSData *)data
       withSerialisationError:(nullable NSError *)serialisationError
              processingError:(NSError **)error;


#pragma mark - Misc

/**
 * @brief Verify response metadata and construct error object in case if data can't be handled.
 *
 * @discussion Depending on few fields stored within HTTP response serialised will determine whether
 * response can be serialised or not.
 *
 * @param error Reference on storage for generated error.
 * @param response Reference on HTTP response instance with metadata information against which
 *   check should be performed.
 * @param responseData Reference on downloaded response data.
 *
 * @return \c YES in case if error occurred.
 */
- (BOOL)getProcessingError:(NSError **)error
  ifUnableToHandleResponse:(NSHTTPURLResponse *)response
                  withData:(NSData *)responseData;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNNetworkResponseSerializer


#pragma mark - Initialization and configuration

- (instancetype)init {
    if ((self = [super init])) {
        _expectedMIMETypes = [@[@"application/json", @"text/json", @"text/javascript"] copy];
    }
    
    return self;
}


#pragma mark - Serialisation

- (id)serializedResponse:(NSHTTPURLResponse *)response
                withData:(NSData *)data
                   error:(NSError *__autoreleasing *)serialisationError {
    
    id serialisedResponse = nil;
    NSError *unexpectedResponseError = nil;
    
    if (![self getProcessingError:&unexpectedResponseError
         ifUnableToHandleResponse:response
                         withData:data]) {
        
        if (data.length) {
            @autoreleasepool {
                NSError *JSONSerializationError = nil;
                serialisedResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&JSONSerializationError];
                
                serialisedResponse = [self fixedSerialisedResponse:serialisedResponse
                                                   forHTTPResponse:response
                                                          fromData:data
                                            withSerialisationError:JSONSerializationError
                                                   processingError:&unexpectedResponseError];
            }
        }
    }
    
    if (unexpectedResponseError) {
        *serialisationError = unexpectedResponseError;
    }
    
    return serialisedResponse;
}

- (id)fixedSerialisedResponse:(id)serialisedResponse
              forHTTPResponse:(NSHTTPURLResponse *)response
                     fromData:(NSData *)data
       withSerialisationError:(NSError *)serialisationError
              processingError:(NSError **)error {
    
    id fixedSerialisedResponse = serialisedResponse;
    
    if (serialisationError && [serialisationError.domain isEqualToString:NSCocoaErrorDomain] &&
        serialisationError.code == NSPropertyListReadCorruptError) {
        
        NSData *nulByte = [[NSData alloc] initWithBytes:(char[]){0xFF} length:1];
        NSRange nulByteRange = [data rangeOfData:nulByte
                                         options:(NSDataSearchOptions)0
                                           range:NSMakeRange(0, data.length)];
        
        if (nulByteRange.location != NSNotFound) {
            NSMutableData *mutableData = [data mutableCopy];
            
            while (nulByteRange.location != NSNotFound) {
                [mutableData replaceBytesInRange:nulByteRange withBytes:NULL length:0];
                nulByteRange = [mutableData rangeOfData:nulByte
                                                options:(NSDataSearchOptions)0
                                                  range:NSMakeRange(0, mutableData.length)];
            }
            
            fixedSerialisedResponse = [self serializedResponse:response
                                                      withData:[mutableData copy]
                                                         error:error];
            
            if (!fixedSerialisedResponse && error) {
                NSMutableDictionary *userInfo = [NSMutableDictionary new];
                userInfo[NSLocalizedDescriptionKey] = @"Request completed, but received data"
                    "corrupt and can't be decoded properly.";
                
                if (response.URL) {
                    userInfo[NSURLErrorFailingURLErrorKey] = response.URL;
                }
                
                if (mutableData.length) {
                    userInfo[kPNNetworkErrorResponseDataKey] = [mutableData copy];
                }
                
                if (error) {
                    *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorBadServerResponse
                                             userInfo:userInfo];
                }
            }
        }
    }
    
    return fixedSerialisedResponse;
}


#pragma mark - Misc

- (BOOL)getProcessingError:(NSError **)error
  ifUnableToHandleResponse:(NSHTTPURLResponse *)response
                  withData:(NSData *)responseData {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    NSInteger statusCode = NSURLErrorUnknown;
    
    if (response) {
        NSString *description = nil;
        
        if (![self.expectedMIMETypes containsObject:response.MIMEType]) {
            description = [NSString stringWithFormat:@"Request completed but unexpected data type "
                           "received in response: %@", response.MIMEType];
            statusCode = NSURLErrorCannotDecodeContentData;
        } else if (response.statusCode >= 400) {
            description = [NSString stringWithFormat:@"Request failed: %@ (%ld)",
                           [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode],
                           (long)response.statusCode];
            statusCode = NSURLErrorBadServerResponse;
        }
        
        if (description) {
            userInfo[NSLocalizedDescriptionKey] = description;
        }
    }
    
    if (userInfo.count) {
        if (response.URL) {
            userInfo[NSURLErrorFailingURLErrorKey] = response.URL;
        }
        
        if (responseData.length) {
            userInfo[kPNNetworkErrorResponseDataKey] = responseData;
        }
        
        if (error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:userInfo];
        }
    }
    
    return statusCode != NSURLErrorUnknown;
}

#pragma mark -


@end
