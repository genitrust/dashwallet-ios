//
//  BRReceiveViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 5/8/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRReceiveViewController.h"
#import "BRRootViewController.h"
#import "BRPaymentRequest.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "BRBubbleView.h"
#import "BRAppGroupConstants.h"
#import "UIImage+Utils.h"
#import "BREventManager.h"
#import "BRWalletManager.h"
#import <MobileCoreServices/UTCoreTypes.h>



//WallOfCoins
#import "WOCBuyDashStep1ViewController.h"
#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "WOCConstants.h"
#import "MBProgressHUD.h"
#import "BRAppDelegate.h"
#import "APIManager.h"

#define QR_TIP      NSLocalizedString(@"Let others scan this QR code to get your dash address. Anyone can send "\
                    "dash to your wallet by transferring them to your address.", nil)
#define ADDRESS_TIP NSLocalizedString(@"This is your dash address. Tap to copy it or send it by email or sms. The "\
                    "address will change each time you receive funds, but old addresses always work.", nil)

//#define QR_IMAGE_FILE [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject\
//                       stringByAppendingPathComponent:@"qr.png"]

@interface BRReceiveViewController ()

@property (nonatomic, strong) UIImage *qrImage;
@property (nonatomic, strong) BRBubbleView *tipView;
@property (nonatomic, assign) BOOL showTips;
@property (nonatomic, strong) NSUserDefaults *groupDefs;
@property (nonatomic, strong) id balanceObserver, txStatusObserver;

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIButton *addressButton;
@property (nonatomic, strong) IBOutlet UIImageView *qrView;

@end

@implementation BRReceiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRPaymentRequest *req;

    self.groupDefs = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    req = (_paymentRequest) ? _paymentRequest :
          [BRPaymentRequest requestWithString:[self.groupDefs stringForKey:APP_GROUP_RECEIVE_ADDRESS_KEY]];

    if (req.isValid) {
        if (! _qrImage) {
            _qrImage = [[UIImage imageWithData:[self.groupDefs objectForKey:APP_GROUP_QR_IMAGE_KEY]]
                        resize:self.qrView.bounds.size withInterpolationQuality:kCGInterpolationNone];
        }
        
        self.qrView.image = _qrImage;
        [self.addressButton setTitle:req.paymentAddress forState:UIControlStateNormal];
    }
    else [self.addressButton setTitle:nil forState:UIControlStateNormal];
    
    if (req.amount > 0) {
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        NSMutableAttributedString * attributedDashString = [[manager attributedStringForDashAmount:req.amount withTintColor:[UIColor darkTextColor] useSignificantDigits:FALSE] mutableCopy];
        NSString * titleString = [NSString stringWithFormat:@" (%@)",
                                  [manager localCurrencyStringForDashAmount:req.amount]];
        [attributedDashString appendAttributedString:[[NSAttributedString alloc] initWithString:titleString attributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor]}]];
        self.label.attributedText = attributedDashString;
    }

    self.addressButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self updateAddress];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideTips];
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
}

