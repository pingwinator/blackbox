//
//  MainScreenViewController.h
//  blackbox
//
//  Created by Vladimir Samoylenko on 9/9/16.
//  Copyright © 2016 Peredovik Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSData+AES256.h"
#import <Foundation/Foundation.h>
#import <Security/Security.h>

@import LocalAuthentication;

static const UInt8 kKeychainItemIdentifier[]    = "org.peredovik.KeychainUI\0";
static const NSString *identifier = @"RedQueen";
static const NSString *serviceName = @"RedQueenSample";

@interface MainScreenViewController : UIViewController<NSURLSessionDelegate>{

    NSData *laState;
    LAContext *laContext;
    NSString *keyData;
    NSMutableDictionary *updateItem;
    NSDictionary *queryDictionary;
    BOOL hasTouchId;
}


@property (strong, nonatomic) IBOutlet UIButton *btnDetectChagesInFingerPrint;
@property (strong, nonatomic) IBOutlet UIButton *btnStoreToKeyChain;
@property (strong, nonatomic) IBOutlet UIButton *btnGetFromKeyChain;


-(IBAction)btnDetectChagesInFingerPrintTapped:(id)sender;
-(IBAction)btnStoreToKeyChainTapped:(id)sender;
-(IBAction)btnGetFromKeyChainTapped:(id)sender;

-(NSString *)getNibNameForInit;
-(BOOL *)getTouchIdValue;
-(NSString *)getKeyData;
-(NSString *)createKey;

    
@end
