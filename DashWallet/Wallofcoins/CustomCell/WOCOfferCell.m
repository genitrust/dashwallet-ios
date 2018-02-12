//
//  WOCOfferCell.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCOfferCell.h"

@implementation WOCOfferCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btnOrder.layer.cornerRadius = 3.0;
    self.btnOrder.layer.masksToBounds = YES;
    
    self.btnLocation.layer.cornerRadius = 3.0;
    self.btnLocation.layer.masksToBounds = YES;
    
    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = YES;
    
    [self setShadow:self.mainView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Function
- (void)setShadow:(UIView *)view{
    
    //if widthOffset = 1 and heightOffset = 1 then shadow will set to two sides
    //if widthOffset = 0 and heightOffset = 0 then shadow will set to four sides
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 0);//CGSize(width: widthOffset, height: heightOffset)//0,1
    view.layer.shadowRadius = 1; //1
    view.layer.shadowOpacity = 1;//1
    view.layer.masksToBounds = false;
}

@end
