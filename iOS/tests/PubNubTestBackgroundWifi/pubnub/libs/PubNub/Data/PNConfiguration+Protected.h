#import "PNConfiguration.h"


@interface PNConfiguration (Protected)


#pragma mark Instance methods

/**
 * Set whether configuration should provide DNS killing remote origin address or not
 */
- (BOOL)shouldKillDNSCache;
- (void)shouldKillDNSCache:(BOOL)shouldKillDNSCache;

/**
 * Check whether PubNub client should reset connection because new configuration instance changed critical
 * parts of configuration or not
 */
- (BOOL)requiresConnectionResetWithConfiguration:(PNConfiguration *)configuration;

/**
 * Check whether caller configuration is equal to the other or not
 */
- (BOOL)isEqual:(PNConfiguration *)configuration;

/**
 * Check whether configuration is valid or not
 */
- (BOOL)isValid;

#pragma mark -


@end