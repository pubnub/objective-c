/**
 @author Sergey Mamontov
 @since 4.0.2
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNNetworkResponseSerializer.h"


#pragma mark Externs

NSString * const kPNNetworkErrorResponseDataKey = @"PNNetworkErrorResponseDataKey";


#pragma mark - Private interface declaration

@interface PNNetworkResponseSerializer ()


#pragma mark - Properties

/**
 @brief  Stores reference on list of expected MIME types which can be handled by serializer.
 
 @since 4.0.2
 */
@property (nonatomic) NSArray *expectedMIMETtypes;


#pragma mark - Misc

/**
 @brief      Verify resopnse metadata and construct error object in case if data can't be handled.
 @discussion Depending on few fields stored within HTTP response serialized will determine whether 
             response can be serialized or not.
 
 @param error        Reference on storage for generated error.
 @param response     Reference on HTTP response instance with metadata information against which 
                     check should be performed.
 @param responseData Reference on downloaded response data.
 
 @return \c YES in case if error occurred.
 
 @since 4.0.2
 */
- (BOOL)getProcessingError:(NSError **)error ifUnableToHandleResponse:(NSHTTPURLResponse *)response
                  withData:(NSData *)responseData;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNNetworkResponseSerializer


#pragma mark - Initialization and configuration

- (instancetype)init {
    
    // Check whether initialization was successful or not
    if ((self = [super init])) {
        
        _expectedMIMETtypes = [@[@"application/json", @"text/json", @"text/javascript"] copy];
    }
    
    return self;
}


#pragma mark - Serialization

- (id)serializedResponse:(NSHTTPURLResponse *)response withData:(NSData *)data
                   error:(NSError *__autoreleasing *)serializationError {
    
    id serializedResponse = nil;
    NSError *unexpectedResponseError = nil;
    if (![self getProcessingError:&unexpectedResponseError ifUnableToHandleResponse:response
                         withData:data]) {
        
        if ([data length]) {
            
            @autoreleasepool {
                
                NSError *JSONSerializationError = nil;
                serializedResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:(NSJSONReadingOptions)0
                                                                       error:&JSONSerializationError];
            }
        }
    }
    else {
        
        *serializationError = unexpectedResponseError;
    }
    
    return serializedResponse;
}


#pragma mark - Misc

- (BOOL)getProcessingError:(NSError **)error ifUnableToHandleResponse:(NSHTTPURLResponse *)response
                  withData:(NSData *)responseData {
    
    // Prepare variables to describe unacceptable response error.
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    NSInteger statusCode = NSURLErrorUnknown;
    
    // Check whether data with expected MIME type arrived or not.
    if (response) {
        
        NSString *description = nil;
        if (![self.expectedMIMETtypes containsObject:[response MIMEType]]) {
            
            // Construct error description.
            description = [NSString stringWithFormat:@"Request completed but unexpected data type "
                           "received in response: %@", [response MIMEType]];
            statusCode = NSURLErrorCannotDecodeContentData;
        }
        else if (response.statusCode != 200) {
            
            // Construct error description.
            description = [NSString stringWithFormat:@"Request failed: %@ (%ld)",
                           [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode],
                           (long)response.statusCode];
            statusCode = NSURLErrorBadServerResponse;
        }
        
        if (description) {
            
            userInfo[NSLocalizedDescriptionKey] = description;
        }
    }
    
    if ([userInfo count]) {
        
        if ([response URL]) {
            
            userInfo[NSURLErrorFailingURLErrorKey] = [response URL];
        }
        if ([responseData length]) {
            
            userInfo[kPNNetworkErrorResponseDataKey] = responseData;
        }
        
        if (error) {
            
            *error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:userInfo];
        }
    }
    
    return (statusCode != NSURLErrorUnknown);
}

#pragma mark -


@end
