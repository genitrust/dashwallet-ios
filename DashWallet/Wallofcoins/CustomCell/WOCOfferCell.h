//
//  WOCOfferCell.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCOfferCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *otherBankImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblDashTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDashSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBankName;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnOrder;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDollar;

@end
