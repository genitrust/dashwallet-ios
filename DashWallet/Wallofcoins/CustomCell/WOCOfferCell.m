//
//  WOCOfferCell.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCOfferCell.h"

@implementation WOCOfferCell

- (void)awakeFromNib 
{
    [super awakeFromNib];
    // Initialization code
    
    self.btnOrder.layer.cornerRadius = 3.0;
    self.btnOrder.layer.masksToBounds = YES;
    
    self.btnLocation.layer.cornerRadius = 3.0;
    self.btnLocation.layer.masksToBounds = YES;
    
    [self setShadow:self.mainView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Function

- (void)setShadow:(UIView *)view
{
    view.layer.cornerRadius = 3.0;
    view.layer.masksToBounds = YES;
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

@end
