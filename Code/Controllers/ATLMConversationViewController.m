//
//  ATLMConversationViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Atlas/ATLParticipantPresenting.h>
#import "ATLMConversationViewController.h"
#import "ATLMConversationDetailViewController.h"
#import "ATLMMediaViewController.h"
#import "ATLMLocationViewController.h"
#import "ATLMUtilities.h"
#import "ATLMParticipantTableViewController.h"
#import "LYRIdentity+ATLParticipant.h"
#import <objc/runtime.h>
#import "ATLMCardCellPresentable.h"
#import "ATLMCardPresenting.h"
#import "ATLMCardResponder.h"
#import "ATLMCardResponse.h"
#import "ATLMCardResponseCollectionViewCell.h"
#import "Larry_Messenger-Swift.h"
#import "VTConferenceCollectionViewCell.h"

NSString *const VTMIMETypeConference = @"vt/conference";
NSString *const VTConferenceCollectionViewCellIdentifier = @"VTConferenceCollectionViewCell";

static NSDateFormatter *ATLMShortTimeFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMDayOfWeekDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEEE"; // Tuesday
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMRelativeDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMThisYearDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"E, MMM dd,"; // Sat, Nov 29,
    }
    return dateFormatter;
}

static NSDateFormatter *ATLMDefaultDateFormatter()
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd, yyyy,"; // Nov 29, 2013,
    }
    return dateFormatter;
}

typedef NS_ENUM(NSInteger, ATLMDateProximity) {
    ATLMDateProximityToday,
    ATLMDateProximityYesterday,
    ATLMDateProximityWeek,
    ATLMDateProximityYear,
    ATLMDateProximityOther,
};

static ATLMDateProximity ATLMProximityToDate(NSDate *date)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSCalendarUnit calendarUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:calendarUnits fromDate:date];
    NSDateComponents *todayComponents = [calendar components:calendarUnits fromDate:now];
    if (dateComponents.day == todayComponents.day &&
        dateComponents.month == todayComponents.month &&
        dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return ATLMDateProximityToday;
    }

    NSDateComponents *componentsToYesterday = [NSDateComponents new];
    componentsToYesterday.day = -1;
    NSDate *yesterday = [calendar dateByAddingComponents:componentsToYesterday toDate:now options:0];
    NSDateComponents *yesterdayComponents = [calendar components:calendarUnits fromDate:yesterday];
    if (dateComponents.day == yesterdayComponents.day &&
        dateComponents.month == yesterdayComponents.month &&
        dateComponents.year == yesterdayComponents.year &&
        dateComponents.era == yesterdayComponents.era) {
        return ATLMDateProximityYesterday;
    }

    if (dateComponents.weekOfMonth == todayComponents.weekOfMonth &&
        dateComponents.month == todayComponents.month &&
        dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return ATLMDateProximityWeek;
    }

    if (dateComponents.year == todayComponents.year &&
        dateComponents.era == todayComponents.era) {
        return ATLMDateProximityYear;
    }

    return ATLMDateProximityOther;
}

@interface ATLMConversationViewController () <ATLMConversationDetailViewControllerDelegate, ATLParticipantTableViewControllerDelegate>
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, Class<ATLMCardCellPesentable>> *factories;

- (nullable NSString *)cardCellFactoryReuseIdentifierForMesssage:(LYRMessage *)message;

@end

@implementation ATLMConversationViewController

NSString *const ATLMConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const ATLMDetailsButtonAccessibilityLabel = @"Details Button";
NSString *const ATLMDetailsButtonLabel = @"Details";

+ (instancetype)conversationViewControllerWithLayerController:(ATLMLayerController *)layerController
{
    NSAssert(layerController, @"Layer Controller cannot be nil");
    return [[self alloc] initWithLayerController:layerController];
}

