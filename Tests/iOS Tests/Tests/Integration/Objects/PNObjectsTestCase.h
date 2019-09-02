#import "PNTestCase.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Base test case for Object API integration tests.
 *
 * @discussion Class will perform initial setups (two \b PubNub clients) and provide set of useful
 * methods.
 *
 * @author Serhii Mamontov
 * @copyright © 2009-2019 PubNub, Inc.
 */
@interface PNObjectsTestCase : PNTestCase


#pragma mark - Information

/**
 * @brief Client which can be used to generate events.
 */
@property (nonatomic, readonly, strong) PubNub *client1;

/**
 * @brief Client which can be used to handle and verify actions of first client.
 */
@property (nonatomic, readonly, strong) PubNub *client2;

/**
 * @brief How many test \c users should be created for current test case.
 */
@property (nonatomic, assign) NSUInteger testUsersCount;

/**
 * @brief How many test \c spaces should be created for current test case.
 */
@property (nonatomic, assign) NSUInteger testSpacesCount;


#pragma mark - Objects helper

/**
 * @brief Subscribe and wait for completion for channels which is used by Object API to deliver
 * events.
 *
 * @param channels List of object channels on which observing \b PubNub client should be subscribed.
 */
- (void)subscribeOnObjectChannels:(NSArray<NSString *> *)channels;

/**
 * @brief Create configured number of test \c spaces.
 *
 * @return List of test users information (id, name and custom fields).
 */
- (NSArray<NSDictionary *> *)createTestSpaces;

/**
 * @brief Create configured number of test \c users.
 *
 * @return List of test users information (id, name and custom fields).
 */
- (NSArray<NSDictionary *> *)createTestUsers;

/**
 * @brief Create membership of \c users in passed \c spaces.
 *
 * @param users List of test users for which membership should be created.
 * @param spaces List of test spaces with which membership should be created.
 * @param customs List of dictionaries with \c custom data which should be set for membership.
 */
- (void)createUsersMembership:(NSArray<NSDictionary *> *)users
                     inSpaces:(NSArray<NSDictionary *> *)spaces
                  withCustoms:(nullable NSArray<NSDictionary *> *)customs;

/**
 * @brief Add members to passed \c spaces.
 *
 * @param members List of test users which should be added to \c spaces members list.
 * @param spaces List of test spaces for which members list should be modified.
 * @param customs List of dictionaries with \c custom data which should be associated with \c user
 * in \c space's members list.
 */
- (void)addMembers:(NSArray<NSDictionary *> *)members
          toSpaces:(NSArray<NSDictionary *> *)spaces
       withCustoms:(nullable NSArray<NSDictionary *> *)customs;
/**
 * @brief Remove all \c space objects which has been created so far.
 */
- (void)cleanUpSpaceObjects;

/**
 * @brief Remove all \c user objects which has been created so far.
 */
- (void)cleanUpUserObjects;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
