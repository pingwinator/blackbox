//
//  blackboxUITests.m
//  blackboxUITests
//
//  Created by Vladimir Samoylenko on 11/26/16.
//  Copyright © 2016 Peredovik Development. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MainScreenViewController.h"

@interface blackboxUITests : XCTestCase{

    MainScreenViewController *mainScreen;

}

@end

@implementation blackboxUITests

- (void)setUp {
    [super setUp];
    
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];

    mainScreen = [[MainScreenViewController alloc] init];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWriteReadToKeyChain {

    [mainScreen createKey];
    
    NSString *keyDataToWrite = [mainScreen getKeyData];
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElementQuery *buttonsQuery = app.buttons;
    XCUIElementQuery *btnQuery = [buttonsQuery matchingIdentifier:@"storetokeychain"];
    XCUIElement* btnElement = btnQuery.element;
    [btnElement tap];
    
    btnQuery = [buttonsQuery matchingIdentifier:@"getvaluefromkeychain"];
    btnElement = btnQuery.element;
    [btnElement tap];
    
    NSString *readKeyData = [mainScreen getKeyData];

    NSLog(@"before: %@", keyDataToWrite);
    NSLog(@"after : %@", readKeyData);
    
    bool valueTheSame = [keyDataToWrite isEqualToString:readKeyData];
    
    XCTAssertTrue(valueTheSame);
    
}

@end
