#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Category interface declaration

/**
 * @brief \c NSURLSessionConfiguration extension to provide limited \c NSURLSession configuration abilities for developers.
 *
 * @author Serhii Mamontov
 * @version 5.1.3
 * @since 4.4.0
 * @copyright © 2010-2022 PubNub, Inc.
 */
@interface NSURLSessionConfiguration (PNConfiguration)


#pragma mark - Configuration

/**
 * @brief Retrieve reference on previously configured set of custom HTTP headers.
 *
 * @note Dictionary won't include headers provided by \b PubNub client.
 *
 * @return Previously configured custom set of HTTP headers which should be sent along with every request to  \b PubNub service.
 */
+ (nullable NSDictionary<NSString *, id> *)pn_HTTPAdditionalHeaders;

/**
 * @brief Extend additional headers with custom values.
 *
 * @discussion Additional set of headers which is not used by \b PubNub service but can be used by intermediate 
 * tunneling software.
 *
 * @note Next set of fields will be ignored: Accept, Accept-Encoding, User-Agent and Connection.
 *
 * @param HTTPAdditionalHeaders Reference on custom set of HTTP headers which should be sent along with every  request to \b PubNub service.
 */
+ (void)pn_setHTTPAdditionalHeaders:(nullable NSDictionary<NSString *, id> *)HTTPAdditionalHeaders;

/**
 * @brief Retrieve previously configured configured network service type.
 *
 * @note \c NSURLNetworkServiceTypeDefault is set by default and will be returned if nothing changed.
 *
 * @return One of \c NSURLRequestNetworkServiceType enum fields which represent target network service type.
 */
+ (NSURLRequestNetworkServiceType)pn_networkServiceType;

/**
 * @brief Set target network service type.
 *
 * @param networkServiceType One of \c NSURLRequestNetworkServiceType enum fields which represent target network service type.
 */
+ (void)pn_setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType;

/**
 * @brief Retrieve whether previously has been set to use \c WiFi access \b only or \c cellular can be used as well.
 *
 * @return \c YES in case if cellular data can be used as well to access \b PubNub service.
 */
+ (BOOL)pn_allowsCellularAccess;

/**
 * @brief Set whether it is allowed to use cellular data to access \b PubNub service or not.
 *
 * @discussion \b Default: \b YES
 *
 * @param allowsCellularAccess Whether cellular data usage allowed to get access to \b PubNub service or not.
 */
+ (void)pn_setAllowsCellularAccess:(BOOL)allowsCellularAccess;

/**
 * @brief Extra set of protocols which will handle requests which is sent to \b PubNub service.
 *
 * @return Previously configured requests handling protocol classes.
 */
+ (nullable NSArray<Class> *)pn_protocolClasses;

/**
 * @brief Configure extra set of protocols which will handle requests which is sent to \b PubNub service.
 *
 * @warning Protocol classes which is prefixed with: \b NS or \b _NS will be ignored.
 *
 * @param protocolClasses Reference on requests handling protocol classes which should be used with requests to \b PubNub service.
 */
+ (void)pn_setProtocolClasses:(nullable NSArray<Class> *)protocolClasses;

/**
 * @brief Retrieve reference on previously configured connection proxy information.
 *
 * @return Previously configured connection proxy information which will be used by \c NSURLSession to open and send requests to \b PubNub service.
 */
+ (nullable NSDictionary<NSString *, id> *)pn_connectionProxyDictionary;

/**
 * @brief Configure connection proxy.
 *
 * @discussion This dictionary will be used by \c NSURLSession to open connection to \b PubNub service and send requests using it.
 *
 * @param connectionProxyDictionary Dictionary which contain information to setup proxy-based connectino.
 */
+ (void)pn_setConnectionProxyDictionary:(nullable NSDictionary<NSString *, id> *)connectionProxyDictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
