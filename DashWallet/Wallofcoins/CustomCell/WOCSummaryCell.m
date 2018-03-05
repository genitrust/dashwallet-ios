//
//  WOCSummaryCell.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSummaryCell.h"

@implementation WOCSummaryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.mainView.layer.cornerRadius = 10.0;
    self.mainView.layer.masksToBounds = YES;
    
    [self setShadow:self.mainView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setShadow:(UIView *)view
{
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

@end
