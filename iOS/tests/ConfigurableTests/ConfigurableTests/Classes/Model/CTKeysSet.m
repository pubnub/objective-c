//
//  CTKeysSet.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTKeysSet.h"
#import "CTKeySet+Protected.h"


#pragma mark Private interface declaration

@interface CTKeysSet ()


#pragma mark - Class methods

/**
 Allow to fetch cached keys.
 
 @return \b NSArray of \b CTKeySet instances.
 */
+ (NSMutableArray *)keys;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation CTKeysSet


#pragma mark - Class methods

+ (void)initWithJSONFileContent:(NSString *)jsonFilePath {
    
    NSData *keysSetData = [NSData dataWithContentsOfFile:jsonFilePath];
    if (keysSetData) {
        
        NSError *parsingError;
        NSDictionary *keysSet = [NSJSONSerialization JSONObjectWithData:keysSetData options:NSJSONReadingAllowFragments
                                                                  error:&parsingError];
        if (!parsingError) {
            
            [keysSet enumerateKeysAndObjectsUsingBlock:^(NSString *keySetIdentifier, NSDictionary *keySetData, BOOL *keySetEnumeratorStop) {
                
                if (![self keySetWithIdentifier:keySetIdentifier]) {
                    
                    [[self keys] addObject:[CTKeySet keySetWithDictionary:keySetData andIdentifier:keySetIdentifier]];
                }
            }];
        }
        else {
            
            @throw [NSException exceptionWithName:@"Can't load keys set." reason:@"Keys set JSON malformed." userInfo:nil];
        }
    }
}

+ (CTKeySet *)keySetWithIdentifier:(NSString *)identifier {
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self.keyIdentifier == %@", identifier];
    NSArray *filteredKeySet = [[self keys] filteredArrayUsingPredicate:searchPredicate];
    
    
    return [filteredKeySet count] ? [filteredKeySet lastObject] : nil;
}

+ (NSMutableArray *)keys {
    
    static NSMutableArray *_keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _keys = [NSMutableArray array];
    });
    
    
    return _keys;
}

#pragma mark -


@end
