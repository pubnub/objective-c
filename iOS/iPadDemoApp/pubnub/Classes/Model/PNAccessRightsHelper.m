//
//  PNAuditAccessRightsHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAccessRightsHelper.h"
#import "PNAccessRightsInformationCell.h"


#pragma mark Structures

struct PNAccessRightsDataKeysStruct {
    
    __unsafe_unretained NSString *sectionName;
    __unsafe_unretained NSString *sectionData;
    __unsafe_unretained NSString *entrieData;
    __unsafe_unretained NSString *entrieShouldIndent;
};

static struct PNAccessRightsDataKeysStruct PNAccessRightsDataKeys = {
    
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

@interface PNAccessRightsHelper () <UITableViewDelegate, UITableViewDataSource>


#pragma mark - Properties

@property (nonatomic, strong) PNAccessRightsCollection *collection;
@property (nonatomic, assign) PNAccessRightsLevel currentAccessRights;

@property (nonatomic, pn_desired_weak) IBOutlet UITableView *objectsTable;
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *accessRightsInformationTable;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableArray *objects;


#pragma mark - Misc methods

/**
 Analyze collection of access rights and build data tree based on them.
 */
- (void)buildDataTree;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNAccessRightsHelper


#pragma mark - Instance methods

- (void)updateWithAccessRightsCollectionInformation:(PNAccessRightsCollection *)collection {
    
    self.collection = collection;
    
    if (self.collection != nil) {
        
        [self buildDataTree];
    }
    else {
        
        self.data = nil;
        self.objects = nil;
    }
    
    [self.accessRightsInformationTable reloadData];
}

- (void)updateAccessRightsLevel:(PNAccessRightsLevel)accessRightsLevel {
    
    BOOL isAccessRightsLevelChanged = self.currentAccessRights != accessRightsLevel;
    self.currentAccessRights = accessRightsLevel;
    
    if (isAccessRightsLevelChanged) {
        
        if (accessRightsLevel == PNChannelAccessRightsLevel || accessRightsLevel == PNUserAccessRightsLevel) {
            
            self.objects = nil;
            self.data = nil;
            [self.objectsTable reloadData];
            [self.accessRightsInformationTable reloadData];
        }
        else {
            
            self.data = nil;
            [self.accessRightsInformationTable reloadData];
        }
    }
}

- (void)addTargetObject:(NSString *)targetObject {
    
    if (!self.objects) {
        
        self.objects = [NSMutableArray array];
    }
    
    [self.objects addObject:targetObject];
    [self.objectsTable reloadData];
}

- (NSArray *)targetObjects {
    
    return self.objects ? self.objects : @[];
}

- (void)removeTargetObject:(NSString *)targetObject {
    
    [self.objects removeObject:targetObject];
    [self.objectsTable reloadData];
}

- (BOOL)canSendRequest {
    
    BOOL canSendRequest = NO;
    switch (self.currentAccessRights) {
        case PNChannelAccessRightsLevel:
            
            canSendRequest = [self.objects count] > 0;
            break;
        case PNUserAccessRightsLevel:
            
            canSendRequest = [self.objects count] > 0 && [self.targetChannel length];
            break;
            
        default:
            
            canSendRequest = YES;
            break;
    }
    
    
    return canSendRequest;
}


#pragma mark - Misc methods

- (void)buildDataTree {
    
    NSMutableArray *dataTree = [NSMutableArray array];
    
    NSArray *channelAccessRightsInformationList = [self.collection accessRightsInformationForAllChannels];
    NSArray *usersAccessRightsInformation = [self.collection accessRightsInformationForAllClientAuthorizationKeys];
    if (self.collection.level == PNApplicationAccessRightsLevel) {
        
        [dataTree addObject:@{
                              PNAccessRightsDataKeys.sectionName: PNAccessRightsSectionNames.application,
                              PNAccessRightsDataKeys.sectionData: @[
                                      @{
                                        PNAccessRightsDataKeys.entrieData: [self.collection accessRightsInformationForApplication],
                                        PNAccessRightsDataKeys.entrieShouldIndent: @(NO)
                                       }
                                      ]
                              }];
    }
    if (self.collection.level != PNUserAccessRightsLevel) {
        
        if ([channelAccessRightsInformationList count]) {
            
            NSMutableArray *sectionData = [NSMutableArray array];
            [channelAccessRightsInformationList enumerateObjectsUsingBlock:^(PNAccessRightsInformation *channelAccessRightsInformation,
                                                                         NSUInteger channelAccessRightsInformationIdx,
                                                                         BOOL *channelAccessRightsInformationEnumeratorStop) {
                [sectionData addObject:@{
                                         PNAccessRightsDataKeys.entrieData: channelAccessRightsInformation,
                                         PNAccessRightsDataKeys.entrieShouldIndent: @(NO)
                                         }];
                
                NSArray *clientsForChannel = [self.collection accessRightsForClientsOnChannel:channelAccessRightsInformation.channel];
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
    
    self.data = dataTree;
}


#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [tableView isEqual:self.objectsTable] ? 1 : [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numberOfRows = [self.objects count];
    if ([tableView isEqual:self.accessRightsInformationTable]) {
        
        numberOfRows = [[[self.data objectAtIndex:section] valueForKey:PNAccessRightsDataKeys.sectionData] count];
    }
    
    
    return numberOfRows;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger indentationLevel = 0;
    if ([tableView isEqual:self.accessRightsInformationTable]) {
        
        NSDictionary *sectionData = [[[self.data objectAtIndex:indexPath.section] valueForKey:PNAccessRightsDataKeys.sectionData] objectAtIndex:indexPath.row];
        indentationLevel = [[sectionData valueForKey:PNAccessRightsDataKeys.entrieShouldIndent] boolValue] ? 3 : 0;
    }
    
    
    return indentationLevel;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [tableView isEqual:self.objectsTable] ? nil : [[self.data objectAtIndex:section] valueForKey:PNAccessRightsDataKeys.sectionName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    id cell = [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([tableView isEqual:self.accessRightsInformationTable]) {
        
        NSDictionary *data = [[[self.data objectAtIndex:indexPath.section] valueForKey:PNAccessRightsDataKeys.sectionData] objectAtIndex:indexPath.row];
        [(PNAccessRightsInformationCell *)cell updateWithAccessRightsInformation:data];
    }
    else {
        
        ((UITableViewCell *)cell).textLabel.text = [self.objects objectAtIndex:indexPath.row];
    }
    
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  ([tableView isEqual:self.accessRightsInformationTable]) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:self.objectsTable]) {
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            [self.objects removeObjectAtIndex:indexPath.row];
            [self.objectsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self.delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

#pragma mark -


@end
