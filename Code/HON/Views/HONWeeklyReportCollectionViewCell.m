//
//  HONWeeklyReportCollectionViewCell.m
//  Atlas Messenger
//
//  Created by Daniel Maness on 8/4/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

//
//  HONTerminalStatusCollectionViewCell.m
//  Pods
//
//  Created by Daniel Maness on 7/30/17.
//
//

#import "HONConstants.h"
#import "HONMessagingUtilities.h"
#import "HONWeeklyReportCollectionViewCell.h"
#import "HONCardView.h"

@interface HONWeeklyReportCollectionViewCell ()
@property (nonatomic) HONCardView *cardView;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UIView *bodyView;
@property (nonatomic) UIView *buttonView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *indexLabel;
@property (nonatomic) UILabel *responsesLabel;
@property (nonatomic) UIView *ratingsContainerView;
@property (nonatomic) UILabel *greatLabel;
@property (nonatomic) UILabel *goodLabel;
@property (nonatomic) UILabel *badLabel;
@property (nonatomic) UILabel *terribleLabel;
@property (nonatomic) UIImageView *greatImageView;
@property (nonatomic) UIImageView *goodImageView;
@property (nonatomic) UIImageView *badImageView;
@property (nonatomic) UIImageView *terribleImageView;
@property (strong,nonatomic) UIButton *fullReportButton;

@property (nonatomic) LYRMessage *message;
@property (nonatomic) NSURL *reportURL;
@property (nonatomic) NSURL *url;
@end

@implementation HONWeeklyReportCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)
    {
        _cardView = [[HONCardView alloc] init];
        _cardView.cornerRadius = 5.0;
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        _cardView.layer.cornerRadius = 5.0f;
        [self.contentView addSubview:_cardView];
        
        _headerView = [[UIView alloc] init];
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
        _headerView.backgroundColor = HONPurpleColor();
        [self.cardView addSubview:_headerView];
        
        _bodyView = [[UIView alloc] init];
        _bodyView.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyView.backgroundColor = UIColor.whiteColor;
        _bodyView.layer.borderColor = HONLightGrayColor().CGColor;
        _bodyView.layer.borderWidth = 1.0f;
        [self.cardView addSubview:_bodyView];
        
        _buttonView = [[UIView alloc] init];
        _buttonView.translatesAutoresizingMaskIntoConstraints = NO;
        _buttonView.backgroundColor = UIColor.whiteColor;
        _buttonView.layer.borderColor = HONLightGrayColor().CGColor;
        _buttonView.layer.borderWidth = 1.0f;
        [self.cardView addSubview:_buttonView];
        
        [self configureHeaderUI];
        [self configureBodyUI];
        [self configureButtonUI];
        
        [self configureCardConstraints];
        [self configureHeaderConstraints];
        [self configureBodyConstraints];
        [self configureButtonConstraints];
    }
    return self;
}

- (void)configureHeaderUI
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.font = HONFontBold(16.0);
    [self.headerView addSubview:_titleLabel];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    _dateLabel.textColor = UIColor.whiteColor;
    _dateLabel.font = HONFontSemibold(10.0);
    [self.headerView addSubview:_dateLabel];
}

