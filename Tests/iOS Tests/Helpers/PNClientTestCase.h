//
//  PNClientTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/20/16.
//
//

#import <BeKindRewind/BeKindRewind.h>
#import <PubNub/PubNub.h>
#import "PNTestConstants.h"

@interface PNClientTestCase : BKRTestCase

@property (nonatomic, strong, readonly) PNConfiguration *configuration;
@property (nonatomic, strong, readonly) PubNub *client;

- (PNConfiguration *)clientConfiguration;

- (void)waitFor:(NSTimeInterval)timeout;



@end
