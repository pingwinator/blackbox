//
//  NSData+AES256.h
//  blackbox
//
//  Created by Vladimir Samoylenko on 9/9/16.
//  Copyright © 2016 Peredovik Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (AES256)


- (NSData *)AES256EncryptWithKey:(NSString *)key;


@end
