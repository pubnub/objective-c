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
    __unsafe_unretained NSString *channelGroup;
    __unsafe_unretained NSString *channelGroupNamespace;
    __unsafe_unretained NSString *user;
};

static struct PNAccessRightsSectionNamesStruct PNAccessRightsSectionNames = {
    .application = @"Application access rights",
    .channel = @"Channel(s) access rights",
    .channelGroup = @"Channel group(s) access rights",
    .channelGroupNamespace = @"Channel group namespace(s) access rights",
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
    
    NSArray *(^activeChannelsFilterBlock)(BOOL) = ^(BOOL onlyChannelGroups) {
        
        NSMutableArray *filteredChannels = [[PubNub subscribedObjectsList] mutableCopy];
        
        [[filteredChannels copy] enumerateObjectsUsingBlock:^(id<PNChannelProtocol> object, NSUInteger objectIdx,
                                                              BOOL *objectENumeratorStop) {
            
            BOOL isChannelGroup = object.isChannelGroup;
            if ((!isChannelGroup && onlyChannelGroups) || (isChannelGroup && !onlyChannelGroups)) {
                
                [filteredChannels removeObject:object];
            }
        }];
        
        return filteredChannels;
    };
    if (self.operationMode == PNAccessRightsHelperChannelMode) {
        
        self.existingData = [NSMutableArray arrayWithArray:activeChannelsFilterBlock(NO)];
    }
    else if (self.operationMode == PNAccessRightsHelperChannelGroupMode) {
        
        self.existingData = (NSMutableArray *)activeChannelsFilterBlock(YES);
    }
    else {
        
        self.existingData = [NSMutableArray array];
    }
    self.activeChannels = activeChannelsFilterBlock((self.operationMode == PNAccessRightsHelperChannelGroupMode) ||
                                                    (self.operationMode == PNAccessRightsHelperUserOnChannelGroupMode));
    self.userProvidedChannels = [NSMutableArray array];
    self.dataManipulation = [NSMutableArray array];
}

- (void)addObject:(id)object {
    
    if (![self willManipulateWith:object]) {
        
        [self.dataManipulation addObject:object];
    }
    
    if (![self.existingData containsObject:object]) {
        
        if (![self.userProvidedChannels containsObject:object] &&
            (self.operationMode == PNAccessRightsHelperChannelMode ||
             self.operationMode == PNAccessRightsHelperChannelGroupMode)) {
            
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
    if (self.operationMode != PNAccessRightsHelperChannelMode &&
        self.operationMode != PNAccessRightsHelperChannelGroupMode) {
        
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
        
        if (self.operationMode == PNAccessRightsHelperChannelMode ||
            self.operationMode == PNAccessRightsHelperChannelGroupMode) {
            
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
    id <PNChannelProtocol> object = nil;
    if (self.operationMode == PNAccessRightsHelperUserOnChannelMode) {
        
        object = [PNChannel channelWithName:self.channelName];
    }
    else if (self.operationMode == PNAccessRightsHelperUserOnChannelGroupMode){
        
        object = [PNChannelGroup channelGroupWithName:self.channelName];
    }
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
            case PNAccessRightsHelperChannelGroupMode:
                
                [PubNub auditAccessRightsFor:self.dataManipulation withCompletionHandlingBlock:requestHandlerBlock];
                break;
            case PNAccessRightsHelperUserOnChannelMode:
            case PNAccessRightsHelperUserOnChannelGroupMode:
                    
                [PubNub auditAccessRightsFor:object clients:self.dataManipulation
                 withCompletionHandlingBlock:requestHandlerBlock];
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
        
        NSInteger duration = self.accessRightsApplicationDuration;
        PNAccessRights rights = PNUnknownAccessRights;
        if (!self.isRevokingAccessRights &&
            (self.shouldAllowRead || self.shouldAllowWrite || self.shouldAllowManagement)) {
            
            if (self.shouldAllowRead) {
                
                rights |= PNReadAccessRight;
            }
            if (self.shouldAllowWrite) {
                
                rights |= PNWriteAccessRight;
            }
            if (self.shouldAllowManagement) {
                
                rights |= PNManagementRight;
            }
        }
        if (rights == PNUnknownAccessRights) {
            
            duration = 0;
            rights = PNNoAccessRights;
        }
        
        switch (self.operationMode) {
                
            case PNAccessRightsHelperApplicationMode:
                
                [PubNub changeApplicationAccessRightsTo:rights onPeriod:duration
                             andCompletionHandlingBlock:requestHandlerBlock];
                break;
            case PNAccessRightsHelperChannelMode:
            case PNAccessRightsHelperChannelGroupMode:

                [PubNub changeAccessRightsFor:self.dataManipulation to:rights onPeriod:duration
                  withCompletionHandlingBlock:requestHandlerBlock];
                break;
            case PNAccessRightsHelperUserOnChannelMode:
            case PNAccessRightsHelperUserOnChannelGroupMode:
                
                [PubNub changeAccessRightsForClients:self.dataManipulation object:object to:rights onPeriod:duration
                         withCompletionHandlingBlock:requestHandlerBlock];
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
        NSArray *channelGroupAccessRightsInformationList = [collection accessRightsInformationForAllChannelGroups];
        NSArray *channelGroupNamespaceAccessRightsInformationList = [collection accessRightsInformationForAllChannelGroupNamespaces];
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
            
            void(^appendSubTreeForDataStreamObjects)(NSString *, NSArray *) = ^(NSString *sectionName, NSArray *objects){
                
                NSMutableArray *sectionData = [NSMutableArray array];
                [objects enumerateObjectsUsingBlock:^(PNAccessRightsInformation *objectAccessRightsInformation,
                                                      NSUInteger objectAccessRightsInformationIdx,
                                                      BOOL *objectAccessRightsInformationEnumeratorStop) {
                    [sectionData addObject:@{
                                             PNAccessRightsDataKeys.entrieData: objectAccessRightsInformation,
                                             PNAccessRightsDataKeys.entrieShouldIndent: @(NO)
                                             }];
                    
                    NSArray *clientsForObject = [collection accessRightsForClientsOn:objectAccessRightsInformation.object];
                    [clientsForObject enumerateObjectsUsingBlock:^(PNAccessRightsInformation *clientAccessRightsInformation,
                                                                   NSUInteger clientAccessRightsInformationIdx,
                                                                   BOOL *clientAccessRightsInformationEnumeratorStop) {
                        [sectionData addObject:@{
                                                 PNAccessRightsDataKeys.entrieData: clientAccessRightsInformation,
                                                 PNAccessRightsDataKeys.entrieShouldIndent: @(YES)
                                                 }];
                    }];
                    
                }];
                
                [dataTree addObject:@{
                                      PNAccessRightsDataKeys.sectionName: sectionName,
                                      PNAccessRightsDataKeys.sectionData: sectionData
                                      }];
            };
            
            if ([channelAccessRightsInformationList count]) {
                
                appendSubTreeForDataStreamObjects(PNAccessRightsSectionNames.channel, channelAccessRightsInformationList);
            }
            
            if ([channelGroupAccessRightsInformationList count]) {
                
                appendSubTreeForDataStreamObjects(PNAccessRightsSectionNames.channelGroup, channelGroupAccessRightsInformationList);
            }
            
            if ([channelGroupNamespaceAccessRightsInformationList count]) {
                
                appendSubTreeForDataStreamObjects(PNAccessRightsSectionNames.channelGroupNamespace, channelGroupNamespaceAccessRightsInformationList);
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
