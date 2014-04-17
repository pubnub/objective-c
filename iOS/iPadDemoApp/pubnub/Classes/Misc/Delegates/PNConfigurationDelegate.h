//
//  PNConfigurationDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNConfiguration;


#pragma mark - Protocol declaration

@protocol PNConfigurationDelegate <NSObject>


@required

/**
 Called on configuration delegate to inform that configuration update completed.
 
 @return \b PNConfiguration with new / updated / same set of options which will be used for \b PubNub client configuration.
 */
- (void)configurationChangeDidComplete:(PNConfiguration *)updatedConfiguration;

#pragma mark -


@end
