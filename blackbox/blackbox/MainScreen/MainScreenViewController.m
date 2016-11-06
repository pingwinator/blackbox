//
//  MainScreenViewController.m
//  blackbox
//
//  Created by Vladimir Samoylenko on 9/9/16.
//  Copyright © 2016 Peredovik Development. All rights reserved.
//

#import "MainScreenViewController.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

@synthesize btnDetectChagesInFingerPrint;
@synthesize btnStoreToKeyChain;
@synthesize btnGetFromKeyChain;

#pragma mark Initial procedures

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

        NSString *nibName;
        
        NSNumber *scrWidth = [NSNumber numberWithInteger:[[UIScreen mainScreen] bounds].size.height];
        NSNumber *i5Width = [NSNumber numberWithInteger:568];
        NSNumber *i6Width = [NSNumber numberWithInteger:667];
        NSNumber *i6PWidth = [NSNumber numberWithInteger:736];
        NSNumber *iPadProWidth = [NSNumber numberWithInteger:1366];
        
        NSString *xibEndsWith;
        
        if ([scrWidth isEqualToNumber:i5Width]){
            xibEndsWith = @"_iPhone5";
        }else if ([scrWidth isEqualToNumber:i6Width]){
            xibEndsWith = @"_iPhone6";
        }else if ([scrWidth isEqualToNumber:i6PWidth]){
            xibEndsWith = @"_iPhone6plus";
        }else if ([scrWidth isEqualToNumber:iPadProWidth]){
            xibEndsWith = @"_iPadPro";
        }else{
            xibEndsWith = @"_iPad";
        }
        
        nibName = [@"MainScreenViewController" stringByAppendingString:xibEndsWith];

        NSLog(@"nibname is %@", nibName);

        self = [super initWithNibName:nibName bundle:nibBundleOrNil];

    }
    return self;
}


- (void)viewDidLoad {

    [super viewDidLoad];

    laState = nil;
    laContext = [[LAContext alloc] init];

    keyData = [[NSString alloc] init];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


- (void) viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    BOOL hasTouchId = NO;

    if ([LAContext class]) {
        LAContext *context = [LAContext new];
        NSError *error = nil;
        hasTouchId = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    }
    
    if (hasTouchId == NO){
        
        NSLog(@"Device has NO touch id");
        
        [self showMessage:@"Problem" message:@"Device is not compatible: no Touch ID found :("];

        btnDetectChagesInFingerPrint.hidden = YES;
        btnStoreToKeyChain.hidden = YES;
        btnGetFromKeyChain.hidden = YES;
        
        return;
    }
    
    btnDetectChagesInFingerPrint.layer.borderColor = [UIColor blackColor].CGColor;
    btnDetectChagesInFingerPrint.layer.borderWidth = 2.0;
    btnDetectChagesInFingerPrint.layer.cornerRadius = 5;

    btnStoreToKeyChain.layer.borderColor = [UIColor blackColor].CGColor;
    btnStoreToKeyChain.layer.borderWidth = 2.0;
    btnStoreToKeyChain.layer.cornerRadius = 5;
    
    btnGetFromKeyChain.layer.borderColor = [UIColor blackColor].CGColor;
    btnGetFromKeyChain.layer.borderWidth = 2.0;
    btnGetFromKeyChain.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"message" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageNotification:) name:@"message" object:nil];
    
    keyData = [self createKey];

    updateItem = [[NSMutableDictionary alloc] init];
    
    [updateItem setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [updateItem setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [updateItem setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [updateItem setObject:serviceName forKey:(id)kSecAttrService];

    NSMutableDictionary *attributesMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:updateItem];
    
    [attributesMutableDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [attributesMutableDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    [attributesMutableDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    queryDictionary = [NSDictionary dictionaryWithDictionary:attributesMutableDictionary];
    
}


-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"message" object:nil];

}

#pragma mark UI procedures

-(IBAction)btnDetectChagesInFingerPrintTapped:(id)sender{

    NSError *authError = nil;
    NSString *laLocalizedReasonString = @"Please grant needed access level for checking your fingerprint status";
    
    laContext = [[LAContext alloc] init];
    
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {

        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:laLocalizedReasonString
                    reply:^(BOOL success, NSError *error) {
                        if (success) {
                            
                            NSData *newState = laContext.evaluatedPolicyDomainState;
                            
                            NSString *newString = [[NSString alloc] initWithData:newState encoding:NSASCIIStringEncoding];

                            if (laState == nil){
                                
                                laState = laContext.evaluatedPolicyDomainState;
                                
                            }

                            NSString *oldState = [[NSString alloc] initWithData:laState encoding:NSASCIIStringEncoding];

                            if ([oldState isEqualToString:newString] == false){
                                
                                laState = laContext.evaluatedPolicyDomainState;

                                [self sendRequestToServer];
                                
                            }else if ([oldState isEqualToString:newString] == true){
                                
                                [self uniNotification:@"Information" message:@"Fingerprint state is the same as before" notificationName:@"message"];
                                
                            }
                        
                        } else {
                            
                            [self uniNotification:@"error" message:[error description] notificationName:@"message"];
                        }
                    }];
    } else {
        
        [self showMessage:@"error (policy)" message:[authError description]];

    }
    
}


-(IBAction)btnStoreToKeyChainTapped:(id)sender{
    
    CFDictionaryRef attributesResult = nil;
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&attributesResult) == noErr){

        NSLog(@"match found");
        
        NSMutableDictionary *keychainItemData = [[NSMutableDictionary alloc] init];
        [keychainItemData setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        NSData *dataPassword = [updateItem objectForKey:(__bridge id)kSecValueData];
        NSString *passwordString = [[NSString alloc] initWithData:dataPassword encoding:NSUTF8StringEncoding];
        
        passwordString = keyData;
        
        [keychainItemData setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        [keychainItemData removeObjectForKey:(__bridge id)kSecClass];

        OSStatus initialWriteStatus = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)keychainItemData);
        NSLog(@"result secItemUpdated: %d", initialWriteStatus);
        
    }else{

        OSStatus initialWriteStatus = SecItemDelete((CFDictionaryRef) updateItem);
        NSLog(@"result secItemDeleted: %d", initialWriteStatus);
        
        initialWriteStatus = SecItemAdd((__bridge CFDictionaryRef) updateItem, nil);
        NSLog(@"result secItemAdded: %d", initialWriteStatus);

    }
    
}


