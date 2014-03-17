//
//  CTKeySet+Protected.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTKeySet.h"


#pragma mark Structures

struct CTKeySetDataKeysStruct {
    
    /**
     Stores reference on key name under which correct publish key is stored.
     */
    __unsafe_unretained NSString *publishKey;
    
    /**
     Stores reference on key name under which correct subscribe key is stored.
     */
    __unsafe_unretained NSString *subscribeKey;
    
    /**
     Stores reference on key name under which correct secret key is stored.
     */
    __unsafe_unretained NSString *secretKey;
    
    /**
     Stores reference on key name under which correct description key is stored.
     */
    __unsafe_unretained NSString *descriptionKey;
};

extern struct CTKeySetDataKeysStruct CTKeySetDataKeys;


#pragma mark - Private interface declaration

@interface CTKeySet ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscribeKey;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *keyDescription;
@property (nonatomic, copy) NSString *keyIdentifier;


#pragma mark - Class methods

/**
 Construct \b CTKeySet instance basing on dictionary and identifier for key.
 */
+ (CTKeySet *)keySetWithDictionary:(NSDictionary *)dictionary andIdentifier:(NSString *)identifier;

/**
 Construct \b CTKeySet instance using provided values.
 
 @param subscribeKey
 Subscribe key which will be passed to \b PubNub client for message retrieval mission.
 
 @param publishKey
 Publish key which will be passed to \b PubNub client for message sending mission.
 
 @param secretKey
 Secret key which will be passed to \b PubNub client and used with access rights manipulation API.
 
 @param description
 Destription which can be shown in interface (if required).
 
 @param keyIdentifier
 Unique \b NSString instance which identofy exact key set.
 
 @return Fully configured \b CTKeySet which can be used for \b PubNub client configuration.
 */
+ (CTKeySet *)keySetWithSubscribeKey:(NSString *)subscribeKey publishKey:(NSString *)publishKey
                           secretKey:(NSString *)secretKey description:(NSString *)description
                       andIdentifier:(NSString *)keyIdentifier;


#pragma mark - Instance methods

/**
 Initialize \b CTKeySet instance using provided values.
 
 @param subscribeKey
 Subscribe key which will be passed to \b PubNub client for message retrieval mission.
 
 @param publishKey
 Publish key which will be passed to \b PubNub client for message sending mission.
 
 @param secretKey
 Secret key which will be passed to \b PubNub client and used with access rights manipulation API.
 
 @param description
 Destription which can be shown in interface (if required).
 
 @param keyIdentifier
 Unique \b NSString instance which identofy exact key set.
 
 @return Fully configured \b CTKeySet which can be used for \b PubNub client configuration.
 */
- (id)initWithSubscribeKey:(NSString *)subscribeKey publishKey:(NSString *)publishKey secretKey:(NSString *)secretKey
               description:(NSString *)description andIdentifier:(NSString *)keyIdentifier;

#pragma mark -


@end
