//
//  HOOK_SPTNowPlayingModel.h
//  SpotifyGesturesTW
//
//  Created by Dmitry Sokolov on 6/13/17.
//  Copyright © 2017 Dmitry Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@class SPTPlayerImpl, SPTNowPlayingTrackPosition;


@interface SPTNowPlayingModel : NSObject

-(SPTPlayerImpl*)player;

-(SPTNowPlayingTrackPosition*)trackPosition;

@end

@interface HOOK_SPTNowPlayingModel : NSObject


@end
