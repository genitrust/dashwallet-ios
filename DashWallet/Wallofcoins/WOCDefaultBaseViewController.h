//
//  WOCBaseViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/02/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCConstants.h"
#import "BRAppDelegate.h"
#import "BRRootViewController.h"
#import "MBProgressHUD.h"
#import "APIManager.h"
#import "WOCAlertController.h"

@interface WOCDefaultBaseViewController : UIViewController

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (assign) BOOL requiredBackButton;

+ (instancetype) sharedInstance;

- (void)back;
- (void)backToRoot;
- (void)backToMainView;
- (void)push:(NSString*)viewControllerStr ;
- (void)clearLocalStorage;

- (void)setShadow:(UIView *)view;

- (id)getViewController:(NSString*)viewControllerStr;
- (void)pushViewControllerStr:(NSString*)viewControllerStr;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

-(NSString*)getCryptoPrice:(NSNumber*)number;

- (IBAction)backBtnClicked:(id)sender;
- (IBAction)signOutClicked:(id)sender;
- (IBAction)backToMainViewBtnClicked:(id)sender;
@end
