//
//  FTChangeSettings.m
//  PubNubTest
//
//  Created by Vadim Osovets on 5/8/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "FTChangeSettings.h"
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

@implementation FTChangeSettings {
    PubNub *_pubNub;
}


- (void)main {
    NSLog(@"%s", __FUNCTION__);
    
    
    GCDGroup *group = [GCDGroup group];
    
    [group enter];
    
    // Initialize PubNub client.
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    // Time
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
//        NSLog(@"Time: %@ (status: %@)", [result data], [status debugDescription]);
        
        [group leave];
    }];
    
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:10]) {
        NSLog(@"Timeout fired");
    }
    
    NSLog(@"Finished");
    [GCDWrapper sleepForSeconds:10];
}

@end