- (void)updateAddress
{
    //small hack to deal with bounds
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateAddress];
        });
        return;
    }
    __block CGSize qrViewBounds = (self.qrView ? self.qrView.bounds.size : CGSizeMake(250.0, 250.0));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        BRPaymentRequest *req = self.paymentRequest;
        UIImage *image = nil;
        
        if ([req.data isEqual:[self.groupDefs objectForKey:APP_GROUP_REQUEST_DATA_KEY]]) {
            image = [UIImage imageWithData:[self.groupDefs objectForKey:APP_GROUP_QR_IMAGE_KEY]];
        }
        
        if (! image && req.data) {
            image = [UIImage imageWithQRCodeData:req.data color:[CIColor colorWithRed:0.0 green:0.0 blue:0.0]];
        }
        
        self.qrImage = [image resize:qrViewBounds withInterpolationQuality:kCGInterpolationNone];
        
        if (req.amount == 0) {
            if (req.isValid) {
                [self.groupDefs setObject:UIImagePNGRepresentation(image) forKey:APP_GROUP_QR_IMAGE_KEY];
                image = [UIImage imageWithQRCodeData:req.data color:[CIColor colorWithRed:1.0 green:1.0 blue:1.0]];
                [self.groupDefs setObject:UIImagePNGRepresentation(image) forKey:APP_GROUP_QR_INV_IMAGE_KEY];
                [self.groupDefs setObject:self.paymentAddress forKey:APP_GROUP_RECEIVE_ADDRESS_KEY];
                [self.groupDefs setObject:req.data forKey:APP_GROUP_REQUEST_DATA_KEY];
            }
            else {
                [self.groupDefs removeObjectForKey:APP_GROUP_REQUEST_DATA_KEY];
                [self.groupDefs removeObjectForKey:APP_GROUP_RECEIVE_ADDRESS_KEY];
                [self.groupDefs removeObjectForKey:APP_GROUP_QR_IMAGE_KEY];
                [self.groupDefs removeObjectForKey:APP_GROUP_QR_INV_IMAGE_KEY];
            }

            [self.groupDefs synchronize];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.qrView.image = self.qrImage;
            [self.addressButton setTitle:self.paymentAddress forState:UIControlStateNormal];
            
            if (req.amount > 0) {
                BRWalletManager *manager = [BRWalletManager sharedInstance];
                NSMutableAttributedString * attributedDashString = [[manager attributedStringForDashAmount:req.amount withTintColor:[UIColor darkTextColor] useSignificantDigits:FALSE] mutableCopy];
                NSString * titleString = [NSString stringWithFormat:@" (%@)",
                                          [manager localCurrencyStringForDashAmount:req.amount]];
                [attributedDashString appendAttributedString:[[NSAttributedString alloc] initWithString:titleString attributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor]}]];
                self.label.attributedText = attributedDashString;
                
                if (! self.balanceObserver) {
                    self.balanceObserver =
                        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification
                        object:nil queue:nil usingBlock:^(NSNotification *note) {
                            [self checkRequestStatus];
                        }];
                }
                
                if (! self.txStatusObserver) {
                    self.txStatusObserver =
                        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification
                        object:nil queue:nil usingBlock:^(NSNotification *note) {
                            [self checkRequestStatus];
                        }];
                }
            }
        });
    });
}

- (void)checkRequestStatus
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRPaymentRequest *req = self.paymentRequest;
    uint64_t total = 0, fuzz = [manager amountForLocalCurrencyString:[manager localCurrencyStringForDashAmount:1]]*2;
    
    if (! [manager.wallet addressIsUsed:self.paymentAddress]) return;

    for (BRTransaction *tx in manager.wallet.allTransactions) {
        if ([tx.outputAddresses containsObject:self.paymentAddress]) continue;
        if (tx.blockHeight == TX_UNCONFIRMED &&
            [[BRPeerManager sharedInstance] relayCountForTransaction:tx.txHash] < PEER_MAX_CONNECTIONS) continue;
        total += [manager.wallet amountReceivedFromTransaction:tx];
                 
        if (total + fuzz >= req.amount) {
            UIView *view = self.navigationController.presentingViewController.view;

            [self done:nil];
            [view addSubview:[[[BRBubbleView viewWithText:[NSString
             stringWithFormat:NSLocalizedString(@"received %@ (%@)", nil), [manager stringForDashAmount:total],
             [manager localCurrencyStringForDashAmount:total]]
             center:CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)] popIn] popOutAfterDelay:3.0]];
            break;
        }
    }
}

- (BRPaymentRequest *)paymentRequest
{
    if (_paymentRequest) return _paymentRequest;
    return [BRPaymentRequest requestWithString:self.paymentAddress];
}

- (NSString *)paymentAddress
{
    if (_paymentRequest) return _paymentRequest.paymentAddress;
    return [BRWalletManager sharedInstance].wallet.receiveAddress;
}

- (BOOL)nextTip
{
    if (self.tipView.alpha < 0.5) return [(id)self.parentViewController.parentViewController nextTip];

    BRBubbleView *tipView = self.tipView;

    self.tipView = nil;
    [tipView popOut];

    if ([tipView.text hasPrefix:QR_TIP]) {
        self.tipView = [BRBubbleView viewWithText:ADDRESS_TIP tipPoint:[self.addressButton.superview
                        convertPoint:CGPointMake(self.addressButton.center.x, self.addressButton.center.y - 10.0)
                        toView:self.view] tipDirection:BRBubbleTipDirectionDown];
        self.tipView.backgroundColor = tipView.backgroundColor;
        self.tipView.font = tipView.font;
        self.tipView.userInteractionEnabled = NO;
        [self.view addSubview:[self.tipView popIn]];
    }
    else if (self.showTips && [tipView.text hasPrefix:ADDRESS_TIP]) {
        self.showTips = NO;
        [(id)self.parentViewController.parentViewController tip:self];
    }

    return YES;
}

- (void)hideTips
{
    if (self.tipView.alpha > 0.5) [self.tipView popOut];
}

