//
//  BuyDashCell.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "BuyDashCell.h"

@implementation BuyDashCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btnOrder.layer.cornerRadius = 3.0;
    self.btnOrder.layer.masksToBounds = YES;
    
    self.btnLocations.layer.cornerRadius = 3.0;
    self.btnLocations.layer.masksToBounds = YES;
    self.btnLocations.layer.borderWidth = 1.0;
    self.btnLocations.layer.borderColor = [UIColor colorWithRed:78.0/255.0 green:139.0/255.0 blue:202.0/255.0 alpha:1.0].CGColor;
    
    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = YES;
    self.mainView.layer.borderWidth = 0.5;
    self.mainView.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
