//
//  PNDemoAppStructures.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#ifndef pubnub_PNDemoAppStructures_h
#define pubnub_PNDemoAppStructures_h

/**
 Represent navigation items structure keys.
 */
struct PNNavigationTreeStructureKeysStruct {
    
    /**
     Stores name of the key under which button title is stored.
     */
    __unsafe_unretained NSString *buttonTitle;
    
    /**
     Stores name of the key under which sub-tree items is stored.
     */
    __unsafe_unretained NSString *subItems;
    
    /**
     Stores name of the key under which name of selector is stored.
     This selector will be called on target.
     */
    __unsafe_unretained NSString *buttonAction;
};

extern struct PNNavigationTreeStructureKeysStruct PNNavigationTreeStructureKeys;

#endif // pubnub_PNDemoAppStructures_h
