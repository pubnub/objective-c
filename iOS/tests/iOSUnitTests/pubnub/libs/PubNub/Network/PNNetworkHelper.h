@interface PNNetworkHelper : NSObject


#pragma mark - Class methods

#pragma mark - General methods

/**
 * Retrieve current device IP address (return 'nil' if device is not connected or didn't received IP address yet)
 */
+ (NSString *)networkAddress;

/**
 * Retrieve reference on URL which should be used to ensure that origin lookup is possible
 */
+ (NSString *)originLookupResourcePath;


#pragma mark - WLAN information methods

/**
 * Fetch specific WLAN information
 */
+ (NSString *)WLANBasicServiceSetIdentifier;
+ (NSString *)WLANServiceSetIdentifier;

#pragma mark -


@end