//
//  CSAudioDownLoader.h
//  CSMediaPlayer_Example
//
//  Created by Sahara on 2018/9/19.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSAudioDownLoaderDelegate <NSObject>

- (void)downLoading;

@end

@interface CSAudioDownLoader : NSObject

@property (nonatomic, weak) id<CSAudioDownLoaderDelegate> delegate;

@property (nonatomic, assign) long long totalSize;
@property (nonatomic, assign) long long loadedSize;
@property (nonatomic, assign) long long offset;
@property (nonatomic, strong) NSString *mimeType;


- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset;


@end