-(void)pushToStep1
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
        UINavigationController *navController = (UINavigationController*) [storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"];
        
        WOCBuyDashStep1ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];// Or any VC with Id
        vc.isFromSend = YES;
        [navController.navigationBar setTintColor:[UIColor whiteColor]];
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navController;
    });
}

// MARK: - WallofCoins API

- (void)getOrders
{
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             //@"publisherId": @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
        UINavigationController *navController = (UINavigationController*) [storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"];
        
        if (error == nil) {
            if ([responseDict isKindOfClass:[NSArray class]])
            {
                NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
                if (orders.count > 0){
                    NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                    NSDictionary *orderDict = (NSDictionary*)[orders objectAtIndex:0];
                    NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
                    
                    if ([status isEqualToString:@"WD"]) {
                        WOCBuyingInstructionsViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingInstructionsViewController"];
                        myViewController.phoneNo = phoneNo;
                        myViewController.isFromSend = YES;
                        myViewController.isFromOffer = NO;
                        myViewController.orderDict = (NSDictionary*)[orders objectAtIndex:0];
                        
                        [navController pushViewController:myViewController animated:YES];
                    }
                    else {
                        
                        WOCBuyingSummaryViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
                        myViewController.phoneNo = phoneNo;
                        myViewController.orders = orders;
                        myViewController.isFromSend = YES;
                        
                        [navController pushViewController:myViewController animated:YES];
                    }
                    BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
                    appDelegate.window.rootViewController = navController;
                } else {
                    
                    [self pushToStep1];
                }
            }
            else {
                
                [self pushToStep1];
            }
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
            [self pushToStep1];
        }
    }];
}

// MARK: - IBAction

- (IBAction)done:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tip:(id)sender
{
    if ([self nextTip]) return;

    if (! [sender isKindOfClass:[UIGestureRecognizer class]] ||
        ([sender view] != self.qrView && ! [[sender view] isKindOfClass:[UILabel class]])) {
        if (! [sender isKindOfClass:[UIViewController class]]) return;
        self.showTips = YES;
    }

    self.tipView = [BRBubbleView viewWithText:QR_TIP
                    tipPoint:[self.qrView.superview convertPoint:self.qrView.center toView:self.view]
                    tipDirection:BRBubbleTipDirectionUp];
    self.tipView.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:[self.tipView popIn]];
}

- (IBAction)address:(id)sender
{
    if ([self nextTip]) return;
    [BREventManager saveEvent:@"receive:address"];

    BOOL req = (_paymentRequest) ? YES : NO;

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Receive dash at this address: %@", nil),
                                                                                  self.paymentAddress] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:(req) ? NSLocalizedString(@"copy request to clipboard", nil) :
                            NSLocalizedString(@"copy address to clipboard", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                [UIPasteboard generalPasteboard].string = (self.paymentRequest.amount > 0) ? self.paymentRequest.string :
                                self.paymentAddress;
                                NSLog(@"\n\nCOPIED PAYMENT REQUEST/ADDRESS:\n\n%@", [UIPasteboard generalPasteboard].string);
                                
                                [self.view addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"copied", nil)
                                                                            center:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0 - 130.0)] popIn]
                                                       popOutAfterDelay:2.0]];
                                [BREventManager saveEvent:@"receive:copy_address"];
    }]];

    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:(req) ? NSLocalizedString(@"send request as email", nil) :
                                NSLocalizedString(@"send address as email", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                    if ([MFMailComposeViewController canSendMail]) {
                                        MFMailComposeViewController *composeController = [MFMailComposeViewController new];
                                        
                                        composeController.subject = NSLocalizedString(@"Dash address", nil);
                                        [composeController setMessageBody:self.paymentRequest.string isHTML:NO];
                                        [composeController addAttachmentData:UIImagePNGRepresentation(self.qrView.image) mimeType:@"image/png"
                                                                    fileName:@"qr.png"];
                                        composeController.mailComposeDelegate = self;
                                        [self.navigationController presentViewController:composeController animated:YES completion:nil];
                                        composeController.view.backgroundColor =
                                        [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
                                        [BREventManager saveEvent:@"receive:send_email"];
                                    }
                                    else {
                                        [BREventManager saveEvent:@"receive:email_not_configured"];
                                        UIAlertController * alert = [UIAlertController
                                                                     alertControllerWithTitle:@""
                                                                     message:NSLocalizedString(@"email not configured", nil)
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction* okButton = [UIAlertAction
                                                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                   handler:^(UIAlertAction * action) {
                                                                   }];
                                        [alert addAction:okButton];
                                        [self presentViewController:alert animated:YES completion:nil];
                                        
                                    }
                                }]];
    }