- (instancetype)initWithLayerController:(ATLMLayerController *)layerController
{
    NSAssert(layerController, @"Layer Controller cannot be nil");
    self = [self initWithLayerClient:layerController.layerClient];
    if (self)  {
        _layerController = layerController;
        _larryController = [[ATLMLarryController alloc] initWithLayerClient:layerController.layerClient];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.accessibilityLabel = ATLMConversationViewControllerAccessibilityLabel;
    self.dataSource = self;
    self.delegate = self;
   
    if (self.conversation) {
        [self addDetailsButton];
    }
    
    NSMutableDictionary *factories = [NSMutableDictionary dictionary];
    
    // This will automatically register all the factories in the runtime.
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    if (NULL != classes) {
        for (unsigned int i = 0; i < count; i++) {
            Class clss = classes[i];
            if (class_conformsToProtocol(clss, @protocol(ATLMCardCellPesentable))) {
                NSString *identifier = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), NSStringFromClass(clss)];
                [self registerClass:[clss collectionViewCellClass] forMessageCellWithReuseIdentifier:identifier];
                [factories setObject:clss forKey:identifier];
            }
        }
        free(classes);
    }
    
    [self setFactories:factories];
    
    Class clss = [ATLMCardResponseCollectionViewCell class];
    [self registerClass:clss forMessageCellWithReuseIdentifier:NSStringFromClass(clss)];
    
    [self configureUserInterfaceAttributes];
    [self configureVoxeet];
    [self registerNotificationObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureTitle];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![self isMovingFromParentViewController]) {
        [self.view resignFirstResponder];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configuration methods

- (void)configureVoxeet
{
    [self.collectionView registerNib:[UINib nibWithNibName:VTConferenceCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:VTConferenceCollectionViewCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conferenceActionButtonTapped:) name:@"ConferenceActionButtonTapped" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conferenceDestroyed:) name:@"ConferenceDestroyedPush" object:nil];
}

#pragma mark - Accessors

- (void)setConversation:(LYRConversation *)conversation
{
    [super setConversation:conversation];
    [self configureTitle];
}

#pragma mark - ATLConversationViewControllerDelegate

/**
 Atlas - Informs the delegate of a successful message send. Atlas Messenger adds a `Details` button to the navigation bar if this is the first message sent within a new conversation.
 */
- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    [self addDetailsButton];
}

/**
 Atlas - Informs the delegate that a message failed to send. Atlas messeneger display an alert view to inform the user of the failure.
 */
- (void)conversationViewController:(ATLConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error;
{
    NSLog(@"Message Send Failed with Error: %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messaging Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

/**
 Atlas - Informs the delegate that a message was selected. Atlas messenger presents an `ATLImageViewController` if the message contains an image.
 */
- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    LYRMessagePart *messagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEG);
    if (messagePart) {
        [self presentMediaViewControllerWithMessage:message];
        return;
    }
    messagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImagePNG);
    if (messagePart) {
        [self presentMediaViewControllerWithMessage:message];
        return;
    }
    messagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageGIF);
    if (messagePart) {
        [self presentMediaViewControllerWithMessage:message];
        return;
    }
    messagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeVideoMP4);
    if (messagePart) {
        [self presentMediaViewControllerWithMessage:message];
        return;
    }
    
    messagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeLocation);
    if (messagePart) {
        [self presentLocationViewControllerWithMessage:message];
        return;
    }
}

- (CGFloat)conversationViewController:(ATLConversationViewController *)viewController heightForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth
{
    CGFloat result = 0.0;
    
    NSString *identifier = [self cardCellFactoryReuseIdentifierForMesssage:message];
    if (identifier != nil) {
        Class<ATLMCardCellPesentable> factory = [[self factories] objectForKey:identifier];
        result = [[factory collectionViewCellClass] cellSizeForMessage:message withCellWidth:cellWidth].height;
    }
    else {
        
        NSArray<LYRMessagePart *> *parts = [message parts];
        
        NSUInteger count = [parts count];
        LYRMessagePart *initial = [parts firstObject];
        parts = ((1 == count) ? nil : [parts subarrayWithRange:NSMakeRange(1, count - 1)]);
        ATLMCardResponse *response = [ATLMCardResponse cardResponseWithMessagePart:initial supplementalParts:parts];
        if (nil != response) {
            result = [ATLMCardResponseCollectionViewCell cellSizeForCardResponse:response
                                                             fromLayerController:[self layerController]
                                                                   withCellWidth:cellWidth].height;
        }
    }
    
    if (identifier == nil) {
        if ([message.parts.firstObject.MIMEType isEqualToString:VTMIMETypeConference]) {
            result = 193.0;
        }
    }
    return result;
}

- (void)conversationViewController:(ATLConversationViewController *)conversationViewController configureCell:(UICollectionViewCell<ATLMessagePresenting> *)cell forMessage:(LYRMessage *)message
{
    if ([cell isKindOfClass:[ATLBaseCollectionViewCell class]]) {
        
        ATLBaseCollectionViewCell *abcvc = (ATLBaseCollectionViewCell*)cell;
        
        BOOL isOutgoing = [self.layerClient.authenticatedUser.userID isEqualToString:message.sender.userID];
        [abcvc configureCellForType:(isOutgoing ? ATLOutgoingCellType : ATLIncomingCellType)];
        
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        abcvc.bubbleView.menuControllerActions = [NSArray arrayWithObjects:copyMenuItem, deleteMenuItem, nil];
    }
    
    if ([cell isKindOfClass:[VTConferenceCollectionViewCell class]]) {
        [self configureVoxeetConferenceCell:(VTConferenceCollectionViewCell *)cell forMessage:message];
    } else if ([cell conformsToProtocol:@protocol(ATLMCardResponder)] && [cell respondsToSelector:@selector(setLayerController:)]) {
        [(id<ATLMCardResponder>)cell setLayerController:[self layerController]];
    } else if ([cell isKindOfClass:[ATLMCardResponseCollectionViewCell class]]) {
        [(ATLMCardResponseCollectionViewCell*)cell setLayerController:[self layerController]];
    }
}

