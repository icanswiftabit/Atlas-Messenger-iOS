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
#import "ATLConversationDataSource.h"
#import "HONMessagingUtilities.h"
#import "HONConstants.h"
#import "HONTerminalStatusCollectionViewCell.h"
#import "HONWeeklyReportCollectionViewCell.h"
#import "SafariServices/SafariServices.h"
@import QuickLook;

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

@interface ATLMConversationViewController () <ATLMConversationDetailViewControllerDelegate, ATLParticipantTableViewControllerDelegate, HONWeeklyReportCollectionViewCellDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource, SFSafariViewControllerDelegate>

@property (nonatomic) ATLConversationDataSource *conversationDataSource;

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
    
    [self configureUserInterfaceAttributes];
    [self registerNotificationObservers];
    [self registerCustomCellClasses];
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
    
    messagePart = ATLMessagePartForMIMEType(message, HONMIMETypeTerminalStatus);
    if (messagePart) {
        NSString *urlString = [self urlStringFromTerminalStatusMessagePart:messagePart];
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            [self presentWebViewControllerWithURL:url];
        }
        return;
    }
    
    messagePart = ATLMessagePartForMIMEType(message, HONMIMETypeTerminalReport);
    if (messagePart) {
        NSString *urlString = [self urlStringFromTerminalReportMessagePart:messagePart];
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            [self presentWebViewControllerWithURL:url];
        }
        return;
    }
}

- (void)presentWebViewControllerWithURL:(NSURL *)url
{
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    safariViewController.delegate = self;
    [self.navigationController pushViewController:safariViewController animated:YES];
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
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [sender presentViewController:navigationController animated:true completion:nil];
}

