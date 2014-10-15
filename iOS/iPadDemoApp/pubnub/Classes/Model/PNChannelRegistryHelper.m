//
//  PNChannelRegistryHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelRegistryHelper.h"
#import "NSString+PNAddition.h"


#pragma mark Private interface declaration

@interface PNChannelRegistryHelper ()


#pragma mark - Properties

/**
 @brief Reference on array which represent data received from \b PubNub service.
 */
@property (nonatomic, strong) NSArray *fetchedData;

/**
 @brief Reference on array which is used to store user generated content.
 */
@property (nonatomic, strong) NSMutableArray *dataForManipulation;


#pragma mark - Instance methods

- (void)prepareData;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChannelRegistryHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    [self prepareData];
}

- (void)prepareData {
    
    self.dataForManipulation = [NSMutableArray array];
}

- (BOOL)isAblePerformAuditRequest {
    
    BOOL isAblePerformAuditRequest = [self workingWithNamespace];
    if ([self workingWithChannelGroup]) {
        
        isAblePerformAuditRequest = (self.namespaceName && ![self.namespaceName pn_isEmpty]);
    }
    else if ([self workingWithChannelGroupChannels]) {
        
        isAblePerformAuditRequest = (self.channelGroupName && ![self.channelGroupName pn_isEmpty]);
    }
    
    
    return isAblePerformAuditRequest;
}

- (BOOL)isAblePerformModifyRequest {
    
    BOOL isAblePerformModifyRequest = NO;
    if (![self isObjectAudition]) {
        
        isAblePerformModifyRequest = [self workingWithNamespace];
        if (!isAblePerformModifyRequest && [self workingWithChannelGroup]) {
            
            isAblePerformModifyRequest = (self.channelGroupName && ![self.channelGroupName pn_isEmpty]);
        }
        if (!isAblePerformModifyRequest && [self workingWithChannelGroupChannels]) {
            
            isAblePerformModifyRequest = (self.channelGroupName && ![self.channelGroupName pn_isEmpty] &&
                                          [self.dataForManipulation count] > 0);
        }
    }
    
    
    return isAblePerformModifyRequest;
}

- (void)performDataFetchRequestWithBlock:(void(^)(NSError *))handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    if (self.operationMode == PNChannelRegistryHelperNamespaceAuditMode ||
        self.operationMode == PNChannelRegistryHelperNamespaceRemoveMode) {
        
        [[PubNub sharedInstance] requestChannelGroupNamespacesWithCompletionHandlingBlock:^(NSArray *namespaces,
                                                                                            PNError *requestError) {
            
            NSMutableArray *wrappedNamespaces = [NSMutableArray arrayWithCapacity:[namespaces count]];
            [namespaces enumerateObjectsUsingBlock:^(NSString *namespace, NSUInteger namespaceIdx,
                                                     BOOL *namespaceEnumeratorStop) {
                
                [wrappedNamespaces addObject:[PNChannelGroupNamespace namespaceWithName:namespace]];
            }];
            weakSelf.fetchedData = [wrappedNamespaces copy];
            
            if (handlerBlock) {
                
                handlerBlock(requestError);
            }
        }];
    }
    else if (self.operationMode == PNChannelRegistryHelperGroupAuditMode ||
             self.operationMode == PNChannelRegistryHelperGroupRemoveMode) {
        
        [[PubNub sharedInstance] requestChannelGroupsForNamespace:self.namespaceName
                                      withCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups,
                                                                    PNError *requestError) {
                                          
              weakSelf.fetchedData = [channelGroups copy];
              
              if (handlerBlock) {
                  
                  handlerBlock(requestError);
              }
          }];
    }
    else if (self.operationMode == PNChannelRegistryHelperGroupChannelsAuditMode ||
             self.operationMode == PNChannelRegistryHelperGroupChannelsRemoveMode) {
        
        PNChannelGroup *group = [PNChannelGroup channelGroupWithName:self.channelGroupName inNamespace:self.namespaceName];
        [[PubNub sharedInstance] requestChannelsForGroup:group
                             withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *requestError) {
                                 
             weakSelf.fetchedData = [channelGroup.channels copy];
             
             if (handlerBlock) {
                 
                 handlerBlock(requestError);
             }
         }];
    }
}