- (void)configureVoxeetConferenceCell:(VTConferenceCollectionViewCell *)cell forMessage:(LYRMessage *)message
{
    NSString *conferenceID = [self conferenceIDWithMessage:message];
    if (conferenceID) {
        cell.conferenceId = conferenceID;
        
        [VoxeetManager statusWithConferenceID:conferenceID success:^(id _Nonnull json) {
            if (json != nil) {
                NSDictionary *statusData = [self conferenceStatusDataFromRawData:json];
                NSNumber *isLive = [statusData objectForKey:@"isLive"];
                
                if (isLive.boolValue == true) {
                    [self updateVoxeetCell:cell withConferenceData:statusData];
                } else {
                    [VoxeetManager historyWithConferenceID:conferenceID success:^(id _Nonnull json) {
                        if (json != nil) {
                            NSDictionary *historyData = [self conferenceHistoryDataFromRawData:json[0]];
                            
                            [self updateVoxeetCell:cell withConferenceData:historyData];
                        }
                    }];
                }
            }
        }];
    }
}

- (void)updateVoxeetCell:(VTConferenceCollectionViewCell *)voxeetCell isLive:(BOOL)isLive
{
    [VoxeetManager statusWithConferenceID:voxeetCell.conferenceId success:^(id _Nonnull rawData) {
        NSDictionary *statusData = [self conferenceStatusDataFromRawData:rawData];
        [voxeetCell loadConferenceData:statusData];
    }];
}

- (void)updateVoxeetCell:(VTConferenceCollectionViewCell *)voxeetCell withConferenceData:(NSDictionary *)conferenceData
{
    [voxeetCell loadConferenceData:conferenceData];
    
    NSNumber *isLive = [conferenceData objectForKey:@"isLive"];
    if (isLive.boolValue == 1) {
        voxeetCell.bubbleView.menuControllerActions = nil;
    } else {
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        voxeetCell.bubbleView.menuControllerActions = [NSArray arrayWithObjects:deleteMenuItem, nil];
    }
}

- (void)presentLocationViewControllerWithMessage:(LYRMessage *)message
{
    ATLMLocationViewController *locationViewController = [[ATLMLocationViewController alloc] initWithMessage:message];
    [self showViewController:locationViewController sender:self];
    
    locationViewController.mapView.scrollEnabled = NO;
}

- (void)presentMediaViewControllerWithMessage:(LYRMessage *)message
{
    ATLMMediaViewController *imageViewController = [[ATLMMediaViewController alloc] initWithMessage:message];
    [self showViewController:imageViewController sender:self];
}

- (void)showViewController:(UIViewController *)viewController sender:(id)sender
{
    // If the `viewController` is a UINavigationController, present it.
    // Do not attempt to push a navigation controller
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [sender presentViewController:viewController animated:true completion:nil];
        return;
    }
    
    // If `self` is in a navigation controller, push viewController
    // Otherwise present it in a navigation controller
    if (self.navigationController != nil) {
        [self.navigationController pushViewController:viewController animated:true];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [sender presentViewController:navigationController animated:true completion:nil];
    }
}

- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectActionSheetCardType:(enum ATLMActionSheetCardType)cardType
{
    switch (cardType) {
        case ATLMActionSheetCardTypeVoxeet:
            [self sendVoxeetCard];
            break;
            
        default:
            break;
    }
}

#pragma mark - ATLConversationViewControllerDataSource

/**
 Atlas - Returns an object conforming to the `ATLParticipant` protocol whose `userID` property matches the supplied identity.
 */
- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentity:(nonnull LYRIdentity *)identity
{
    return identity;
}

/**
 Atlas - Returns an `NSAttributedString` object for a given date. The format of this string can be configured to whatever format an application wishes to display.
 */
- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter;
    ATLMDateProximity dateProximity = ATLMProximityToDate(date);
    switch (dateProximity) {
        case ATLMDateProximityToday:
        case ATLMDateProximityYesterday:
            dateFormatter = ATLMRelativeDateFormatter();
            break;
        case ATLMDateProximityWeek:
            dateFormatter = ATLMDayOfWeekDateFormatter();
            break;
        case ATLMDateProximityYear:
            dateFormatter = ATLMThisYearDateFormatter();
            break;
        case ATLMDateProximityOther:
            dateFormatter = ATLMDefaultDateFormatter();
            break;
    }

    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *timeString = [ATLMShortTimeFormatter() stringFromDate:date];
    
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", dateString, timeString]];
    [dateAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, dateAttributedString.length)];
    [dateAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, dateAttributedString.length)];
    [dateAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:11] range:NSMakeRange(0, dateString.length)];
    return dateAttributedString;
}

/**
 Atlas - Returns an `NSAttributedString` object for given recipient state. The state string will only be displayed below the latest message that was sent by the currently authenticated user.
 */
- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    NSMutableDictionary *mutableRecipientStatus = [recipientStatus mutableCopy];
    if ([mutableRecipientStatus valueForKey:self.layerClient.authenticatedUser.userID]) {
        [mutableRecipientStatus removeObjectForKey:self.layerClient.authenticatedUser.userID];
    }
    
    NSString *statusString = [NSString new];
    if (mutableRecipientStatus.count > 1) {
        __block NSUInteger readCount = 0;
        __block BOOL delivered = NO;
        __block BOOL sent = NO;
        __block BOOL pending = NO;
        [mutableRecipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
            LYRRecipientStatus status = statusNumber.integerValue;
            switch (status) {
                case LYRRecipientStatusInvalid:
                    break;
                case LYRRecipientStatusPending:
                    pending = YES;
                    break;
                case LYRRecipientStatusSent:
                    sent = YES;
                    break;
                case LYRRecipientStatusDelivered:
                    delivered = YES;
                    break;
                case LYRRecipientStatusRead:
                    readCount += 1;
                    break;
            }
        }];
        if (readCount) {
            NSString *participantString = readCount > 1 ? @"Participants" : @"Participant";
            statusString = [NSString stringWithFormat:@"Read by %lu %@", (unsigned long)readCount, participantString];
        } else if (pending) {
            statusString = @"Pending";
        }else if (delivered) {
            statusString = @"Delivered";
        } else if (sent) {
            statusString = @"Sent";
        }
    } else {
        __block NSString *blockStatusString = [NSString new];
        [mutableRecipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
            if ([userID isEqualToString:self.layerClient.authenticatedUser.userID]) return;
            LYRRecipientStatus status = statusNumber.integerValue;
            switch (status) {
                case LYRRecipientStatusInvalid:
                    blockStatusString = @"Not Sent";
                    break;
                case LYRRecipientStatusPending:
                    blockStatusString = @"Pending";
                    break;
                case LYRRecipientStatusSent:
                    blockStatusString = @"Sent";
                    break;
                case LYRRecipientStatusDelivered:
                    blockStatusString = @"Delivered";
                    break;
                case LYRRecipientStatusRead:
                    blockStatusString = @"Read";
                    break;
            }
        }];
        statusString = blockStatusString;
    }
    return [[NSAttributedString alloc] initWithString:statusString attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:11]}];
}

#pragma mark - ATLAddressBarControllerDelegate

/**
 Atlas - Informs the delegate that the user tapped the `addContacts` icon in the `ATLAddressBarViewController`. Atlas Messenger presents an `ATLParticipantPickerController`.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    NSSet *selectedParticipantIDs = [addressBarViewController.selectedParticipants valueForKey:@"userID"];
    if (selectedParticipantIDs) {
        query.predicate = [LYRPredicate predicateWithProperty:@"userID" predicateOperator:LYRPredicateOperatorIsNotIn value:selectedParticipantIDs];
    }
    
    NSError *error;
    NSOrderedSet *identities = [self.layerClient executeQuery:query error:&error];
    if (error) {
        ATLMAlertWithError(error);
    }
    
    ATLMParticipantTableViewController *controller = [ATLMParticipantTableViewController participantTableViewControllerWithParticipants:identities.set sortType:ATLParticipantPickerSortTypeFirstName];
    controller.blockedParticipantIdentifiers = [self.layerClient.policies valueForKey:@"sentByUserID"];
    controller.delegate = self;
    controller.allowsMultipleSelection = NO;
    
    [self showViewController:controller sender:self];
}

/**
 Atlas - Informs the delegate that the user is searching for participants. Atlas Messengers queries for participants whose `fullName` property contains the given search string.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *participants))completion
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"displayName" predicateOperator:LYRPredicateOperatorLike value:[searchText stringByAppendingString:@"%"]];
    [self.layerClient executeQuery:query completion:^(NSOrderedSet<id<ATLParticipant>> * _Nullable resultSet, NSError * _Nullable error) {
        if (resultSet) {
            completion(resultSet.array);
        } else {
            completion([NSArray array]);
        }
    }];
}

/**
 Atlas - Informs the delegate that the user tapped on the `ATLAddressBarViewController` while it was disabled. Atlas Messenger presents an `ATLConversationDetailViewController` in response.
 */
