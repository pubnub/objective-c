//
//  CTKeySet.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTKeySet+Protected.h"


#pragma mark Structures

struct CTKeySetDataKeysStruct CTKeySetDataKeys = {
    
    .publishKey = @"pubKey",
    .subscribeKey = @"subKey",
    .secretKey = @"secKey",
    .descriptionKey = @"description"
};


#pragma mark - Public interface implementation

@implementation CTKeySet


#pragma mark - Class methods

/**
 Construct \b CTKeySet instance basing on dictionary and identifier for key.
 */
+ (CTKeySet *)keySetWithDictionary:(NSDictionary *)dictionary andIdentifier:(NSString *)identifier {
    
    return [self keySetWithSubscribeKey:[dictionary valueForKeyPath:CTKeySetDataKeys.subscribeKey]
                             publishKey:[dictionary valueForKeyPath:CTKeySetDataKeys.publishKey]
                              secretKey:[dictionary valueForKeyPath:CTKeySetDataKeys.secretKey]
                            description:[dictionary valueForKeyPath:CTKeySetDataKeys.descriptionKey]
                          andIdentifier:identifier];
}

+ (CTKeySet *)keySetWithSubscribeKey:(NSString *)subscribeKey publishKey:(NSString *)publishKey
                           secretKey:(NSString *)secretKey description:(NSString *)description
                       andIdentifier:(NSString *)keyIdentifier {
    
    return [[self alloc] initWithSubscribeKey:subscribeKey publishKey:publishKey secretKey:secretKey
                                  description:description andIdentifier:keyIdentifier];
}


#pragma mark - Instance methods

- (id)initWithSubscribeKey:(NSString *)subscribeKey publishKey:(NSString *)publishKey secretKey:(NSString *)secretKey
               description:(NSString *)description andIdentifier:(NSString *)keyIdentifier {
    
    // Check whether initializarion has been successful or not.
    if ((self = [super init])) {
        
        self.subscribeKey = subscribeKey;
        self.publishKey = publishKey;
        self.secretKey = secretKey;
        self.keyDescription = description;
        self.keyIdentifier = keyIdentifier;
    }
    
    
    return self;
}

#pragma mark -


@end
