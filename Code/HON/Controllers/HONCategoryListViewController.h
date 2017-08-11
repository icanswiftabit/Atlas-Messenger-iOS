//
//  HONCategoryListViewController.h
//  HappyOrNot
//
//  Created by Daniel Maness on 8/9/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMLayerController.h"

NS_ASSUME_NONNULL_BEGIN
@class HONCategoryListViewController;

@protocol HONCategoryListViewControllerPresentationDelegate <NSObject>

- (void)categoryListViewControllerWillBeDismissed:(nonnull HONCategoryListViewController *)categoryListViewController;

- (void)categoryListViewControllerWasDismissed:(nonnull HONCategoryListViewController *)categoryListViewController;

@end

@interface HONCategoryListViewController : UITableViewController

@property (nullable, nonatomic, weak) id<HONCategoryListViewControllerPresentationDelegate> presentationDelegate;
@property (nonatomic) ATLMLayerController *layerController;
@property (nonatomic, retain) NSArray *categories;

+ (instancetype)categoryListViewControllerWithLayerController:(ATLMLayerController *)layerController;

- (void)presentTerminalListViewControllerWithFolderName:(NSString *)FolderName;

@end
NS_ASSUME_NONNULL_END