#if ! TARGET_IPHONE_SIMULATOR
    if ([MFMessageComposeViewController canSendText]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:(req) ? NSLocalizedString(@"send request as message", nil) :
                                NSLocalizedString(@"send address as message", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                    if ([MFMessageComposeViewController canSendText]) {
                                        MFMessageComposeViewController *composeController = [MFMessageComposeViewController new];
                                        
                                        if ([MFMessageComposeViewController canSendSubject]) {
                                            composeController.subject = NSLocalizedString(@"Dash address", nil);
                                        }
                                        
                                        composeController.body = self.paymentRequest.string;
                                        
                                        if ([MFMessageComposeViewController canSendAttachments]) {
                                            [composeController addAttachmentData:UIImagePNGRepresentation(self.qrView.image)
                                                                  typeIdentifier:(NSString *)kUTTypePNG filename:@"qr.png"];
                                        }
                                        
                                        composeController.messageComposeDelegate = self;
                                        [self.navigationController presentViewController:composeController animated:YES completion:nil];
                                        composeController.view.backgroundColor = [UIColor colorWithPatternImage:
                                                                                  [UIImage imageNamed:@"wallpaper-default"]];
                                        [BREventManager saveEvent:@"receive:send_message"];
                                    }
                                    else {
                                        [BREventManager saveEvent:@"receive:message_not_configured"];
                                        UIAlertController * alert = [UIAlertController
                                                                     alertControllerWithTitle:@""
                                                                     message:NSLocalizedString(@"sms not currently available", nil)
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction* okButton = [UIAlertAction
                                                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                   handler:^(UIAlertAction * action) {
                                                                   }];
                                        [alert addAction:okButton];
                                        [self presentViewController:alert animated:YES completion:nil];
                                    }
                                }]];
    }
#endif

    if (! req) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"request an amount", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UINavigationController *amountNavController = [self.storyboard
                                                           instantiateViewControllerWithIdentifier:@"AmountNav"];
            
            ((BRAmountViewController *)amountNavController.topViewController).delegate = self;
            [self.navigationController presentViewController:amountNavController animated:YES completion:nil];
            [BREventManager saveEvent:@"receive:request_amount"];
                                }]];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

// Added New Button to Buy Dash with cash
- (IBAction)buyDash:(id)sender
{
    [sender setEnabled:NO];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        [self getOrders];
    }
    else {
        [self pushToStep1];
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
didFinishWithResult:(MessageComposeResult)result
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result
error:(NSError *)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - BRAmountViewControllerDelegate

- (void)amountViewController:(BRAmountViewController *)amountViewController selectedAmount:(uint64_t)amount
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    if (amount < manager.wallet.minOutputAmount) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"amount too small", nil)
                                     message:[NSString stringWithFormat:NSLocalizedString(@"dash payments can't be less than %@", nil),
                                              [manager stringForDashAmount:manager.wallet.minOutputAmount]]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                   }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        [BREventManager saveEvent:@"receive:amount_too_small"];
        return;
    }

    [BREventManager saveEvent:@"receive:show_request"];
    UINavigationController *navController = (UINavigationController *)self.navigationController.presentedViewController;
    BRReceiveViewController *receiveController = [self.storyboard
                                                  instantiateViewControllerWithIdentifier:@"RequestViewController"];
    
    receiveController.paymentRequest = self.paymentRequest;
    receiveController.paymentRequest.amount = amount;
    NSNumber *number = [manager localCurrencyNumberForDashAmount:amount];
    if (number) {
        receiveController.paymentRequest.currencyAmount = number.stringValue;
    }
    receiveController.paymentRequest.currency = manager.localCurrencyCode;
    receiveController.view.backgroundColor = self.parentViewController.parentViewController.view.backgroundColor;
    navController.delegate = receiveController;
    [navController pushViewController:receiveController animated:YES];
}

// MARK: - UIViewControllerAnimatedTransitioning

// This is used for percent driven interactive transitions, as well as for container controllers that have companion
// animations that might need to synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

// This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = transitionContext.containerView;
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey],
                     *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    [containerView addSubview:to.view];
    
    [UIView transitionFromView:from.view toView:to.view duration:[self transitionDuration:transitionContext]
    options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        [from.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

// MARK: - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC
toViewController:(UIViewController *)toVC
{
    return self;
}

// MARK: - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

@end