- (void)configureBodyUI
{
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _indexLabel.textAlignment = NSTextAlignmentLeft;
    _indexLabel.textColor = HONGrayColor();
    _indexLabel.font = HONFontSemibold(12.0);
    [self.bodyView addSubview:_indexLabel];
    
    _responsesLabel = [[UILabel alloc] init];
    _responsesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _responsesLabel.textAlignment = NSTextAlignmentLeft;
    _responsesLabel.textColor = HONGrayColor();
    _responsesLabel.font = HONFontSemibold(12.0);
    [self.bodyView addSubview:_responsesLabel];
    
    _ratingsContainerView = [[UIView alloc] init];
    _ratingsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    _ratingsContainerView.backgroundColor = HONLightGrayColor();
    _ratingsContainerView.layer.cornerRadius = 5.0f;
    [self.bodyView addSubview:_ratingsContainerView];
    
    _greatImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hon-great-icon"]];
    _greatImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _greatImageView.backgroundColor = UIColor.clearColor;
    _greatImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.ratingsContainerView addSubview:_greatImageView];
    
    _goodImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hon-good-icon"]];
    _goodImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _goodImageView.backgroundColor = UIColor.clearColor;
    _goodImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.ratingsContainerView addSubview:_goodImageView];
    
    _badImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hon-bad-icon"]];
    _badImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _badImageView.backgroundColor = UIColor.clearColor;
    _badImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.ratingsContainerView addSubview:_badImageView];
    
    _terribleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hon-terrible-icon"]];
    _terribleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _terribleImageView.backgroundColor = UIColor.clearColor;
    _terribleImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.ratingsContainerView addSubview:_terribleImageView];
    
    _greatLabel = [[UILabel alloc] init];
    _greatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _greatLabel.textAlignment = NSTextAlignmentCenter;
    _greatLabel.textColor = HONGrayColor();
    _greatLabel.font = HONFontSemibold(12.0);
    [self.ratingsContainerView addSubview:_greatLabel];
    
    _goodLabel = [[UILabel alloc] init];
    _goodLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _goodLabel.textAlignment = NSTextAlignmentCenter;
    _goodLabel.textColor = HONGrayColor();
    _goodLabel.font = HONFontSemibold(12.0);
    [self.ratingsContainerView addSubview:_goodLabel];
    
    _badLabel = [[UILabel alloc] init];
    _badLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _badLabel.textAlignment = NSTextAlignmentCenter;
    _badLabel.textColor = HONGrayColor();
    _badLabel.font = HONFontSemibold(12.0);
    [self.ratingsContainerView addSubview:_badLabel];
    
    _terribleLabel = [[UILabel alloc] init];
    _terribleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _terribleLabel.textAlignment = NSTextAlignmentCenter;
    _terribleLabel.textColor = HONGrayColor();
    _terribleLabel.font = HONFontSemibold(12.0);
    [self.ratingsContainerView addSubview:_terribleLabel];
}

- (void)configureButtonUI
{
    _fullReportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _fullReportButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_fullReportButton setTitle:@"View Full Report" forState:UIControlStateNormal];
    [_fullReportButton setTitleColor:HONPurpleColor() forState:UIControlStateNormal];
    _fullReportButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _fullReportButton.titleLabel.font = HONFontBold(14.0);
    _fullReportButton.backgroundColor = UIColor.whiteColor;
    [_fullReportButton addTarget:self action:@selector(fullReportButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:_fullReportButton];
}

- (void)configureCardConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.75 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cardView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeHeight multiplier:0.6 constant:1]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

- (void)configureHeaderConstraints
{
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:15]];
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-15]];
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)configureBodyConstraints
{
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingsContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.9 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingsContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.6 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingsContainerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingsContainerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:10]];
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.indexLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.responsesLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.indexLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:20]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.responsesLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.indexLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.greatImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.greatImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.greatImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeCenterY multiplier:0.75 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.greatImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.goodImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.goodImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.goodImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.greatImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.goodImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.greatImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.badImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.badImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.badImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.goodImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.badImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.goodImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.terribleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.terribleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.ratingsContainerView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.terribleImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.badImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.terribleImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.badImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.greatLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.greatImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.greatLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.greatImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.goodLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.goodImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.goodLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.goodImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.badLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.badImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.badLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.badImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.terribleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.terribleImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    [self.ratingsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.terribleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.terribleImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

- (void)configureButtonConstraints
{
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullReportButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullReportButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullReportButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullReportButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
}

- (void)updateWithSender:(id<ATLParticipant>)sender
{
    return;
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem
{
    return;
}

- (void)presentMessage:(LYRMessage *)message
{
    [self presentMockMessage];
    return;
    
    self.message = message;
    LYRMessagePart *messagePart = message.parts.firstObject;
    
    if ([messagePart.MIMEType isEqualToString:HONMIMETypeTerminalStatus]) {
        
    }
}

- (NSString *)urlStringFromsMessagePart:(LYRMessagePart *)messagePart
{
    NSString *jsonString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *url = [json objectForKey:@"url"];
    return url;
}

- (void)presentMockMessage
{
    self.titleLabel.text = @"WEEKLY REPORT";
    self.dateLabel.text = @"7/17/17 - 7/23/17";
    self.indexLabel.text = @"Index: 81.0";
    self.responsesLabel.text = @"Responses: 90";
    self.greatLabel.text = @"50%";
    self.goodLabel.text = @"43%";
    self.badLabel.text = @"6%";
    self.terribleLabel.text = @"1%";
    self.reportURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HappyOrNotHR_20170723_Week" ofType:@"pdf"]];
}

- (void)fullReportButtonTapped
{
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.delegate = self;
    previewController.dataSource = self;
    [self.delegate didTapViewFullReportButton:previewController];
}

#pragma mark - QLPreviewControllerDataSource Methods
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.reportURL;
}

@end
