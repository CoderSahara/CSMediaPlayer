//
//  CSRemoteResourceLoaderDelegate.m
//  CSMediaPlayer_Example
//
//  Created by Sahara on 2018/9/19.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import "CSRemoteResourceLoaderDelegate.h"
#import "CSRemoteAudioFile.h"
#import "CSAudioDownLoader.h"
#import "NSURL+CSMediaURL.h"

@interface CSRemoteResourceLoaderDelegate ()<CSAudioDownLoaderDelegate>

@property (nonatomic, strong) CSAudioDownLoader *downLoader;

@property (nonatomic, strong) NSMutableArray *loadingRequests;

@end

@implementation CSRemoteResourceLoaderDelegate

- (CSAudioDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[CSAudioDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}


- (NSMutableArray *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}


// 当外界, 需要播放一段音频资源是, 会跑一个请求, 给这个对象
// 这个对象, 到时候, 只需要根据请求信息, 抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%@", loadingRequest);
    
    
    // 1. 判断, 本地有没有该音频资源的缓存文件, 如果有 -> 直接根据本地缓存, 向外界响应数据(3个步骤) return
    NSURL *url = [loadingRequest.request.URL httpURL];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    if ([CSRemoteAudioFile cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    // 记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
    
    // 2. 判断有没有正在下载
    if (self.downLoader.loadedSize == 0) {
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        //        开始下载数据(根据请求的信息, url, requestOffset, requestLength)
        return YES;
    }
    
    // 3. 判断当前是否需要重新下载
    // 3.1 当资源请求, 开始点 < 下载的开始点
    // 3.2 当资源的请求, 开始点 > 下载的开始点 + 下载的长度 + 666
    if (requestOffset < self.downLoader.offset || requestOffset > (self.downLoader.offset + self.downLoader.loadedSize + 666)) {
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        return YES;
    }
    
    // 开始处理资源请求 (在下载过程当中, 也要不断的判断)
    [self handleAllLoadingRequest];
    
    
    return YES;
}

// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"取消某个请求");
    [self.loadingRequests removeObject:loadingRequest];
}

- (void)downLoading {
    [self handleAllLoadingRequest];
}

- (void)handleAllLoadingRequest {

    //    NSLog(@"在这里不断的处理请求");
    NSLog(@"-----%@", self.loadingRequests);
    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        NSString *contentType = self.downLoader.mimeType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 填充数据
        NSData *data = [NSData dataWithContentsOfFile:[CSRemoteAudioFile tmpFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[CSRemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        
        long long responseOffset = requestOffset - self.downLoader.offset;
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength) ;
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        
        [loadingRequest.dataRequest respondWithData:subData];
        
        
        
        // 3. 完成请求(必须把所有的关于这个请求的区间数据, 都返回完之后, 才能完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
        
    }
    
    [self.loadingRequests removeObjectsInArray:deleteRequests];
    
    /*
    AVAssetResourceLoadingRequest *loadingRequest = self.loadingRequests.firstObject;
    // 直接拿本地的临时缓存数据, 给请求, 让请求, 帮我们返回给服务器
    NSURL *url = loadingRequest.request.URL;
    // 1. 填充信息头
    loadingRequest.contentInformationRequest.contentType = self.downLoader.mimeType;
    loadingRequest.contentInformationRequest.contentLength = self.downLoader.totalSize;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 返回数据
    // 2.1 计算请求的数据区间
    long long requestOffSet = loadingRequest.dataRequest.currentOffset;
    long long requestLength = loadingRequest.dataRequest.requestedLength;
    
    // 2.2 根据请求的区间, 看下,本地的临时缓存,能够返回多少
    long long responseOffset = requestOffSet - self.downLoader.offset;
    long long responseLength = MIN(requestLength, self.downLoader.offset + self.downLoader.loadedSize - requestOffSet);
    
    NSData *data = [NSData dataWithContentsOfFile:[CSRemoteAudioFile tmpFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    if (data.length == 0) {
        data = [NSData dataWithContentsOfFile:[CSRemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    }
    NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
    if (loadingRequest.dataRequest) {
        [loadingRequest.dataRequest respondWithData:subData];
        // 3. 完成请求(byteRange) (必须, 是这个请求的数据, 全部都给完了, 完成)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [self.loadingRequests removeObject:loadingRequest];
        }
    }
    */
}


#pragma mark - Private Method

// 处理, 本地已经下载好的资源文件
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    // 1. 填充相应的信息头信息
    // 计算总大小
    
    
    NSURL *url = loadingRequest.request.URL;
    long long totalSize = [CSRemoteAudioFile cacheFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    
    NSString *contentType = [CSRemoteAudioFile contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 相应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:[CSRemoteAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3. 完成本次请求(一旦,所有的数据都给完了, 才能调用完成请求方法)
    [loadingRequest finishLoading];
}


@end