- (void)addressBarViewControllerDidSelectWhileDisabled:(ATLAddressBarViewController *)addressBarViewController
{
    [self detailsButtonTapped];
}

#pragma mark - ATLParticipantTableViewControllerDelegate

/**
 Atlas - Informs the delegate that the user selected an participant. Atlas Messenger in turn, informs the `ATLAddressBarViewController` of the selection.
 */
- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{
    [self.addressBarController selectParticipant:participant];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 Atlas - Informs the delegate that the user is searching for participants. Atlas Messengers queries for participants whose `fullName` property contains the give search string.
 */
- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    LYRPredicate *searchPredicate = [LYRPredicate predicateWithProperty:@"displayName" predicateOperator:LYRPredicateOperatorLike value:[NSString stringWithFormat:@"%%%@%%", searchText]];
    
    if (self.conversation.participants) {
        LYRPredicate *selectedPredicate = [LYRPredicate predicateWithProperty:@"userID" predicateOperator:LYRPredicateOperatorIsNotIn value:[self.conversation.participants valueForKey:@"userID"]];
        query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[ searchPredicate, selectedPredicate ]];
    } else {
        query.predicate = searchPredicate;
    }

    [self.layerClient executeQuery:query completion:^(NSOrderedSet<id<ATLParticipant>> * _Nullable resultSet, NSError * _Nullable error) {
        if (resultSet) {
            completion(resultSet.set);
        } else {
            completion([NSSet set]);
        }
    }];
}

#pragma mark - LSConversationDetailViewControllerDelegate

/**
 Atlas - Informs the delegate that the user has tapped the `Share My Current Location` button. Atlas Messenger sends a message into the current conversation with the current location.
 */
- (void)conversationDetailViewControllerDidSelectShareLocation:(ATLMConversationDetailViewController *)conversationDetailViewController
{
    [self sendLocationMessage];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 Atlas - Informs the delegate that the conversation has changed. Atlas Messenger updates its conversation and the current view controller's title in response.
 */
- (void)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation
{
    self.conversation = conversation;
    [self configureTitle];
}

#pragma mark - Larry Helper Methods

- (BOOL)isLarryConversation
{
    return [self.conversation.participants containsObject:self.larryController.larryIdentity];
}

- (NSString *)getLarryResponse:(NSString *)messageText
{
    NSAssert([self isLarryConversation], @"Cannot get a Larry response from outside the Larry conversation.");
    NSString *responseText;
    
    
    return responseText;
}

- (void)sendLarryMessage:(NSString *)messageText
{
    NSAssert([self isLarryConversation], @"Cannot send a message as Larry from outside the Larry conversation.");
}

#pragma mark - VoxeetConferenceKit Helpers

- (void)sendVoxeetCard
{
    [VoxeetManager createConferenceWithCompletion:^(NSString * _Nullable conferenceID) {
        if (conferenceID) {
            NSDictionary *confIdDict = [NSDictionary dictionaryWithObject:conferenceID forKey:@"confId"];
            NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:confIdDict];
            LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:VTMIMETypeConference data:messageData];
            
            LYRPushNotificationConfiguration *defaultConfiguration = [LYRPushNotificationConfiguration new];
            defaultConfiguration.alert = @"You have a call";
            defaultConfiguration.sound = @"layerbell.caf";
            defaultConfiguration.category = ATLUserNotificationDefaultActionsCategoryIdentifier;
            
            LYRMessageOptions *messageOptions = [LYRMessageOptions new];
            messageOptions.pushNotificationConfiguration = defaultConfiguration;
            
            LYRMessage *messageLayer = [self.layerClient newMessageWithParts:@[ messagePart ] options:messageOptions error:nil];
            
            NSError *error = nil;
            BOOL success = [self.conversation sendMessage:messageLayer error:&error];
            if (success) {
                NSLog(@"Message enqueued for delivery");
            } else {
                NSLog(@"Message send failed with error: %@", error);
            }
        }
    }];
}

- (void)conferenceActionButtonTapped:(NSNotification *)notification
{
    NSString *conferenceID = notification.userInfo[@"conferenceId"];
    NSString *actionText = notification.userInfo[@"actionText"];
    if (conferenceID && actionText) {
        if ([actionText isEqualToString:@"Join Call"]) {
            [self joinVoxeetConference:conferenceID];
        } else if ([actionText isEqualToString:@"Leave Call"]) {
            [self leaveVoxeetConference:conferenceID];
        } else if ([actionText isEqualToString:@"New Call"]) {
            [self sendVoxeetCard];
        }
    }
}

