#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSURL+CSMediaURL.h"
#import "CSAudioDownLoader.h"
#import "CSRemoteAudioFile.h"
#import "CSRemotePlayer.h"
#import "CSRemoteResourceLoaderDelegate.h"

FOUNDATION_EXPORT double CSMediaPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char CSMediaPlayerVersionString[];

