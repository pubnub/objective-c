//
//  CTKeysSet.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CTKeySet;


#pragma mark - Public interface declaration

@interface CTKeysSet : NSObject


#pragma mark - Class methods

/**
 Allow to fetch set of key sets which can be used by client from JSON file.
 
 @param jsonFilePath
 Full path to the file which stores array of key sets.
 */
+ (void)initWithJSONFileContent:(NSString *)jsonFilePath;

/**
 Allow to fetch from cache \b CTKeySet instance by it's identifier (if cache has been filled before).
 
 @param identifier
 \b NSString instance which has been assigned during instance creation.
 
 @return \b CTKeySet instance if it has been cached before or \c 'nil'.
 */
+ (CTKeySet *)keySetWithIdentifier:(NSString *)identifier;

#pragma mark -


@end
