/**
 @author Sergey Mamontov
 @since 4.4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "NSURLSessionConfiguration+PNConfigurationPrivate.h"
#if TARGET_OS_WATCH
    #import <WatchKit/WatchKit.h>
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <UIKit/UIKit.h>
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface NSURLSessionConfiguration (PNConfigurationProtected)


#pragma mark - Misc

/**
 @brief  Retrieve reference on list of previusly created configuration instances.
 
 @since 4.4.1
 
 @return Dictionary where each configuration mapped to it's identifier.
 */
+ (NSMutableDictionary<NSString *, NSURLSessionConfiguration *> *)pn_configurations;

/**
 @brief  Allow to filter up passed list of prtocol classes from names which can intersect with \c Apple's 
         protocols. 
 
 @since 4.4.0
 
 @param protocolClasses Srouce list of protocol classes which should be filtered.
 
 @return Filtered list of protocol classes or same list if there was no potentially dangerous protocol 
        classes.
 */
+ (nullable NSArray<Class> *)pn_filteredProtocolClasses:(NSArray<Class> *)protocolClasses;

/**
 @brief  Allow to construct set of headers which should be used for network requests.
 
 @return Dictionary with headers which should be added to each request.
 
 @since 4.4.0
 */
+ (NSDictionary *)pn_defaultHeaders;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation NSURLSessionConfiguration (PNConfiguration)


#pragma mark - Initialization and Configuration

+ (instancetype)pn_ephemeralSessionConfigurationWithIdentifier:(NSString *)identifier; {
    
    NSMutableDictionary *sessionConfigurations = [self pn_configurations];
    if (sessionConfigurations[identifier] == nil) {
        
        NSURLSessionConfiguration *sessionConfiguration;
        sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        sessionConfiguration.URLCache = nil;
        sessionConfiguration.HTTPAdditionalHeaders = [self pn_defaultHeaders];
        sessionConfigurations[identifier] = sessionConfiguration;
    }
    
    return sessionConfigurations[identifier];
}

+ (NSDictionary<NSString *, id> *)pn_HTTPAdditionalHeaders {
    
    NSURLSessionConfiguration *configuration = [self pn_configurations].allValues.firstObject;
    NSMutableDictionary *headers = [configuration.HTTPAdditionalHeaders mutableCopy];
    [headers removeObjectsForKeys:@[@"Accept", @"Accept-Encoding", @"User-Agent", @"Connection"]];
    
    return (headers.count ? headers : nil);
}

+ (void)pn_setHTTPAdditionalHeaders:(NSDictionary<NSString *, id> *)HTTPAdditionalHeaders {
    
    NSArray<NSURLSessionConfiguration *> *configurations = [self pn_configurations].allValues;
    NSMutableDictionary *customHeaders = [HTTPAdditionalHeaders mutableCopy];
    [customHeaders removeObjectsForKeys:@[@"Accept", @"Accept-Encoding", @"User-Agent", @"Connection"]];
    
    // Compose resulting HTTP headers holder.
    NSMutableDictionary *headers = [[self pn_defaultHeaders] mutableCopy];
    [headers addEntriesFromDictionary:customHeaders];
    
    for (NSURLSessionConfiguration *configuration in configurations) {

        configuration.HTTPAdditionalHeaders = headers;
    }
}

+ (NSURLRequestNetworkServiceType)pn_networkServiceType {
    
    NSURLSessionConfiguration *configuration = [self pn_configurations].allValues.firstObject;
    
    return configuration.networkServiceType;
}

+ (void)pn_setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType {
    
    for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
        
        configuration.networkServiceType = networkServiceType;
    }
}

+ (BOOL)pn_allowsCellularAccess {
    
    NSURLSessionConfiguration *configuration = [self pn_configurations].allValues.firstObject;
    
    return configuration.allowsCellularAccess;
}

+ (void)pn_setAllowsCellularAccess:(BOOL)allowsCellularAccess {
    
    for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
        
        configuration.allowsCellularAccess = allowsCellularAccess;
    }
}

+ (NSArray<Class> *)pn_protocolClasses {
    
    NSURLSessionConfiguration *configuration = [self pn_configurations].allValues.firstObject;
    
    return [self pn_filteredProtocolClasses:configuration.protocolClasses];
}

+ (void)pn_setProtocolClasses:(NSArray<Class> *)protocolClasses {
    
    NSArray<Class> *classes = [self pn_configurations].allValues.firstObject.protocolClasses;
    
    // Append user-provided protocol classes to system-provided.
    NSMutableArray *currentProtocolClasses = [NSMutableArray arrayWithArray:classes];
    [currentProtocolClasses removeObjectsInArray:[self pn_protocolClasses]];
    [currentProtocolClasses addObjectsFromArray:[self pn_filteredProtocolClasses:protocolClasses]];
    
    classes = [currentProtocolClasses copy];
    for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
        
        configuration.protocolClasses = classes;
    }
}

+ (NSDictionary<NSString *, id> *)pn_connectionProxyDictionary {
    
    NSURLSessionConfiguration *configuration = [self pn_configurations].allValues.firstObject;
    
    return configuration.connectionProxyDictionary;
}

+ (void)pn_setConnectionProxyDictionary:(NSDictionary<NSString *, id> *)connectionProxyDictionary {
    
    for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
        
        configuration.connectionProxyDictionary = connectionProxyDictionary;
    }
}


#pragma mark - Misc

+ (NSMutableDictionary<NSString *, NSURLSessionConfiguration *> *)pn_configurations {
    
    static NSMutableDictionary *_sharedSessionConfigurations;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedSessionConfigurations = [NSMutableDictionary new]; });
    
    return _sharedSessionConfigurations;
}

+ (NSArray<Class> *)pn_filteredProtocolClasses:(NSArray<Class> *)protocolClasses {
    
    NSArray<Class> *protocols = (protocolClasses.count ? protocolClasses : nil);
    if (protocols.count) {
        
        NSMutableArray *filteredProtocols = [protocols mutableCopy];
        [protocols enumerateObjectsUsingBlock:^(Class protocolClass, NSUInteger protocolClassIdx, BOOL *protocolClassesEnumeratorStop) {
            
            NSString *className = NSStringFromClass(protocolClass);
            if ([className hasPrefix:@"_NS"] || [className hasPrefix:@"NS"]) {
                
                [filteredProtocols removeObject:protocolClass];
            }
        }];
        protocols = [filteredProtocols copy];
    }
    
    return protocols;
}

+ (NSDictionary *)pn_defaultHeaders {
    
    NSString *device = @"iPhone";
#if TARGET_OS_WATCH
    NSString *osVersion = [[WKInterfaceDevice currentDevice] systemVersion];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo]operatingSystemVersion];
    NSMutableString *osVersion = [NSMutableString stringWithFormat:@"%@.%@",
                                  @(version.majorVersion), @(version.minorVersion)];
    if (version.patchVersion > 0) {
        
        [osVersion appendFormat:@".%@", @(version.patchVersion)];
    }
#endif
    NSString *userAgent = [NSString stringWithFormat:@"iPhone; CPU %@ OS %@ Version",
                           device, osVersion];
    
    return @{@"Accept":@"*/*", @"Accept-Encoding":@"gzip,deflate", @"User-Agent":userAgent,
             @"Connection":@"keep-alive"};
}

#pragma mark -


@end
