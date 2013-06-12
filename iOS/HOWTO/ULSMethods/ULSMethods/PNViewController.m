//
//  PNViewController.m
//  ULSMethods
//
//  Created by geremy cohen on 06/07/13.
//  Copyright (c) 2013 PubNub. All rights reserved.
//

#import "PNViewController.h"

@interface PNViewController ()

@end

@implementation PNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setting Auth to "sergey" should work as expected
    // Setting to nil or "foo" should cause an access denied
    // Must use ULS test domain uls-test.pubnub.co (not com)




    // If ULS is on, and you dont try to connect with an auth key, you should t
    // error code 112 (401, auth requir)

//    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"uls-test.pubnub.co"
//                                                             publishKey:@"pub-c-a2650a22-deb1-44f5-aa87-1517049411d5"
//                                                           subscribeKey:@"sub-c-a478dd2a-c33d-11e2-883f-02ee2ddab7fe"
//                                                              secretKey:@"sec-c-YjFmNzYzMGMtYmI3NC00NzJkLTlkYzYtY2MwMzI4YTJhNDVh"
//                                                         authorizationKey:nil];


    // If ULS is on, and you dont try to connect with an auth key, you should get
    // error code 113 (403, auth incorrect)
    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"uls-test.pubnub.co"
                                                             publishKey:@"pub-c-a2650a22-deb1-44f5-aa87-1517049411d5"
                                                           subscribeKey:@"sub-c-a478dd2a-c33d-11e2-883f-02ee2ddab7fe"
                                                              secretKey:@"sec-c-YjFmNzYzMGMtYmI3NC00NzJkLTlkYzYtY2MwMzI4YTJhNDVh"
                                                       authorizationKey:@"geremy"];

    [PubNub setConfiguration:myConfig];

    [PubNub connect];
    [PubNub subscribeOnChannel:[PNChannel channelWithName:@"z"]];

//    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"uls-test.pubnub.co"
//                                                             publishKey:@"pub-c-a2650a22-deb1-44f5-aa87-1517049411d5"
//                                                           subscribeKey:@"sub-c-a478dd2a-c33d-11e2-883f-02ee2ddab7fe"
//                                                              secretKey:@"sec-c-YjFmNzYzMGMtYmI3NC00NzJkLTlkYzYtY2MwMzI4YTJhNDVh"
//                                                       authorizationKey:@"geremy"];

//    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"uls-test.pubnub.co"
//                                                             publishKey:@"pub-c-a2650a22-deb1-44f5-aa87-1517049411d5"
//                                                           subscribeKey:@"sub-c-a478dd2a-c33d-11e2-883f-02ee2ddab7fe"
//                                                              secretKey:@"sec-c-YjFmNzYzMGMtYmI3NC00NzJkLTlkYzYtY2MwMzI4YTJhNDVh"
//                                                       authorizationKey:nil];
//
    //
    // returns: s_7edda({"message":"Forbidden","payload":"z","service":"ULS","error":true})
    // ONLY consider "error":"true" in your logic
    // IGNORE "message", "payload", "service" attributes for now, they may deprecate

    // if response is a hash, and has an attribute called error, and "error":"true"
    // should send to didFailAuthorization delegate
    // Pass to this delegate:
    // - operation (publish, subscribe, history, time, hereNow, apnsAdd, etc)
    // - channel
    // - authkey
    // - timetoken
    // - URL request string which caused error

    // Within didFailAuthorization, I should be able to unsubscribe, sleep, set a new authKey, etc
    // If didFailAuthorization delegate does not exist, retry infinitely



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end