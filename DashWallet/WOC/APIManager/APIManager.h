//
//  APIManager.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#define SHOW_LOGS TRUE

#ifdef SHOW_LOGS
#define APILog(x, ...) NSLog(@"\n\n%s %d: \n" x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define APILog(x, ...)
#endif
#define Str(str) (str != [NSNull null])?str:@""

@interface APIManager : NSObject

@property (nonatomic,strong) NSDate * lastMarketInfoCheck;

+ (instancetype)sharedInstance;

-(void)testAPI;
-(void)getAvailablePaymentCenters:(void (^)(id responseDict, NSError *error))completionBlock ;
-(void)makeAPIRequestWithURL:(NSString*)apiURL methord:(NSString*)httpMethord parameter:(id)parameter header:(NSDictionary*)header andCompletionBlock:(void (^)(id responseDict, NSError *error))completionBlock;
@end
