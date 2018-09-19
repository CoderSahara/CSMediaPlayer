//
//  NSURL+CSMediaURL.m
//  CSMediaPlayer_Example
//
//  Created by Sahara on 2018/9/19.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import "NSURL+CSMediaURL.h"

@implementation NSURL (CSMediaURL)

- (NSURL *)streamingURL {
    // http://xxxx
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"sreaming";
    return compents.URL;
}

- (NSURL *)httpURL {
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"http";
    return compents.URL;
}

- (NSURL *)htppsURL {
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"https";
    return compents.URL;
}

@end
