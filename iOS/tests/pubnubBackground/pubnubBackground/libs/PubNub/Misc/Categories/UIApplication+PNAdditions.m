//
//  UIApplication+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/4/13.
//
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIApplication+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub application category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface implementation

@implementation UIApplication (PNAdditions)


#pragma mark - Class methods

+ (BOOL)canRunInBackground {

    static BOOL canRunInBackground;
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{

        // Retrieve application information Property List
        NSDictionary *applicationInformation = [[NSBundle mainBundle] infoDictionary];

        if ([applicationInformation objectForKey:@"UIBackgroundModes"]) {

            NSArray *backgroundModes = [applicationInformation valueForKey:@"UIBackgroundModes"];
            NSArray *suitableModes = @[@"audio", @"location", @"voip", @"bluetooth-central", @"bluetooth-peripheral"];
            [backgroundModes enumerateObjectsUsingBlock:^(id mode, NSUInteger modeIdx, BOOL *modeEnumeratorStop) {

                canRunInBackground = [suitableModes containsObject:mode];
                *modeEnumeratorStop = canRunInBackground;
            }];
        }
    });


    return canRunInBackground;
}

#pragma mark -


@end
#endif
