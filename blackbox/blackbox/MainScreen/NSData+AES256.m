//
//  NSData+AES256.m
//  blackbox
//
//  Created by Vladimir Samoylenko on 9/9/16.
//  Copyright © 2016 Peredovik Development. All rights reserved.
//

#import "NSData+AES256.h"

@implementation NSData (AES256)


- (NSData *)AES256EncryptWithKey:(NSString *)key {

    NSData *result = [[NSData alloc] init];
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
//    free(buffer);
    return result;
}

@end
