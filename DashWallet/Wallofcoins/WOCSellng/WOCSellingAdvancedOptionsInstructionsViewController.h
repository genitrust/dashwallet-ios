//
//  WOCSellingAdvancedOptionsInstructionsViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"

// Enter Phone Number Screen
@interface WOCSellingAdvancedOptionsInstructionsViewController : WOCBaseViewController
@property (assign, nonatomic) BOOL isBeforeCreateAd;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *txtMaxLimit;
@property (weak, nonatomic) IBOutlet UITextField *txtMinLimit;

- (IBAction)nextClicked:(id)sender;
- (void)loadVarificationScreen;
- (void)setupUI;
@end
