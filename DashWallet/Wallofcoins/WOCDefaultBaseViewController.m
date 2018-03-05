//
//  WOCBaseViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/02/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCDefaultBaseViewController.h"

#define MAIN_VIEWCONTROLLER @"WOCBuyDashStep1ViewController"

@interface WOCDefaultBaseViewController ()

@end

@implementation WOCDefaultBaseViewController

+ (instancetype) sharedInstance {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self setWOCNavigationController];
   
    NSLog(@"------------> You are In %@",[super class]);
    
    if (self.requiredBackButton) {
        
        if ([self.navigationController.visibleViewController isKindOfClass:NSClassFromString(MAIN_VIEWCONTROLLER)]) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToRoot)];
        }
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
        }
    }
    
    [self setWocDeviceCode];
}

-(void)setWOCNavigationController {
    /*
    if ( [WOCBaseViewController sharedInstance].navigationController == nil)
    {
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
        if ([[storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"] isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = (UINavigationController*) [storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"];

            [WOCBaseViewController sharedInstance].navigationController = navController;
            self.navigationController = navController;
        }
    }
    else
    {
        self.navigationController = [WOCBaseViewController sharedInstance].navigationController;
    }
     */
}

-(void)setWocDeviceCode {
    //store deviceCode in userDefault
    int launched = [self.defaults integerForKey:USER_DEFAULTS_LAUNCH_STATUS];
    if (launched == 0) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [self.defaults setValue:uuid forKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
        [self.defaults setInteger:1 forKey:USER_DEFAULTS_LAUNCH_STATUS];
        [self.defaults synchronize];
    }
}

-(NSString *)wocDeviceCode {
    NSString *deviceCode = @"";
    
    if ([self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE] != nil) {
        deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    }
    return deviceCode;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        
        NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
        NSString *loginPhone = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",phoneNo];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)setShadow:(UIView *)view {
    
    view.layer.cornerRadius = 3.0;
    view.layer.masksToBounds = YES;
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

- (void)showAlertWithText:(NSString*)alertText {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE message:alertText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:okayAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)storeDeviceInfoLocally {
    
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER] != nil) {
        if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID] != nil) {
            NSString * phoneNumber = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            NSString * deviceID = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            
            NSMutableDictionary *localDeiveDict =  [NSMutableDictionary dictionaryWithCapacity:0];
            if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
                
                localDeiveDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            }
            
            localDeiveDict[phoneNumber] = [NSString stringWithFormat:@"%@",deviceID];
            if (localDeiveDict != nil) {
                [self.defaults setObject:localDeiveDict forKey:USER_DEFAULTS_LOCAL_DEVICE_INFO];
                [self.defaults synchronize];
            }
        }
    }
    
    NSLog(@"Device info %@",[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]);
}

-(void)clearLocalStorage
{
    [self.defaults removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
    [self.defaults synchronize];
}

- (void)pushViewControllerStr:(NSString*)viewControllerStr {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
    id pushViewController = [storyboard instantiateViewControllerWithIdentifier:viewControllerStr];
    if (pushViewController != nil) {
        if ([pushViewController isKindOfClass:NSClassFromString(viewControllerStr)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 if ([self.navigationController.visibleViewController isKindOfClass:NSClassFromString(viewControllerStr)] == FALSE) {
                     [self.navigationController pushViewController:pushViewController animated:YES];
                 }
            });
        }
    }
}
// MARK: - BACK Funcations
- (void)backToRoot {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BRRootViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        
        UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
        UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blueColor];
        
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = nav;
        
         [self setWOCNavigationController];
    });
}

- (void)backToMainView {

    [self storeDeviceInfoLocally];
    [self push:MAIN_VIEWCONTROLLER];
}

-(id)getViewController:(NSString*)viewControllerStr  {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
    return  [storyboard instantiateViewControllerWithIdentifier:viewControllerStr];
}

- (void)push:(NSString*)viewControllerStr {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.navigationController.visibleViewController isKindOfClass:NSClassFromString(viewControllerStr)] == FALSE) {
            BOOL mainViewFound = FALSE;
            for (UIViewController *vc in self.navigationController.viewControllers) {
                
                if ([vc isKindOfClass:NSClassFromString(viewControllerStr)] == TRUE) {
                    mainViewFound = TRUE;
                    [self.navigationController popToViewController:vc animated:TRUE];
                }
            }
            
            if (!mainViewFound) {
                [self pushViewControllerStr:viewControllerStr];
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1 object:nil];
            });
        }
    });
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.navigationController.visibleViewController isKindOfClass:[viewController class]] == FALSE) {
            BOOL mainViewFound = FALSE;
            for (UIViewController *vc in self.navigationController.viewControllers) {
                
                if ([vc isKindOfClass:[viewController class]] == TRUE) {
                    mainViewFound = TRUE;
                    [self.navigationController popToViewController:vc animated:animated];
                }
            }
            
            if (!mainViewFound) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.navigationController.visibleViewController isKindOfClass:[viewController class]] == FALSE) {
                        [self.navigationController pushViewController:viewController animated:animated];
                    }
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1 object:nil];
            });
        }
    });
}

-(void)back {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController.navigationBar setHidden:NO];
    });
}

// MARK: - IBAction

- (IBAction)backBtnClicked:(id)sender {
    [self back];
}

- (IBAction)backToMainViewBtnClicked:(id)sender {
    [self backToMainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

