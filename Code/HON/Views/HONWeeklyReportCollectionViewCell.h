//
//  HONWeeklyReportCollectionViewCell.h
//  Atlas Messenger
//
//  Created by Daniel Maness on 8/4/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import "ATLMessagePresenting.h"
#import "ATLMessageCollectionViewCell.h"
#import "QuickLook/QuickLook.h"

@protocol HONWeeklyReportCollectionViewCellDelegate <NSObject>

- (void)didTapViewFullReportButton:(UIViewController *)previewController;

@end

@interface HONWeeklyReportCollectionViewCell : UICollectionViewCell <ATLMessagePresenting, QLPreviewControllerDelegate, QLPreviewControllerDataSource>

@property (nonatomic) id<HONWeeklyReportCollectionViewCellDelegate> delegate;

@end