- (void)conferenceDestroyed:(NSNotification *)notification
{
    NSError *error;
    NSData *data = notification.userInfo[@"JSON"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSString *conferenceID = json[@"conferenceId"];
    if (conferenceID != nil) {
        NSLog(@"Voxeet call ended for conferenceID = %@", conferenceID);
        VTConferenceCollectionViewCell *cell = [self conferenceCellWithConferenceID:conferenceID];
        [self updateVoxeetCell:cell isLive:NO];
    }
}

- (void)joinVoxeetConference:(NSString *)conferenceID
{
    [VoxeetManager startConferenceWithConferenceID:conferenceID authenticatedUser:self.layerController.layerClient.authenticatedUser participants:self.conversation.participants success:^(id _Nonnull rawData) {
        VTConferenceCollectionViewCell *cell = [self conferenceCellWithConferenceID:conferenceID];
        NSDictionary *statusData = [self conferenceStatusDataFromRawData:rawData];
        [self updateVoxeetCell:cell withConferenceData:statusData];
    } fail:^(id _Nonnull error) {
        NSLog(@"Failed to start Voxeet conferenceID %@ with error: %@", conferenceID, error);
    }];
    VTConferenceCollectionViewCell *cell = [self conferenceCellWithConferenceID:conferenceID];
    [self updateVoxeetCell:cell isLive:YES];
}

- (void)leaveVoxeetConference:(NSString *)conferenceID
{
    [VoxeetManager stopConferenceWithConferenceID:conferenceID];
    VTConferenceCollectionViewCell *cell = [self conferenceCellWithConferenceID:conferenceID];
    [self updateVoxeetCell:cell isLive:NO];
}

- (NSString *)conferenceIDWithMessage:(LYRMessage *)message
{
    NSString *conferenceID;
    if ([message.parts.firstObject.MIMEType isEqualToString:VTMIMETypeConference]) {
        NSData *messageData = message.parts.firstObject.data;
        if (messageData) {
            NSDictionary *messageDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
            if (messageDictionary.allKeys.count > 0) {
                conferenceID = [messageDictionary objectForKey:@"confId"];
            }
        }
    }
    
    return conferenceID;
}

- (VTConferenceCollectionViewCell *)conferenceCellWithConferenceID:(NSString *)conferenceID
{
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[VTConferenceCollectionViewCell class]] && [((VTConferenceCollectionViewCell *)cell).conferenceId isEqualToString:conferenceID]) {
            return (VTConferenceCollectionViewCell *)cell;
        }
    }
    return nil;
}

- (NSDictionary *)conferenceStatusDataFromRawData:(NSDictionary *)rawData {
    NSMutableDictionary *conferenceData = [[NSMutableDictionary alloc]init];
    
    NSString *conferenceId = rawData[@"conferenceId"];
    [conferenceData setValue:conferenceId forKey:@"confId"];
    
    // Status message extraction
    NSNumber *isLive = [rawData objectForKey:@"isLive"];
    [conferenceData setValue:isLive forKey:@"isLive"];
    
    
    if (isLive != nil && [isLive intValue] == 1) {
        NSMutableArray *participantsArray = [[NSMutableArray alloc] init];
        [conferenceData setObject:participantsArray forKey:@"participants"];
        
        // Creation of 2 buffers dictionary for VoxeetId and currentStatus
        NSMutableDictionary *userStateBuffer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *userIdsBuffer = [[NSMutableDictionary alloc] init];
        NSArray *participants = [rawData objectForKey:@"participants"];
        if (participants != nil && participants.count > 0) {
            for (NSDictionary *part in participants) {
                NSString *userId = nil;
                NSDictionary *metaData = part[@"metadata"];
                if (metaData != nil) {
                    userId = [metaData objectForKey:@"AtlasId"];
                }
                NSString *voxeetId = part[@"userId"];
                if (userId != nil && voxeetId != nil) {
                    [userIdsBuffer setObject:voxeetId forKey:userId];
                }
                
                NSString *status = part[@"status"];
                
                if (userId != nil && status != nil) {
                    [userStateBuffer setObject:status forKey:userId];
                }
            }
        }
        
        // Creating a dictionary for each conference participant with buffered data
        for (LYRIdentity *lyrPart in self.conversation.participants) {
            NSString *status = userStateBuffer[lyrPart.userID];
            
            if (status == nil) {
                status = @"OUT";
            }
            
            NSString *voxeetId = userIdsBuffer[lyrPart.userID];
            
            NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
            [userDict setObject:lyrPart.userID forKey:@"id"];
            
            userDict[@"name"] = lyrPart.displayName;
            userDict[@"status"] = status;
            userDict[@"lyrUser"] = lyrPart;
            userDict[@"voxeetId"] = voxeetId;
            [participantsArray addObject:userDict];
            
            if ([lyrPart.userID isEqualToString:self.layerClient.authenticatedUser.userID]) {
                conferenceData[@"ownStatus"] = status;
            }
        }
        
        // Starting timestamp management
        NSNumber *startTimestamp = rawData[@"startTimestamp"];
        if (startTimestamp != nil) {
            NSNumber *secondsStart = [NSNumber numberWithDouble:[startTimestamp doubleValue] / 1000.0];
            [conferenceData setObject:secondsStart forKey:@"startTime"];
        }
    }
    return conferenceData;
}

