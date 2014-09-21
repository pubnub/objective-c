//
//  PNAccessRightsHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNAccessRightsHelper.h"


#pragma mark Structures

struct PNAccessRightsDataKeysStruct PNAccessRightsDataKeys = {
    
    .sectionName = @"title",
    .sectionData = @"entries",
    .entrieData = @"data",
    .entrieShouldIndent = @"shouldIndent"
};

struct PNAccessRightsSectionNamesStruct {
    
    __unsafe_unretained NSString *application;
    __unsafe_unretained NSString *channel;
    __unsafe_unretained NSString *user;
};

static struct PNAccessRightsSectionNamesStruct PNAccessRightsSectionNames = {
    .application = @"Application access rights",
    .channel = @"Channel(s) access rights",
    .user = @"User(s) access rights"
};


#pragma mark - Private interface declaration

@interface PNAccessRightsHelper ()


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsHelperMode operationMode;
@property (nonatomic, assign, getter = isRevokingAccessRights) BOOL revokingAccessRights;
@property (nonatomic, assign, getter = isAuditingAccessRights) BOOL auditingAccessRights;

/**
 Property used during data addition by user for \c channel mode
 */
@property (nonatomic, strong) NSMutableArray *userProvidedChannels;

/**
 Stores reference on list of channels on which client subscribed at this moment.
 */
@property (nonatomic, strong) NSArray *activeChannels;

@property (nonatomic, strong) NSMutableArray *existingData;
@property (nonatomic, strong) NSMutableArray *dataManipulation;

/**
 Stores reference on access rights tree which has been built from server response.
 */
@property (nonatomic, strong) NSArray *accessRightsTree;

/**
 Stores reference on array which store data which has been provided by user (it can be list of channels or list of identifiers).
 */
@property (nonatomic, strong) NSMutableArray *userProvidedData;


#pragma mark - Instance methods

- (void)prepareData;


#pragma mark - Misc methods

- (void)buildDataTreeForCollection:(PNAccessRightsCollection *)collection;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNAccessRightsHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    [self prepareData];
}

- (void)prepareData {
    
    if (self.operationMode == PNAccessRightsHelperChannelMode) {
        
        self.existingData = [NSMutableArray arrayWithArray:[PubNub subscribedChannels]];
    }
    else {
        
        self.existingData = [NSMutableArray array];
    }
    self.activeChannels = [PubNub subscribedChannels];
    self.userProvidedChannels = [NSMutableArray array];
    self.dataManipulation = [NSMutableArray array];
}

- (void)addObject:(id)object {
    
    if (![self willManipulateWith:object]) {
        
        [self.dataManipulation addObject:object];
    }
    
    if (![self.existingData containsObject:object]) {
        
        if (![self.userProvidedChannels containsObject:object] && self.operationMode == PNAccessRightsHelperChannelMode) {
            
            [self.userProvidedChannels addObject:object];
        }
        
        [self.existingData addObject:object];
    }
}

- (void)removeObject:(id)object {
    
    if ([self.userProvidedChannels containsObject:object]) {
        
        [self.userProvidedChannels removeObject:object];
        [self.existingData removeObject:object];
    }
    if (self.operationMode != PNAccessRightsHelperChannelMode) {
        
        [self.existingData removeObject:object];
    }
    [self.dataManipulation removeObject:object];
}

- (void)configureForMode:(PNAccessRightsHelperMode)mode forAccessRightsAudition:(BOOL)shouldAuditAccessRights
    orAccessRightsRevoke:(BOOL)shouldRevokeAccessRights {
    
    self.operationMode = mode;
    self.auditingAccessRights = shouldAuditAccessRights;
    self.revokingAccessRights = shouldRevokeAccessRights;
    [self prepareData];
}

- (BOOL)isAbleToChangeAccessRights {
    
    BOOL isAbleToChangeAccessRights = self.operationMode == PNAccessRightsHelperApplicationMode;
    if (!isAbleToChangeAccessRights) {
        
        if (self.operationMode == PNAccessRightsHelperChannelMode) {
            
            isAbleToChangeAccessRights  = ([self.dataManipulation count] > 0);
        }
        else {
            
            isAbleToChangeAccessRights  = (self.channelName && ![self.channelName pn_isEmpty] && [self.dataManipulation count] > 0);
        }
    }
    
    
    return isAbleToChangeAccessRights;
}

