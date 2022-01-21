//
//  YoutubeVideoPlayer.m
//
//  Created by Adrien Girbone on 15/04/2014.
//
//

#import "YoutubeVideoPlayer.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AVKit/AVKit.h>
#import <Cordova/NSDictionary+CordovaPreferences.h>

@implementation YoutubeVideoPlayer

- (void)pluginInitialize
{
    NSString *api_key = [self.commandDelegate.settings cordovaSettingForKey:@"YouTubeDataApiKey"];

    if (api_key != nil) {
        [XCDYouTubeClient setInnertubeApiKey: api_key];
    }
}

- (void)openVideo:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult* pluginResult = nil;
    
    NSString* videoID = [command.arguments objectAtIndex:0];
    
    if (videoID != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
        
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        [self.viewController presentViewController:playerViewController animated:YES completion:nil];

        __weak AVPlayerViewController *weakPlayerViewController = playerViewController;
        [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoID completionHandler:^(XCDYouTubeVideo * _Nullable video, NSError * _Nullable error) {
            if (video)
            {
                NSDictionary *streamURLs = video.streamURLs;
                NSURL *streamURL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?: streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];
                weakPlayerViewController.player = [AVPlayer playerWithURL:streamURL];
                [weakPlayerViewController.player play];
            }
            else
            {
                [self.viewController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    } else {
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing videoID Argument"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }
    
    _eventsCallbackId = command.callbackId;
}

- (void) playerItemDidPlayToEndTime:(NSNotification *)notification
{
    [self playerItemDidFinish: true];
}

- (void) playerItemFailedToPlayToEndTime:(NSNotification *)notification
{
    [self playerItemDidFinish: false];
}

- (void) playerItemDidFinish:(bool)isSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    if (!isSuccess)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Playback Error"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_eventsCallbackId];
    
}

@end
