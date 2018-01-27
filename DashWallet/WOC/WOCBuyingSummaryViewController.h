//
//  WOCBuyingSummaryViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyingSummaryViewController : UIViewController

@property (strong, nonatomic) NSString *phoneNo;
@property (strong, nonatomic) NSArray *orders;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyMoreDash;
- (IBAction)buyMoreDashClicked:(id)sender;

@end
