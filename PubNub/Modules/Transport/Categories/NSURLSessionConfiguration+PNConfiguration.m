/**
 * @author Serhii Mamontov
 * @version 5.1.3
 * @since 4.4.0
 * @copyright © 2010-2022 PubNub, Inc.
 */
#import "NSURLSessionConfiguration+PNConfigurationPrivate.h"
#if TARGET_OS_IOS || TARGET_OS_TV
    #import <UIKit/UIKit.h>
#elif TARGET_OS_WATCH
    #import <WatchKit/WatchKit.h>
#elif TARGET_OS_OSX
    #import <AppKit/AppKit.h>
#endif // TARGET_OS_OSX
#import "PNConstants.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface NSURLSessionConfiguration (PNConfigurationProtected)


#pragma mark - Misc

/**
 * @brief Queue to access shared configuration objects in safe way.
 *
 * @since 5.1.3
 *
 * @return Queue for resources access serializingion.
 */
+ (dispatch_queue_t)pn_resourceAccessQueue;

/**
 * @brief Retrieve reference on list of previously created configuration instances.
 *
 * @since 4.4.1
 *
 * @return Dictionary where each configuration mapped to it's identifier.
 */
+ (NSMutableDictionary<NSString *, NSURLSessionConfiguration *> *)pn_configurations;

/**
 * @brief  Set default values for session's configuration object.
 *
 * @since 4.5.4
 *
 * @param configuration Reference on created session configuration instance to which default settings should be applied.
 */
+ (void)pn_setDefaultValuesForSessionConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 * @brief Allow to filter up passed list of prtocol classes from names which can intersect with \c Apple's protocols.
 *
 * @param protocolClasses Srouce list of protocol classes which should be filtered.
 *
 * @return Filtered list of protocol classes or same list if there was no potentially dangerous protocol classes.
 */
+ (nullable NSArray<Class> *)pn_filteredProtocolClasses:(NSArray<Class> *)protocolClasses;

/**
 * @brief Allow to construct set of headers which should be used for network requests.
 *
 * @return Dictionary with headers which should be added to each request.
 */
+ (NSDictionary *)pn_defaultHeaders;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation NSURLSessionConfiguration (PNConfiguration)


#pragma mark - Initialization and Configuration

+ (instancetype)pn_ephemeralSessionConfigurationWithIdentifier:(NSString *)identifier {
    __block NSURLSessionConfiguration *configuration = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        NSMutableDictionary *configurations = [self pn_configurations];
        configuration = configurations[identifier];
        
        if (!configuration) {
            configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            [self pn_setDefaultValuesForSessionConfiguration:configuration];
            configurations[identifier] = configuration;
        }
    });
    
    return configuration;
}

+ (instancetype)pn_backgroundSessionConfigurationWithIdentifier:(NSString *)identifier {
    __block NSURLSessionConfiguration *configuration = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        SEL backgroundConfiguration = @selector(backgroundSessionConfigurationWithIdentifier:);
        NSMutableDictionary *configurations = [self pn_configurations];
        configuration = configurations[identifier];
        
        if (!configuration && [NSURLSessionConfiguration respondsToSelector:backgroundConfiguration]) {
            configuration = [NSURLSessionConfiguration performSelector:backgroundConfiguration
                                                            withObject:identifier];
            [self pn_setDefaultValuesForSessionConfiguration:configuration];
            configurations[identifier] = configuration;
        }
    });
    
    return configuration;
}

+ (NSDictionary<NSString *, id> *)pn_HTTPAdditionalHeaders {
    __block NSMutableDictionary *headers = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        NSURLSessionConfiguration *configuration = [self pn_configurations].allValues.firstObject;
        headers = [configuration.HTTPAdditionalHeaders mutableCopy];
        [headers removeObjectsForKeys:@[@"Accept", @"Accept-Encoding", @"User-Agent", @"Connection"]];
    });
    
    return headers.count ? headers : nil;
}

+ (void)pn_setHTTPAdditionalHeaders:(NSDictionary<NSString *, id> *)HTTPAdditionalHeaders {
    dispatch_async(self.pn_resourceAccessQueue, ^{
        NSArray<NSURLSessionConfiguration *> *configurations = [self pn_configurations].allValues;
        NSMutableDictionary *customHeaders = [HTTPAdditionalHeaders mutableCopy];
        [customHeaders removeObjectsForKeys:@[@"Accept", @"Accept-Encoding", @"User-Agent", @"Connection"]];
        
        // Compose resulting HTTP headers holder.
        NSMutableDictionary *headers = [[self pn_defaultHeaders] mutableCopy];
        [headers addEntriesFromDictionary:customHeaders];
        
        for (NSURLSessionConfiguration *configuration in configurations) {
            configuration.HTTPAdditionalHeaders = headers;
        }
    });
}

+ (NSURLRequestNetworkServiceType)pn_networkServiceType {
    __block NSURLSessionConfiguration *configuration = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        configuration = [self pn_configurations].allValues.firstObject;
    });
    
    return configuration.networkServiceType;
}

+ (void)pn_setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType {
    dispatch_async(self.pn_resourceAccessQueue, ^{
        for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
            configuration.networkServiceType = networkServiceType;
        }
    });
}

+ (BOOL)pn_allowsCellularAccess {
    __block NSURLSessionConfiguration *configuration = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        configuration = [self pn_configurations].allValues.firstObject;
    });
    
    return configuration.allowsCellularAccess;
}