- (void)performRequestWithBlock:(void(^)(NSError *))handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    if (self.isAuditingAccessRights) {
        
        PNClientChannelAccessRightsAuditBlock requestHandlerBlock = ^(PNAccessRightsCollection *collection, PNError *requestError) {
            
            [weakSelf buildDataTreeForCollection:collection];
            if (handlerBlock) {
                
                handlerBlock(requestError);
            }
        };
        
        switch (self.operationMode) {
            case PNAccessRightsHelperApplicationMode:
                
                [PubNub auditAccessRightsForApplicationWithCompletionHandlingBlock:requestHandlerBlock];
                break;
            case PNAccessRightsHelperChannelMode:
                
                [PubNub auditAccessRightsForChannels:self.dataManipulation withCompletionHandlingBlock:requestHandlerBlock];
                break;
            case PNAccessRightsHelperUserMode:
                
                [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:self.channelName]
                                            clients:self.dataManipulation withCompletionHandlingBlock:requestHandlerBlock];
                break;
                
            default:
                break;
        }
    }
    else {
        
        PNClientChannelAccessRightsChangeBlock requestHandlerBlock = ^(PNAccessRightsCollection *collection, PNError *requestError) {
            
            [weakSelf buildDataTreeForCollection:collection];
            if (handlerBlock) {
                
                handlerBlock(requestError);
            }
        };
        
        BOOL isAllAccessRights = self.shouldAllowRead && self.shouldAllowWrite;
        switch (self.operationMode) {
            case PNAccessRightsHelperApplicationMode:
                
                if (!self.isRevokingAccessRights && (self.shouldAllowRead || self.shouldAllowWrite)) {
                    
                    PNAccessRights rights = PNWriteAccessRight;
                    if (isAllAccessRights) {
                        
                        rights = PNAllAccessRights;
                    }
                    else if (self.shouldAllowRead) {
                        
                        rights = PNReadAccessRight;
                    }
                    
                    [PubNub changeApplicationAccessRightsTo:rights
                                                  forPeriod:self.accessRightsApplicationDuration
                                 andCompletionHandlingBlock:requestHandlerBlock];
                }
                else {
                    
                    [PubNub changeApplicationAccessRightsTo:PNNoAccessRights forPeriod:0
                                 andCompletionHandlingBlock:requestHandlerBlock];
                }
                break;
            case PNAccessRightsHelperChannelMode:
                
                if (!self.isRevokingAccessRights && (self.shouldAllowRead || self.shouldAllowWrite)) {
                    
                    PNAccessRights rights = PNWriteAccessRight;
                    if (isAllAccessRights) {
                        
                        rights = PNAllAccessRights;
                    }
                    else if (self.shouldAllowRead) {
                        
                        rights = PNReadAccessRight;
                    }
                    [PubNub changeAccessRightsForChannels:self.dataManipulation to:rights
                                                forPeriod:self.accessRightsApplicationDuration
                              withCompletionHandlingBlock:requestHandlerBlock];
                }
                else {
                    
                    [PubNub changeAccessRightsForChannels:self.dataManipulation to:PNNoAccessRights forPeriod:0
                              withCompletionHandlingBlock:requestHandlerBlock];
                }
                break;
            case PNAccessRightsHelperUserMode:
                
                if (!self.isRevokingAccessRights && (self.shouldAllowRead || self.shouldAllowWrite)) {
                    
                    PNAccessRights rights = PNWriteAccessRight;
                    if (isAllAccessRights) {
                        
                        rights = PNAllAccessRights;
                    }
                    else if (self.shouldAllowRead) {
                        
                        rights = PNReadAccessRight;
                    }
                    
                    [PubNub changeAccessRightsForClients:self.dataManipulation
                                               onChannel:[PNChannel channelWithName:self.channelName]
                                                      to:rights forPeriod:self.accessRightsApplicationDuration
                             withCompletionHandlingBlock:requestHandlerBlock];
                }
                else {
                    
                    [PubNub changeAccessRightsForClients:self.dataManipulation
                                               onChannel:[PNChannel channelWithName:self.channelName]
                                                      to:PNNoAccessRights forPeriod:self.accessRightsApplicationDuration
                             withCompletionHandlingBlock:requestHandlerBlock];
                }
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)willManipulateWith:(id)object {
    
    return [self.dataManipulation containsObject:object];
}

- (NSArray *)accessRights {
    
    return self.accessRightsTree;
}

- (NSArray *)userData {
    
    return self.existingData;
}

- (NSArray *)channels {
    
    return self.activeChannels;
}


#pragma mark - Misc methods

- (void)buildDataTreeForCollection:(PNAccessRightsCollection *)collection {
    
    if (collection) {
        
        
        NSMutableArray *dataTree = [NSMutableArray array];
        
        NSArray *channelAccessRightsInformationList = [collection accessRightsInformationForAllChannels];
        NSArray *usersAccessRightsInformation = [collection accessRightsInformationForAllClientAuthorizationKeys];
        if (collection.level == PNApplicationAccessRightsLevel) {
            
            [dataTree addObject:@{
                                  PNAccessRightsDataKeys.sectionName: PNAccessRightsSectionNames.application,
                                  PNAccessRightsDataKeys.sectionData: @[
                                          @{
                                              PNAccessRightsDataKeys.entrieData: [collection accessRightsInformationForApplication],
                                              PNAccessRightsDataKeys.entrieShouldIndent: @(NO)
                                              }
                                          ]
                                  }];
        }
        
        if (collection.level != PNUserAccessRightsLevel) {
            
            if ([channelAccessRightsInformationList count]) {
                
                NSMutableArray *sectionData = [NSMutableArray array];
                [channelAccessRightsInformationList enumerateObjectsUsingBlock:^(PNAccessRightsInformation *channelAccessRightsInformation,
                                                                                 NSUInteger channelAccessRightsInformationIdx,
                                                                                 BOOL *channelAccessRightsInformationEnumeratorStop) {
                    [sectionData addObject:@{
                                             PNAccessRightsDataKeys.entrieData: channelAccessRightsInformation,
                                             PNAccessRightsDataKeys.entrieShouldIndent: @(NO)
                                             }];
                    
                    NSArray *clientsForChannel = [collection accessRightsForClientsOnChannel:channelAccessRightsInformation.channel];
                    [clientsForChannel enumerateObjectsUsingBlock:^(PNAccessRightsInformation *clientAccessRightsInformation,
                                                                    NSUInteger clientAccessRightsInformationIdx,
                                                                    BOOL *clientAccessRightsInformationEnumeratorStop) {
                        [sectionData addObject:@{
                                                 PNAccessRightsDataKeys.entrieData: clientAccessRightsInformation,
                                                 PNAccessRightsDataKeys.entrieShouldIndent: @(YES)
                                                 }];
                    }];
                    
                }];
                [dataTree addObject:@{
                                      PNAccessRightsDataKeys.sectionName: PNAccessRightsSectionNames.channel,
                                      PNAccessRightsDataKeys.sectionData: sectionData
                                      }];
            }
        }
        else {
            
            NSMutableArray *sectionData = [NSMutableArray array];
            [usersAccessRightsInformation enumerateObjectsUsingBlock:^(PNAccessRightsInformation *clientAccessRightsInformation,
                                                                       NSUInteger clientAccessRightsInformationIdx,
                                                                       BOOL *clientAccessRightsInformationEnumeratorStop) {
                
                [sectionData addObject:@{
                                         PNAccessRightsDataKeys.entrieData: clientAccessRightsInformation,
                                         PNAccessRightsDataKeys.entrieShouldIndent: @(NO)
                                         }];
                
            }];
            [dataTree addObject:@{
                                  PNAccessRightsDataKeys.sectionName: PNAccessRightsSectionNames.user,
                                  PNAccessRightsDataKeys.sectionData: sectionData
                                  }];
        }
        
        self.accessRightsTree = dataTree;
    }
    else {
        
        self.accessRightsTree = nil;
    }
}

#pragma mark -


@end
