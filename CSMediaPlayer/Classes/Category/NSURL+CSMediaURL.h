//
//  NSURL+CSMediaURL.h
//  CSMediaPlayer_Example
//
//  Created by Sahara on 2018/9/19.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CSMediaURL)

/**
 获取streaming协议的url地址
 */
- (NSURL *)streamingURL;

/**
 获取http协议的url地址
 */
- (NSURL *)httpURL;

/**
 获取https协议的url地址
 */
- (NSURL *)htppsURL;

@end