- (void)performDataModifyRequestWithBlock:(void(^)(NSError *))handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    if (self.operationMode == PNChannelRegistryHelperNamespaceRemoveMode) {
        
        [[PubNub sharedInstance] removeChannelGroupNamespace:self.namespaceName
                                 withCompletionHandlingBlock:^(NSString *namespaceName, PNError *requestError) {

             if (!requestError) {
                 
                 PNChannelGroupNamespace *namespaceObject = [PNChannelGroupNamespace namespaceWithName:namespaceName];
                 NSMutableArray *mutableFetchedData = [self.fetchedData mutableCopy];
                 [mutableFetchedData removeObject:namespaceObject];
                 weakSelf.fetchedData = [mutableFetchedData copy];
                 weakSelf.namespaceName = nil;
             }
             
             if (handlerBlock) {
                 
                 handlerBlock(requestError);
             }
         }];
    }
    else if (self.operationMode == PNChannelRegistryHelperGroupRemoveMode) {
        
        PNChannelGroup *group = [PNChannelGroup channelGroupWithName:self.channelGroupName inNamespace:self.namespaceName];
        [[PubNub sharedInstance] removeChannelGroup:group
                        withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *requestError) {
                            
            if (!requestError) {
                
                NSMutableArray *mutableFetchedData = [self.fetchedData mutableCopy];
                [mutableFetchedData removeObject:channelGroup];
                weakSelf.fetchedData = [mutableFetchedData copy];
                weakSelf.channelGroupName = nil;
            }
            
            if (handlerBlock) {
                
                handlerBlock(requestError);
            }
        }];
    }
    else if (self.operationMode == PNChannelRegistryHelperGroupChannelsAddMode ||
             self.operationMode == PNChannelRegistryHelperGroupChannelsRemoveMode) {
        
        PNChannelGroup *group = [PNChannelGroup channelGroupWithName:self.channelGroupName inNamespace:self.namespaceName];
        void(^responseProcessingBlock)(NSArray *, PNError *) = ^(NSArray *channels, PNError *requestError) {
            
            if (!requestError) {
                
                [weakSelf.dataForManipulation removeObjectsInArray:channels];
            }
            
            if (handlerBlock) {
                
                handlerBlock(requestError);
            }
        };
        if (self.operationMode == PNChannelRegistryHelperGroupChannelsAddMode) {
            
            [[PubNub sharedInstance] addChannels:self.dataForManipulation toGroup:group
                     withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels,
                                                   PNError *requestError) {
                         
                 responseProcessingBlock(channels, requestError);
             }];
        }
        else {
            
            [[PubNub sharedInstance] removeChannels:self.dataForManipulation fromGroup:group
                        withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels,
                                                      PNError *requestError) {
                            
                responseProcessingBlock(channels, requestError);
            }];
        }
    }
}

- (BOOL)isObjectRemove {
    
    return (self.operationMode == PNChannelRegistryHelperNamespaceRemoveMode ||
            self.operationMode == PNChannelRegistryHelperGroupRemoveMode ||
            self.operationMode == PNChannelRegistryHelperGroupChannelsRemoveMode);
}

- (BOOL)isObjectAudition {
    
    return (self.operationMode == PNChannelRegistryHelperNamespaceAuditMode ||
            self.operationMode == PNChannelRegistryHelperGroupAuditMode ||
            self.operationMode == PNChannelRegistryHelperGroupChannelsAuditMode);
}

- (BOOL)workingWithNamespace {
    
    return (self.operationMode == PNChannelRegistryHelperNamespaceRemoveMode ||
            self.operationMode == PNChannelRegistryHelperNamespaceAuditMode);
}

- (BOOL)workingWithChannelGroup {
    
    return (self.operationMode == PNChannelRegistryHelperGroupAuditMode ||
            self.operationMode == PNChannelRegistryHelperGroupRemoveMode);
}

- (BOOL)workingWithChannelGroupChannels {
    
    return (self.operationMode == PNChannelRegistryHelperGroupChannelsAddMode ||
            self.operationMode == PNChannelRegistryHelperGroupChannelsRemoveMode ||
            self.operationMode == PNChannelRegistryHelperGroupChannelsAuditMode);
}

- (void)addObject:(id<PNChannelProtocol>)object {
    
    if (![self willManipulateWith:object]) {
        
        [self.dataForManipulation addObject:object];
    }
}

- (void)removeObject:(id<PNChannelProtocol>)object {
    
    [self.dataForManipulation removeObject:object];
}

- (BOOL)willManipulateWith:(id<PNChannelProtocol>)object {
    
    return [self.dataForManipulation containsObject:object];
}

- (NSArray *)representationData {
    
    return ([self isObjectAudition] || [self isObjectRemove] ? self.fetchedData : self.dataForManipulation);
}

#pragma mark -


@end
