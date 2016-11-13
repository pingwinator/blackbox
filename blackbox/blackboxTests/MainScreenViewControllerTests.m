//
//  blackboxTests.m
//  blackboxTests
//
//  Created by Vladimir Samoylenko on 11/12/16.
//  Copyright © 2016 Peredovik Development. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MainScreenViewController.h"

@interface blackboxTests : XCTestCase
{
    
    MainScreenViewController *mainScreen;
    
}

@end

@implementation blackboxTests


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    mainScreen = [[MainScreenViewController alloc] init];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    
}

- (void)testCreationOfViewController {
    
    NSString *nibNameOriginal = [mainScreen getNibNameForInit];

    NSString *nibName = mainScreen.nibName;
    
    XCTAssertNotNil(nibName);

    BOOL areEqual = [nibNameOriginal isEqualToString:nibName];
    
    XCTAssertTrue(areEqual);

}


- (void)testIfButtonsAreHiddenShown {

    BOOL touchIdIs = *[mainScreen getTouchIdValue];

    BOOL btnGetFromKeyChainIsHidden = mainScreen.btnGetFromKeyChain.hidden;
    BOOL btnDetectChagesInFingerPrintIsHidden = mainScreen.btnDetectChagesInFingerPrint.hidden;
    BOOL btnStoreToKeyChainIsHidden = mainScreen.btnStoreToKeyChain.hidden;
    
    if (touchIdIs == YES){
    
        XCTAssertTrue(btnGetFromKeyChainIsHidden);
        XCTAssertTrue(btnDetectChagesInFingerPrintIsHidden);
        XCTAssertTrue(btnStoreToKeyChainIsHidden);
        
    }else{

        XCTAssertFalse(btnGetFromKeyChainIsHidden);
        XCTAssertFalse(btnDetectChagesInFingerPrintIsHidden);
        XCTAssertFalse(btnStoreToKeyChainIsHidden);

    }
    
}


-(void)testWriteRead {
    
    BOOL touchIdIs = *[mainScreen getTouchIdValue];

    if (touchIdIs == NO){
        
        XCTAssert(YES, @"Pass - cannot use Simulator for testing");
        return;
    }

    NSString *keyDataBefore = [mainScreen getKeyData];
    
    [mainScreen.btnStoreToKeyChain sendActionsForControlEvents:UIControlEventTouchDown];
    
    [mainScreen.btnGetFromKeyChain sendActionsForControlEvents:UIControlEventTouchDown];
    
    NSString *keyDataAfter = [mainScreen getKeyData];
    
    BOOL theSame = [keyDataBefore isEqualToString:keyDataAfter];
    
    XCTAssertTrue(theSame, @"the same string");
    
}


@end