- (NSDictionary *)conferenceHistoryDataFromRawData:(NSDictionary *)rawData
{
    NSMutableDictionary *conferenceData = [[NSMutableDictionary alloc]init];
    
    NSString *conferenceId = rawData[@"conferenceId"];
    [conferenceData setObject:conferenceId forKey:@"conferenceId"];
    
    NSNumber *startTime = rawData[@"conferenceTimestamp"];
    [conferenceData setObject:startTime forKey:@"startTime"];
    
    NSNumber *duration = rawData[@"conferenceDuration"];
    [conferenceData setObject:duration forKey:@"duration"];
    
    NSArray *participants = rawData[@"@participantIds"];
    if (participants != nil) {
        [conferenceData setObject:participants forKey:@"participants"];
    }
    
    NSNumber *isLive = [NSNumber numberWithInteger:0];
    [conferenceData setObject:isLive forKey:@"isLive"];
    
    return conferenceData;
}

#pragma mark - Details Button Actions

- (void)addDetailsButton
{
    if (self.navigationItem.rightBarButtonItem) return;

    UIBarButtonItem *detailsButtonItem = [[UIBarButtonItem alloc] initWithTitle:ATLMDetailsButtonLabel
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(detailsButtonTapped)];
    detailsButtonItem.accessibilityLabel = ATLMDetailsButtonAccessibilityLabel;
    self.navigationItem.rightBarButtonItem = detailsButtonItem;
}

- (void)detailsButtonTapped
{
    ATLMConversationDetailViewController *detailViewController = [ATLMConversationDetailViewController conversationDetailViewControllerWithConversation:self.conversation withLayerController:self.layerController];
    detailViewController.detailDelegate = self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Notification Handlers

- (void)layerClientObjectsDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (![self isLarryConversation]) return;
    
    NSArray *changes = notification.userInfo[LYRClientObjectChangesUserInfoKey];
    for (LYRObjectChange *change in changes) {
        if (change.type == LYRObjectChangeTypeCreate && [change.object isKindOfClass:[LYRMessage class]]) {
            LYRMessage *message = change.object;
            if (message.sender == self.layerController.layerClient.authenticatedUser) {
                NSString *messageText = [self getTextFromMessage:message];
                if (messageText) {
                    [self.larryController getResponseFromLarry:messageText completion:^(NSString * _Nonnull responseText, NSError * _Nonnull error) {
                        if (responseText) {
                            [self.larryController sendMessageAsLarry:responseText];
                        }
                    }];
                }
            }
        }
    }
}

- (void)conversationMetadataDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;

    [self configureTitle];
}

#pragma mark - Helpers

- (void)configureTitle
{
    if ([self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey]) {
        NSString *conversationTitle = [self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey];
        if (conversationTitle.length) {
            self.title = conversationTitle;
        } else {
            self.title = [self defaultTitle];
        }    } else {
        self.title = [self defaultTitle];
    }
}

