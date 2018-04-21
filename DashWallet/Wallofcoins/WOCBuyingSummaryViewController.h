//
//  WOCBuyingSummaryViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"
@interface WOCBuyingSummaryViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *phoneNo;
@property (strong, nonatomic) NSArray *orders;
@property (assign) BOOL isFromSend;
@property (assign) BOOL hideSuccessAlert;
@property (weak, nonatomic) IBOutlet UITextView *txtInstruction;
@property (weak, nonatomic) IBOutlet UILabel *lblInstruction;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyMoreDash;

- (IBAction)buyMoreDashClicked:(id)sender;
- (void)displayAlert;

@end
