//
//  HONCategoryListViewController.m
//  HappyOrNot
//
//  Created by Daniel Maness on 8/9/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import "ATLMConversationListViewController.h"
#import "ATLMSettingsViewController.h"
#import "HONCategoryListViewController.h"

static NSString *const HONCategoryCellReuseIdentifier = @"HONCategoryCellReuseIdentifier";

@interface HONCategoryListViewController () <UITableViewDataSource, UITableViewDelegate, ATLMSettingsViewControllerDelegate>

@end

@implementation HONCategoryListViewController

@synthesize categories;

NSString *const ATLMSettingsButtonAccessibilityLabel = @"Settings Button";

+ (instancetype)categoryListViewControllerWithLayerController:(ATLMLayerController *)layerController
{
    NSAssert(layerController, @"Layer Controller cannot be nil");
    return [[self alloc] initWithLayerController:layerController];
}

- (instancetype)initWithLayerController:(ATLMLayerController *)layerController
{
    NSAssert(layerController, @"Layer Controller cannot be nil");
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)  {
        _layerController = layerController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.categories = [NSArray arrayWithObjects:@"Concessions",@"Guest Services", @"Other", @"Parking", @"Restrooms", @"Screening", @"Unassigned", nil];
    
    // Left navigation item
    UIButton* infoButton= [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *infoItem  = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(settingsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    infoButton.accessibilityLabel = ATLMSettingsButtonAccessibilityLabel;
    [self.navigationItem setLeftBarButtonItem:infoItem];
}


#pragma mark - UITableViewControllerDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HONCategoryCellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HONCategoryCellReuseIdentifier];
    }
    
    cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewControllerDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *folderName = [self.categories objectAtIndex:indexPath.row];
    [self presentTerminalListViewControllerWithFolderName:folderName];
}

#pragma mark - ATLMSettingsViewControllerDelegate

- (void)switchUserTappedInSettingsViewController:(ATLMSettingsViewController *)settingsViewController
{
    // Nothing to do.
}

- (void)logoutTappedInSettingsViewController:(ATLMSettingsViewController *)settingsViewController
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    if (self.layerController.layerClient.isConnected) {
        if ([weakSelf.presentationDelegate respondsToSelector:@selector(categoryListViewControllerWillBeDismissed:)]) {
            [weakSelf.presentationDelegate categoryListViewControllerWillBeDismissed:weakSelf];
        }
        
        [self.layerController.layerClient.authenticatedUser removeObserver:settingsViewController forKeyPath:@"presenceStatus"];
        [self.layerController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
            [SVProgressHUD dismiss];
            [settingsViewController dismissViewControllerAnimated:YES completion:^{
                // Inform the presentation delegate all subviews (from child view
                // controllers) have been dismissed.
                if ([weakSelf.presentationDelegate respondsToSelector:@selector(categoryListViewControllerWasDismissed:)]) {
                    [weakSelf.presentationDelegate categoryListViewControllerWasDismissed:weakSelf];
                }
            }];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Unable to logout. Layer is not connected"];
    }
}

- (void)settingsViewControllerDidFinish:(ATLMSettingsViewController *)settingsViewController
{
    [settingsViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)settingsButtonTapped
{
    ATLMSettingsViewController *settingsViewController = [[ATLMSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped layerClient:self.layerController.layerClient];
    settingsViewController.settingsDelegate = self;
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (void)presentTerminalListViewControllerWithFolderName:(NSString *)folderName
{
    ATLMConversationListViewController *terminalListViewController = [ATLMConversationListViewController conversationListViewControllerWithLayerController:self.layerController withFolderName:folderName];
    [self.navigationController pushViewController:terminalListViewController animated:YES];
}

@end
