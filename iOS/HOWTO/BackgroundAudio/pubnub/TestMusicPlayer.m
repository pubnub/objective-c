//
//  MusicPlayer.m
//  BackgroundAudio
//
//  Created by Jonathan Sagorin on 7/20/12.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "TestMusicPlayer.h"
#import "MusicQuery.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TestMusicPlayer()
@property(nonatomic,strong) AVQueuePlayer *avQueuePlayer;
@end
@implementation TestMusicPlayer

@synthesize avQueuePlayer=_avQueuePlayer;

+(void)initSession
{
    
    // Registers this class as the delegate of the audio session.
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError) {
        NSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
    }
    [[AVAudioSession sharedInstance] setActive: YES error: nil];

    UInt32 doSetProperty = 0;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideCategoryMixWithOthers,
                             sizeof (doSetProperty),
                             &doSetProperty
                             );
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (activationError) {
        NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
    }
    
}

- (void)loadExampleItem
{
	[[self avQueuePlayer] removeAllItems];
	for( int i=0; i<200; i++ )
	{
		NSString *str=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"2.mp3"];
		NSURL *remoteURL = [NSURL fileURLWithPath: str];
		AVPlayerItem *item = [AVPlayerItem playerItemWithURL:remoteURL];
		// insert the new item at the end
		if (item) {
			NSLog(@"insert item");
	//        [self registerAVItemObserver:item];
			[[self avQueuePlayer] insertItem:item afterItem:nil];
			[self play];
            // now observe item.status for when it is ready to play
		}
	}
}

- (void)registerAVItemObserver:(AVPlayerItem *)playerItem
{
	[playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context: nil];
}

-(AVPlayer *)avQueuePlayer
{
    if (!_avQueuePlayer) {
        _avQueuePlayer = [[AVQueuePlayer alloc]init];
		_avQueuePlayer.volume = 0.0;
//
//		[[NSNotificationCenter defaultCenter] addObserver: self
//                                                 selector: @selector(playerItemDidReachEnd:)
//                                                     name: AVPlayerItemDidPlayToEndTimeNotification
//                                                   object: nil];
		_avQueuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(nextSongPlaying:)
//													 name:AVPlayerItemDidPlayToEndTimeNotification
//												   object:[_avQueuePlayer currentItem]];
	}

    return _avQueuePlayer;
}

//- (void) playerItemDidReachEnd: (NSNotification *)notification
//{
//	NSLog(@"playerItemDidReachEnd");
//	[self loadExampleItem];
//}
//
//- (void)nextSongPlaying:(NSNotification *)notification
//{
//	NSLog(@"nextSongPlaying");
//	[self loadExampleItem];
//}

-(void) playSongWithId:(NSNumber*)songId
{
    MPMediaItem *mediaItem = [[[MusicQuery alloc]init] queryForSongWithId:songId];
    if (mediaItem) {
        if (mediaItem) {
            NSURL *assetUrl = [mediaItem valueForProperty: MPMediaItemPropertyAssetURL];
            AVPlayerItem *avSongItem = [[AVPlayerItem alloc] initWithURL:assetUrl];
            if (avSongItem) {
                [[self avQueuePlayer] insertItem:avSongItem afterItem:nil];
                [self play];
            }
        }
    }
}

#pragma mark - player actions
-(void) pause
{
    [[self avQueuePlayer] pause];
}

-(void) play
{
    [[self avQueuePlayer] play];
}


-(void) clear
{
    [[self avQueuePlayer] removeAllItems];
}

#pragma mark - remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    NSLog(@"received event!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                if ([self avQueuePlayer].rate > 0.0) {
                    [[self avQueuePlayer] pause];
                } else {
                    [[self avQueuePlayer] play];
                }

                break;
            }
            default:
                break;
        }
    }
}

@end
