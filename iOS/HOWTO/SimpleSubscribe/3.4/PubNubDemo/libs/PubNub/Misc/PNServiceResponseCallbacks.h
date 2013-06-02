//
//  PNServiceResponseCallbacks.h
//  pubnub
//
//  This header file stores keys which are
//  used to callback function names in service
//  response
//  
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#ifndef PNServiceResponseCallbacks_h
#define PNServiceResponseCallbacks_h


struct PNServiceResponseCallbacksStruct {
    
    // Name of the function which is used to
    // retrieve message which is used by
    // network profiler for latency calculation
    __unsafe_unretained NSString *latencyMeasureMessageCallback;
    // Name of the function which is used for
    // subscription and presence events for
    // set/single channel(s)
    __unsafe_unretained NSString *subscriptionCallback;
    
    // Name of the function which is used to
    // leave specified channel(s)
    __unsafe_unretained NSString *leaveChannelCallback;
    
    // Name of the function which is used to
    // mark response which tells client about
    // sent message processing result
    __unsafe_unretained NSString *sendMessageCallback;
    
    // Name of the function which is used to
    // retrieve current time token from
    // PubNub service
    __unsafe_unretained NSString *timeTokenCallback;

    // Name of the function which is used to
    // retrieve channel history
    __unsafe_unretained NSString *messageHistoryCallback;

    // Name of the function which is used to
    // retrieve channel participants
    __unsafe_unretained NSString *channelParticipantsCallback;

    // Name of the function which is used to
    // return APNSAdd response
    __unsafe_unretained NSString *apnsAddCallback;

    // Name of the function which is used to
    // return APNSRemoveOne response
    __unsafe_unretained NSString *apnsRemoveOneCallback;

    // Name of the function which is used to
    // return APNSRemoveAll response
    __unsafe_unretained NSString *apnsRemoveAllCallback;

    // Name of the function which is used to
    // return APNSListActive response
    __unsafe_unretained NSString *apnsListActiveCallback;



};

extern struct PNServiceResponseCallbacksStruct PNServiceResponseCallbacks;

#endif // PNServiceResponseCallbacks_h
