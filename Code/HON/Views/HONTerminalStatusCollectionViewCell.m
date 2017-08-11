//
//  HONTerminalStatusCollectionViewCell.m
//  Pods
//
//  Created by Daniel Maness on 7/30/17.
//
//

#import "HONConstants.h"
#import "HONMessagingUtilities.h"
#import "HONTerminalStatusCollectionViewCell.h"
#import "HONCardView.h"

@interface HONTerminalStatusCollectionViewCell ()
@property (nonatomic) HONCardView *cardView;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UIView *bodyView;
@property (nonatomic) UIView *buttonView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *timeframeLabel;
@property (nonatomic) UIImageView *iconImageView;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UILabel *thresholdLabel;
@property (nonatomic) UILabel *ratingLabel;
@property (nonatomic) UILabel *responsesLabel;
@property (strong,nonatomic) UIButton *acknowledgeButton;
@property (strong,nonatomic) UIButton *noActionButton;

@property (nonatomic) LYRMessage *message;
@property (nonatomic) NSURL *url;
@end

@implementation HONTerminalStatusCollectionViewCell

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
        _headerView.backgroundColor = HONRedColor();
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
    
    _timeframeLabel = [[UILabel alloc] init];
    _timeframeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeframeLabel.textAlignment = NSTextAlignmentLeft;
    _timeframeLabel.textColor = UIColor.whiteColor;
    _timeframeLabel.font = HONFontSemibold(1.0);
    [self.headerView addSubview:_timeframeLabel];
}

- (void)configureBodyUI
{
    _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hon-unhappy-icon"]];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _iconImageView.backgroundColor = UIColor.whiteColor;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bodyView addSubview:_iconImageView];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionLabel.textAlignment = NSTextAlignmentLeft;
    _descriptionLabel.textColor = HONGrayColor();
    _descriptionLabel.font = HONFontSemibold(8.0);
    _descriptionLabel.numberOfLines = 2;
    [self.bodyView addSubview:_descriptionLabel];
    
    _thresholdLabel = [[UILabel alloc] init];
    _thresholdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _thresholdLabel.textAlignment = NSTextAlignmentLeft;
    _thresholdLabel.textColor = HONGrayColor();
    _thresholdLabel.font = HONFontRegular(12.0);
    [self.bodyView addSubview:_thresholdLabel];
    
    _ratingLabel = [[UILabel alloc] init];
    _ratingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _ratingLabel.textAlignment = NSTextAlignmentCenter;
    _ratingLabel.textColor = HONPurpleColor();
    _ratingLabel.font = HONFontBold(48.0);
    [self.bodyView addSubview:_ratingLabel];
    
    _responsesLabel = [[UILabel alloc] init];
    _responsesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _responsesLabel.textAlignment = NSTextAlignmentCenter;
    _responsesLabel.textColor = HONGrayColor();
    _responsesLabel.font = HONFontSemibold(8.0);
    _responsesLabel.numberOfLines = 0;
    [self.bodyView addSubview:_responsesLabel];
}

- (void)configureButtonUI
{
    _acknowledgeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _acknowledgeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_acknowledgeButton setTitle:@"Mark as Acknowledged" forState:UIControlStateNormal];
    [_acknowledgeButton setTitleColor:HONGreenColor() forState:UIControlStateNormal];
    _acknowledgeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _acknowledgeButton.titleLabel.font = HONFontBold(14.0);
    _acknowledgeButton.backgroundColor = UIColor.whiteColor;
    [self.buttonView addSubview:_acknowledgeButton];
    
    _noActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _noActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_noActionButton setTitle:@"No Action" forState:UIControlStateNormal];
    [_noActionButton setTitleColor:HONRedColor() forState:UIControlStateNormal];
    _noActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _noActionButton.titleLabel.font = HONFontBold(14.0);
    _noActionButton.backgroundColor = UIColor.whiteColor;
    _noActionButton.layer.borderColor = HONLightGrayColor().CGColor;
    _noActionButton.layer.borderWidth = 1.0f;
    [self.buttonView addSubview:_noActionButton];
}

- (void)configureCardConstraints {
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
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeHeight multiplier:0.4 constant:1]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.bodyView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeHeight multiplier:0.4 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.cardView addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cardView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
}

- (void)configureHeaderConstraints
{
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:15]];
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.timeframeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10]];
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.timeframeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.timeframeLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-5]];
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)configureBodyConstraints
{
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.2 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.4 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTop multiplier:1.0 constant:5]];
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTop multiplier:1.0 constant:5]];

    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.thresholdLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.thresholdLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.responsesLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-5]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.responsesLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)configureButtonConstraints
{
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.acknowledgeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.acknowledgeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.acknowledgeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.acknowledgeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.noActionButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.noActionButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.noActionButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.buttonView addConstraint:[NSLayoutConstraint constraintWithItem:self.noActionButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
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
    self.message = message;
    LYRMessagePart *messagePart = message.parts.firstObject;
    
    if ([messagePart.MIMEType isEqualToString:HONMIMETypeTerminalStatus]) {
        NSString *jsonString = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        self.titleLabel.text = @"ALERT NOTICE";
        self.dateLabel.text = [NSString stringWithFormat:@"%@", [json objectForKey:@"date"]];
        self.descriptionLabel.text = [NSString stringWithFormat:@"%@", [json objectForKey:@"description"]];
        self.ratingLabel.text = [NSString stringWithFormat:@"%@", [json objectForKey:@"rating"]];
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [json objectForKey:@"url"]]];
        
        NSMutableAttributedString *responsesTitleString = [[NSMutableAttributedString alloc] initWithString:@"NEGATIVE RESPONSES"];
        [responsesTitleString addAttribute:NSFontAttributeName value:HONFontSemibold(8) range:NSMakeRange(0, responsesTitleString.length)];
        NSString *responses = [json objectForKey:@"responses"];
        NSMutableAttributedString *responsesString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", responses]];
        [responsesString addAttribute:NSFontAttributeName value:HONFontSemibold(12) range:NSMakeRange(0, responsesString.length)];
        [responsesTitleString appendAttributedString:responsesString];
        [self.responsesLabel setAttributedText:responsesTitleString];
    }
}

- (void)presentMockMessage
{
    self.titleLabel.text = @"ALERT NOTICE";
    self.dateLabel.text = @"Wed (07/26), 11:45 AM";
    self.timeframeLabel.text = @"30 mins";
    self.descriptionLabel.text = @"Location Front Desk Check-In Timeliness needs your attention!";
    self.thresholdLabel.text = @"Rate < 30%";
    self.ratingLabel.text = @"33%";
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"NEGATIVE RESPONSES"];
    [titleString addAttribute:NSFontAttributeName value:HONFontSemibold(8) range:NSMakeRange(0, titleString.length)];
    
    NSMutableAttributedString *responsesString = [[NSMutableAttributedString alloc] initWithString:@"\n1 out of total 3"];
    [responsesString addAttribute:NSFontAttributeName value:HONFontSemibold(12) range:NSMakeRange(0, responsesString.length)];
    
    [titleString appendAttributedString:responsesString];
    [self.responsesLabel setAttributedText:titleString];
}

@end
