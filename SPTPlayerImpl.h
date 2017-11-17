//
//  HOOK_SPTPlayerImpl.h
//  SpotifyGesturesTW
//
//  Created by Dmitry Sokolov on 6/13/17.
//  Copyright © 2017 Dmitry Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SPTPlayerImpl : NSObject

-(id)pause:(id)model;

-(id)resume;

-(id)seekTo:(CGFloat)position;

-(id)skipToNextTrackWithOptions:(id)options;
-(id)skipToPreviousTrackWithOptions:(id)options;

@end

@interface HOOK_SPTPlayerImpl : NSObject

@end
