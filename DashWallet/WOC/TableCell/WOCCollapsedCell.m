//
//  WOCCollapsedCell.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCCollapsedCell.h"

@implementation WOCCollapsedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = YES;
    
    self.mainView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.mainView.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainView.layer.shadowRadius = 1.0;
    self.mainView.layer.shadowOpacity = 1.0;
    self.mainView.layer.masksToBounds = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
