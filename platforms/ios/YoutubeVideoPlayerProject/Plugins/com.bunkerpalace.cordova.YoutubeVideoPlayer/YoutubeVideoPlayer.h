//
//  YoutubeVideoPlayer.h
//
//  Created by Adrien Girbone on 15/04/2014.
//
//

#import <Cordova/CDV.h>
#import <XCDYouTubeKit/XCDYouTubeVideoPlayerViewController.h>

@interface YoutubeVideoPlayer : CDVPlugin {
    NSString* _eventsCallbackId;
}

- (void)openVideo:(CDVInvokedUrlCommand*)command;

@end
