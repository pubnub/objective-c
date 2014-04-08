//
//  NSString+PNLocalization.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface NSString (PNLocalization)


#pragma mark - Instance methods

/**
 Search for localization for receiver.
 
 @return Loclized string from Localizable.strings file or receiver itself.
 */
- (NSString *)localized;

#pragma mark -


@end
