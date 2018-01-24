//
//  WOCAboutCell.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCAboutCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertLeadingConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkTrailingConstant;

@end
