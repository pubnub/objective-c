//
//  PNConfigurationView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "PNConfigurationDelegate.h"


#pragma mark - Public interface declaration

@interface PNConfigurationView : PNInputFormView


#pragma mark - Class methods

/**
 Retrieve reference on configuration view with predefined delegate.
 
 @param delegate
 Object which conform to \b PNConfigurationControllerDelegate protocol.
 
 @param configuration
 \b PNConfiguration instance which represent current client configuration.
 
 @return Configuration controller instance.
 */
+ (PNConfigurationView *)configurationViewWithDelegate:(id<PNConfigurationDelegate>)delegate
                                      andConfiguration:(PNConfiguration *)configuration;

#pragma mark -


@end