- (void)conversationViewController:(ATLConversationViewController *)conversationViewController configureCell:(UICollectionViewCell<ATLMessagePresenting> *)cell forMessage:(LYRMessage *)message
{
    if ([cell isKindOfClass:[ATLBaseCollectionViewCell class]]) {
        
        ATLBaseCollectionViewCell *abcvc = (ATLBaseCollectionViewCell *)cell;
        
        BOOL isOutgoing = [self.layerClient.authenticatedUser.userID isEqualToString:message.sender.userID];
        [abcvc configureCellForType:(isOutgoing ? ATLOutgoingCellType : ATLIncomingCellType)];
        
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        
        abcvc.bubbleView.menuControllerActions = [NSArray arrayWithObjects:copyMenuItem, deleteMenuItem, nil];
    }
    
    if ([cell isKindOfClass:[HONWeeklyReportCollectionViewCell class]]) {
        HONWeeklyReportCollectionViewCell *reportCell = (HONWeeklyReportCollectionViewCell *)cell;
        reportCell.delegate = self;
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

- (NSString *)conversationViewController:(ATLConversationViewController *)viewController reuseIdentifierForMessage:(LYRMessage *)message
{
    LYRMessagePart *part = message.parts.firstObject;
    if([part.MIMEType isEqualToString:HONMIMETypeTerminalStatus]) {
        return HONTerminalStatusReuseIdentifier;
    } else if([part.MIMEType isEqualToString:HONMIMETypeTerminalReport]) {
        return HONTerminalReportReuseIdentifier;
    }
    return nil;
}

- (CGFloat)conversationViewController:(ATLConversationViewController *)viewController heightForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth
{
    LYRMessagePart *part = message.parts.firstObject;
    
    if([part.MIMEType isEqualToString:HONMIMETypeTerminalStatus]) {
        NSInteger heightInt = 200;
        return heightInt;
    } else if([part.MIMEType isEqualToString:HONMIMETypeTerminalReport]) {
        NSInteger heightInt = 200;
        return heightInt;
    }
    return 0;
}

- (NSSet *)getUsers
{
    NSSet *users = [NSSet setWithObjects:
                    @"0ad9a737-6382-4a02-b386-6c5324d082a1",
                    @"36fa66d2-7ace-4ad3-a4df-c6b8db82f3bb",
                    @"4150e903-824c-46b8-98fb-7751a56c649d",
                    @"7351ab8d-14a1-4258-acce-b5b765cf6750",
                    @"7ac37121-d6b6-48be-ba8c-7be0c35b0646",
                    @"82a661a0-ce3b-4d4f-8720-c6d74668b105",
                    @"916e1ab9-3366-4e08-acd6-37533e8a9efa",
                    @"b9dd4f8d-85ee-4f7f-bd3f-22905ebc489c",
                    @"c8808ed8-6a3c-4fc9-9597-0250dc288446",
                    @"d8361407-ed75-4c63-bf7f-6fbfdd57540d",
                    @"ec5319e4-863d-4473-90bd-3d006031fa56",
                    @"fa5ce7a1-bccc-41e9-a77f-06b5640659db",
                    @"47fd1cd0-9b54-4229-9c3c-d8325bbc4477",
                    @"bd2404b6-a71a-4340-915e-689a0a6b915e",
                    nil];
    return users;
}

#pragma mark - ATLAddressBarControllerDelegate

/**
 Atlas - Informs the delegate that the user tapped the `addContacts` icon in the `ATLAddressBarViewController`. Atlas Messenger presents an `ATLParticipantPickerController`.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    NSSet *selectedParticipantIDs = [addressBarViewController.selectedParticipants valueForKey:@"userID"];
    NSSet *validUserIDs = [self getUsers];
    LYRPredicate *validUserPredicate = [LYRPredicate predicateWithProperty:@"userID" predicateOperator:LYRPredicateOperatorIsIn value:validUserIDs];
    
    if (selectedParticipantIDs) {
        LYRPredicate *selectedParticipantPredicate = [LYRPredicate predicateWithProperty:@"userID" predicateOperator:LYRPredicateOperatorIsNotIn value:selectedParticipantIDs];
        query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[selectedParticipantPredicate, validUserPredicate]];
    } else {
        query.predicate = validUserPredicate;
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - HONWeeklyReportCollectionViewCellDelegate

- (void)didTapViewFullReportButton:(UIViewController *)previewController
{
    [self presentViewController:previewController animated:YES completion:nil];
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

- (NSString *)urlStringFromTerminalStatusMessagePart:(LYRMessagePart *)messagePart
{
    NSString *jsonString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *url = [json objectForKey:@"url"];
    return url;
}

- (NSString *)urlStringFromTerminalReportMessagePart:(LYRMessagePart *)messagePart
{
    NSString *jsonString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *url = [json objectForKey:@"url"];
    return url;
}

#pragma mark - Link Tap Handler

- (void)userDidTapLink:(NSNotification *)notification
{
    [[UIApplication sharedApplication] openURL:notification.object];
}

- (void)configureUserInterfaceAttributes
{
    [[ATLIncomingMessageCollectionViewCell appearance] setBubbleViewColor:HONLightGrayColor()];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blackColor]];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageLinkTextColor:ATLBlueColor()];
    
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:HONPurpleColor()];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageLinkTextColor:[UIColor whiteColor]];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTapLink:) name:ATLUserDidTapLinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationMetadataDidChange:) name:ATLMConversationMetadataDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)registerCustomCellClasses
{
    [self registerClass:[HONTerminalStatusCollectionViewCell class] forMessageCellWithReuseIdentifier:HONTerminalStatusReuseIdentifier];
    [self registerClass:[HONWeeklyReportCollectionViewCell class] forMessageCellWithReuseIdentifier:HONTerminalReportReuseIdentifier];
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

#pragma mark - UI Configuration

- (BOOL)shouldDisplayDateLabelForSection:(NSUInteger)section
{
    if (section < ATLNumberOfSectionsBeforeFirstMessageSection) return NO;
    if (section == ATLNumberOfSectionsBeforeFirstMessageSection) return YES;
    
    LYRMessage *message = [self.conversationDataSource messageAtCollectionViewSection:section];
    LYRMessagePart *messagePart = ATLMessagePartForMIMEType(message, HONMIMETypeTerminalStatus);
    if (messagePart) {
        return NO;
    }
    
    messagePart = ATLMessagePartForMIMEType(message, HONMIMETypeTerminalReport);
    if (messagePart) {
        return NO;
    }
    
    LYRMessage *previousMessage = [self.conversationDataSource messageAtCollectionViewSection:section - 1];
    if (!previousMessage.sentAt) return NO;
    
    NSDate *date = message.sentAt ?: [NSDate date];
    NSTimeInterval interval = [date timeIntervalSinceDate:previousMessage.sentAt];
    if (fabs(interval) > self.dateDisplayTimeInterval) {
        return YES;
    }
    return NO;
}

@end