-(IBAction)btnGetFromKeyChainTapped:(id)sender{

    CFDictionaryRef dictionaryRef = NULL;

    OSStatus readDataStatus = SecItemCopyMatching((__bridge CFDictionaryRef) queryDictionary, (CFTypeRef *)&dictionaryRef);
    
    NSLog(@"result readStatus: %d", readDataStatus);
    
    if(readDataStatus == errSecSuccess){

        NSDictionary *dataPasswordDic = (__bridge NSDictionary *)(dictionaryRef);
        
        NSData *dataPassword = [dataPasswordDic objectForKey:(__bridge id)kSecValueData];
        NSString *password = [[NSString alloc] initWithData:dataPassword encoding:NSUTF8StringEncoding];

        NSLog(@"got stored value: %@", password);

    }

    NSLog(@"getting stored data completed");
    
}


#pragma mark Utility procedures

-(void)messageNotification:(NSNotification *) notification{

    NSDictionary *notificationDic = notification.userInfo;
    
    [self showMessage:[notificationDic valueForKey:@"title"] message:[notificationDic valueForKey:@"message"]];

    
}


-(void)showMessage:(NSString *)title message:(NSString *)messageText{

    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:title  message:messageText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (NSString *)createKey {
    
    unsigned char buf[32];
    arc4random_buf(buf, sizeof(buf));
    
     NSData *keyGenerated = [NSData dataWithBytes:buf length:sizeof(buf)];
    
    if (keyGenerated == nil) {
        return nil;
    }
 
    return [keyGenerated base64EncodedStringWithOptions:kNilOptions];
}


-(void) sendRequestToServer{
    
    NSMutableDictionary *dictJSON = [[NSMutableDictionary alloc] init];
    
    NSString *oldState = [[NSString alloc] initWithData:laState encoding:NSASCIIStringEncoding];

    [dictJSON setValue:oldState forKey:@"fingerstring"];
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJSON options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error != nil){
        
        [self showMessage:@"error (JSON convertation)" message:[error description]];
        
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    
    NSData *cipher = [jsonData AES256EncryptWithKey:keyData];
    
    NSString *urlServer = @"http://requestb.in/18ktndx1";
    NSURL *url = [NSURL URLWithString:urlServer];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    request.HTTPMethod = @"POST";
    request.HTTPBody = cipher;

    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonString length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        
        if (([data length] > 0) && (connectionError == nil)){
            
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self uniNotification:@"Data has been sent" message:response notificationName:@"message"];
            
        }else if (([data length] == 0) && (connectionError == 0)){

            [self uniNotification:@"Connection error" message:@"result is empty" notificationName:@"message"];

        }else if (connectionError != nil){
            
            [self uniNotification:@"Connection error" message:[connectionError description] notificationName:@"message"];
            
        }

    }];

    [postDataTask resume];

}


-(void)uniNotification:(NSString *)title message:(NSString *)message notificationName:(NSString *)notificationName{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    [userInfo setValue:title forKey:@"title"];
    [userInfo setValue:message forKey:@"message"];
    
    if (![NSThread isMainThread])
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSNotification *notification = [NSNotification notificationWithName:notificationName object:self userInfo:userInfo];
            
            [self sendNorification:notification];
            
        });
        return;
    }else{
        
        NSNotification *notification = [NSNotification notificationWithName:notificationName object:self userInfo:userInfo];
        
        [self sendNorification:notification];
        
    }
    
}



-(void)sendNorification:(NSNotification *)notification
{
    
    [[NSNotificationQueue defaultQueue]
     enqueueNotification:notification
     postingStyle:NSPostNow];
    
}


@end
