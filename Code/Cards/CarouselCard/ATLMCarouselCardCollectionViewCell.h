//
//  ATLMCarouselCardCollectionViewCell.h
//  Atlas Messenger
//
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#if 0
#pragma mark Imports
#endif

#import <Atlas/Atlas.h>
#import "ATLMCardPresenting.h"
#import "ATLMCardResponder.h"

NS_ASSUME_NONNULL_BEGIN     // {


#if 0
#pragma mark -
#endif

@interface ATLMCarouselCardCollectionViewCell : UICollectionViewCell <ATLMCardPresenting, ATLMCardResponder>
@property (nonatomic, strong, readwrite, nullable) LYRMessage *message;

@end

NS_ASSUME_NONNULL_END       // }
