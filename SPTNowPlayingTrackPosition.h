//
//  SPTNowPlayingTrackPosition.h
//  SpotifyGesturesTW
//
//  Created by Dmitry Sokolov on 6/13/17.
//  Copyright © 2017 Dmitry Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SPTNowPlayingTrackPosition : NSObject


-(CGFloat)currentTrackProgress;

-(CGFloat)playbackSpeed;


-(CGFloat)trackLength;

@end