+ (void)pn_setAllowsCellularAccess:(BOOL)allowsCellularAccess {
    dispatch_async(self.pn_resourceAccessQueue, ^{
        for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
            configuration.allowsCellularAccess = allowsCellularAccess;
        }
    });
}

+ (NSArray<Class> *)pn_protocolClasses {
    __block NSURLSessionConfiguration *configuration = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        configuration = [self pn_configurations].allValues.firstObject;
    });
    
    return [self pn_filteredProtocolClasses:configuration.protocolClasses];
}

+ (void)pn_setProtocolClasses:(NSArray<Class> *)protocolClasses {
    NSArray<Class> *registeredProtocols = [self pn_protocolClasses];
    
    dispatch_async(self.pn_resourceAccessQueue, ^{
        NSArray<NSURLSessionConfiguration *> *configurations = [self pn_configurations].allValues;
        NSArray<Class> *classes = configurations.firstObject.protocolClasses;
        
        // Append user-provided protocol classes to system-provided.
        NSMutableArray *currentProtocolClasses = [NSMutableArray arrayWithArray:classes];
        [currentProtocolClasses removeObjectsInArray:registeredProtocols];
        [currentProtocolClasses addObjectsFromArray:[self pn_filteredProtocolClasses:protocolClasses]];
        
        classes = [currentProtocolClasses copy];
        for (NSURLSessionConfiguration *configuration in configurations) {
            configuration.protocolClasses = classes;
        }
    });
}

+ (NSDictionary<NSString *, id> *)pn_connectionProxyDictionary {
    __block NSURLSessionConfiguration *configuration = nil;
    
    dispatch_sync(self.pn_resourceAccessQueue, ^{
        configuration = [self pn_configurations].allValues.firstObject;
    });
    
    return configuration.connectionProxyDictionary;
}

+ (void)pn_setConnectionProxyDictionary:(NSDictionary<NSString *, id> *)connectionProxyDictionary {
    dispatch_async(self.pn_resourceAccessQueue, ^{
        for (NSURLSessionConfiguration *configuration in [self pn_configurations].allValues) {
            configuration.connectionProxyDictionary = connectionProxyDictionary;
        }
    });
}


#pragma mark - Misc

+ (dispatch_queue_t)pn_resourceAccessQueue {
    static dispatch_queue_t _sharedSessionConfigurationsAccessQueue;
    static dispatch_once_t onceToken;
  
    dispatch_once(&onceToken, ^{
        _sharedSessionConfigurationsAccessQueue = dispatch_queue_create("com.pubnub.categories.session-configuration",
                                                                        DISPATCH_QUEUE_SERIAL);
    });
  
    return _sharedSessionConfigurationsAccessQueue;
}

+ (NSMutableDictionary<NSString *, NSURLSessionConfiguration *> *)pn_configurations {
    static NSMutableDictionary *_sharedSessionConfigurations;
    static dispatch_once_t onceToken;
  
    dispatch_once(&onceToken, ^{
        _sharedSessionConfigurations = [NSMutableDictionary new];
    });
    
    return _sharedSessionConfigurations;
}

+ (void)pn_setDefaultValuesForSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.URLCache = nil;
    configuration.HTTPAdditionalHeaders = [self pn_defaultHeaders];
}

+ (NSArray<Class> *)pn_filteredProtocolClasses:(NSArray<Class> *)protocolClasses {
    NSArray<Class> *protocols = (protocolClasses.count ? protocolClasses : nil);
  
    if (protocols.count) {
        NSMutableArray *filteredProtocols = [protocols mutableCopy];
        
        [protocols enumerateObjectsUsingBlock:^(Class protocolClass, NSUInteger protocolClassIdx, BOOL *stop) {
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
    static NSDictionary *defaultHeaders;
    static dispatch_once_t onceToken;
  
    dispatch_once(&onceToken, ^{
        NSDictionary *applicationInformation = [NSBundle mainBundle].infoDictionary;
        NSString *appVersion = applicationInformation[@"CFBundleVersion"];
        NSString *appName = applicationInformation[@"CFBundleName"] ?: applicationInformation[@"CFBundleDisplayName"];
        NSString *application = [NSString stringWithFormat:@"%@/%@", appName, appVersion];
        NSString *osName = [kPNClientName componentsSeparatedByString:@"-"].lastObject;
        NSString *osVersion = pn_operating_system_version();
        NSString *cpuArch = pn_cpu_architecture();
        NSString *deviceName = @"iPhone";
        
        if ([osName isEqual:@"macOS"]) {
          deviceName = @"Mac";
        } else if ([osName isEqual:@"tvOS"]) {
          deviceName = @"Apple TV";
        } else if ([osName isEqual:@"watchOS"]) {
          deviceName = @"Apple Watch";
        }
      
        NSString *platform = [NSString stringWithFormat:@"%@; %@ %@; %@", deviceName, osName, osVersion, cpuArch];
        NSString *sdkInformation = [@"PubNub-ObjC/" stringByAppendingString:kPNLibraryVersion];
        
        NSString *userAgent = [NSString stringWithFormat:@"%@ (%@) %@", application, platform, sdkInformation];
        defaultHeaders = @{@"Accept":@"*/*", @"Accept-Encoding":@"gzip,deflate", @"User-Agent":userAgent,
                           @"Connection":@"keep-alive"};
    });
    
    return defaultHeaders;
}

#pragma mark -


@end