- (NSString *)defaultTitle
{
    if (!self.conversation) {
        return @"New Message";
    }
    
    NSMutableSet *otherParticipants = [self.conversation.participants mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID != %@", self.layerClient.authenticatedUser.userID];
    [otherParticipants filterUsingPredicate:predicate];
    
    if (otherParticipants.count == 0) {
        return @"Personal";
    } else if (otherParticipants.count == 1) {
        LYRIdentity *otherIdentity = [otherParticipants anyObject];
        id<ATLParticipant> participant = [self conversationViewController:self participantForIdentity:otherIdentity];
        return participant ? participant.firstName : @"Message";
    } else if (otherParticipants.count > 1) {
        NSUInteger participantCount = 0;
        id<ATLParticipant> knownParticipant;
        for (LYRIdentity *identity in otherParticipants) {
            id<ATLParticipant> participant = [self conversationViewController:self participantForIdentity:identity];
            if (participant) {
                participantCount += 1;
                knownParticipant = participant;
            }
        }
        if (participantCount == 1) {
            return knownParticipant.firstName;
        } else if (participantCount > 1) {
            return @"Group";
        }
    }
    return @"Message";
}

- (NSString *)getTextFromMessage:(LYRMessage *)message
{
    NSString *messageText;
    
    return messageText;
}

- (nullable NSString *)conversationViewController:(ATLConversationViewController *)viewController reuseIdentifierForMessage:(LYRMessage *)message
{
    NSString *result = [self cardCellFactoryReuseIdentifierForMesssage:message];
    
    if (nil == result) {
        
        NSArray<LYRMessagePart *> *parts = [message parts];
        
        NSUInteger count = [parts count];
        LYRMessagePart *initial = [parts firstObject];
        parts = ((1 == count) ? nil : [parts subarrayWithRange:NSMakeRange(1, count - 1)]);
        ATLMCardResponse *response = [ATLMCardResponse cardResponseWithMessagePart:initial supplementalParts:parts];
        if (nil != response) {
            result = NSStringFromClass([ATLMCardResponseCollectionViewCell class]);
        }
    }
    
    if (result == nil) {
        if ([message.parts.firstObject.MIMEType isEqualToString:VTMIMETypeConference]) {
            result = VTConferenceCollectionViewCellIdentifier;
        }
    }
    
    return result;
}
    
- (nullable NSString *)cardCellFactoryReuseIdentifierForMesssage:(LYRMessage *)message
{
    NSDictionary<NSString *, Class<ATLMCardCellPesentable>> *factories = [self factories];
    for (NSString *key in factories) {
        Class<ATLMCardCellPesentable> factory = [factories objectForKey:key];
        if ([factory isSupportedMessage:message]) {
            return key;
        }
    }
    
    return nil;
}

#pragma mark - Link Tap Handler

- (void)userDidTapLink:(NSNotification *)notification
{
    [[UIApplication sharedApplication] openURL:notification.object];
}

- (void)configureUserInterfaceAttributes
{
    [[ATLIncomingMessageCollectionViewCell appearance] setBubbleViewColor:ATLLightGrayColor()];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blackColor]];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageLinkTextColor:ATLBlueColor()];
    
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:ATLBlueColor()];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageLinkTextColor:[UIColor whiteColor]];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTapLink:) name:ATLUserDidTapLinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationMetadataDidChange:) name:ATLMConversationMetadataDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerClientObjectsDidChange:) name:LYRClientObjectsDidChangeNotification object:nil];
}

#pragma mark - Device Orientation

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Message ActionItem Methods

- (void)deleteMessage:(id)sender
{
    if (![[sender class] isSubclassOfClass:[UIMenuController class]]) {
        return;
    }
    
    CGPoint point = [(UIMenuController *)sender menuFrame].origin;
    CGPoint offsetPoint = self.collectionView.contentOffset;
    CGPoint realPoint = CGPointMake(point.x + offsetPoint.x, point.y + offsetPoint.y + 64);
    NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:realPoint];
    if (!path) {
        return;
    }
    
    __block ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:path];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *globalAction = [UIAlertAction actionWithTitle:@"Everyone" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMessage:cell.message withMode:LYRDeletionModeAllParticipants];
    }];
    [controller addAction:globalAction];
    
    UIAlertAction *myDevicesAction = [UIAlertAction actionWithTitle:@"My Devices" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMessage:cell.message withMode:LYRDeletionModeMyDevices];
    }];
    [controller addAction:myDevicesAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)deleteMessage:(LYRMessage *)message withMode:(LYRDeletionMode)deletionMode
{
    NSError *error;
    BOOL success = [message delete:deletionMode error:&error];
    if (!success) {
        ATLMAlertWithError(error);
    } else {
        NSLog(@"Message deleted!");
    }
}

- (void)copyMessage:(id)sender
{
    if (![[sender class] isSubclassOfClass:[UIMenuController class]]) {
        return;
    }
    
    CGPoint point = [(UIMenuController *)sender menuFrame].origin;
    CGPoint offsetPoint = self.collectionView.contentOffset;
    CGPoint realPoint = CGPointMake(point.x + offsetPoint.x, point.y + offsetPoint.y + 64);
    NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:realPoint];
    if (!path) {
        return;
    }
    
    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:path];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (!cell.bubbleView.bubbleViewLabel.isHidden) {
        NSString *text = cell.bubbleView.bubbleViewLabel.text;
        if (!text) {
            return;
        }
        pasteboard.string = text;
    } else {
        NSData *imageData = UIImagePNGRepresentation(cell.bubbleView.bubbleImageView.image);
        [pasteboard setData:imageData forPasteboardType:ATLPasteboardImageKey];
    }
}

@end
