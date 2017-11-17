#import "headers.h"

@interface SPTNowPlayingCoverArtModel : NSObject

-(SPTNowPlayingModel*)model;

@end

@interface SPTNowPlayingCoverArtController : NSObject

-(UIView*)coverArtView;

-(SPTNowPlayingCoverArtModel*)model;

-(void)setUpGesturesForView:(UIView*)view;
-(void)fastforward_SGTW:(UIGestureRecognizer*)gesture;
-(void)handleSGT_Swipe:(UISwipeGestureRecognizer*)gesture;
-(void)coverArtViewTapped:(UITapGestureRecognizer*)gesture;


-(void)setUpGesturesForView:(UIView*)view;
@end

double SGTW_AmountToForward = 10.0;

double SGTW_AmountToRewind = 10.0;

BOOL SGTW_isEnabled = YES;

BOOL SGTW_alwaysScreenOn = YES;







%hook SPTNowPlayingCoverArtController

-(instancetype)initWithModel:(id)model delegate:(id)delegate coverArtView:(UIView*)artView imageLoaderFactory:(id)factory videoSurfaceManager:(id)manager carouselRegistry:(id)registry logCenter:(id)center nowPlayingVideoManager:(id)videoManager testManager:(id)testManager adsManager:(id)adsManager {
    
    id res = %orig;
    
    [res setUpGesturesForView:artView];
    
    return res;
}


%new
-(void)setUpGesturesForView:(UIView*)view {
	if (view.gestureRecognizers.count <= 2) {
        
        
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fastforward_SGTW:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.cancelsTouchesInView = YES;
        
        UITapGestureRecognizer* tap = view.gestureRecognizers[0];
        [tap requireGestureRecognizerToFail:doubleTap];
        
        [view addGestureRecognizer:doubleTap];
        
        UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSGT_Swipe:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        [view addGestureRecognizer:swipeDown];
        
        
        UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSGT_Swipe:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [view addGestureRecognizer:swipeUp];
        
        UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fastforward_SGTW:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [view addGestureRecognizer:swipeRight];
    }

} // end method

-(void)coverArtViewTapped:(UITapGestureRecognizer*)gesture {
    if (!SGTW_isEnabled) {
	%orig;
        return;
    }

    SPTNowPlayingCoverArtModel* artModel = [self model];
    
    SPTNowPlayingModel* model = [artModel model];
    
    SPTPlayerImpl* player = [model player];
    
    SPTNowPlayingTrackPosition* position = [model trackPosition];
    CGFloat newPosition = MAX(0.0f, ([position currentTrackProgress] - SGTW_AmountToRewind) );
    [player seekTo:newPosition];
}


%new
-(void)fastforward_SGTW:(UIGestureRecognizer*)gesture {
    if (!SGTW_isEnabled) return;
    
    SPTNowPlayingCoverArtModel* artModel = [self model];
    
    SPTNowPlayingModel* model = [artModel model];
    
    SPTPlayerImpl* player = [model player];
    
    SPTNowPlayingTrackPosition* position = [model trackPosition];
    CGFloat trackLength = [position trackLength];
    CGFloat newPosition = [position currentTrackProgress] + SGTW_AmountToForward;
    if (newPosition > trackLength)
        newPosition = trackLength - 1.0f;
    
    [player seekTo:newPosition];
}




%new
-(void)handleSGT_Swipe:(UISwipeGestureRecognizer*)gesture {
    if (!SGTW_isEnabled) return;
    
    SPTNowPlayingCoverArtModel* artModel = [self model];
    
    SPTNowPlayingModel* model = [artModel model];
    
    SPTPlayerImpl* player = [model player];
    
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            [player skipToNextTrackWithOptions:nil];
            break;
            
        case UISwipeGestureRecognizerDirectionUp:
            [player skipToPreviousTrackWithOptions:nil];
            break;
            
        case UISwipeGestureRecognizerDirectionRight: {
            SPTNowPlayingTrackPosition* position = [model trackPosition];
            CGFloat newPosition = MIN(1.0f, ([position currentTrackProgress] + 10.f) );
            [player seekTo:newPosition];
        }
            
            break;
            
        default:
            break;
    }
    
}


%end

@interface SPTNowPlayingCoverArtView : UIView

-(UIScrollView*)coverArtView;

-(SPTNowPlayingCoverArtController*)dataSource;
-(SPTNowPlayingCoverArtController*)delegate;

@end

// ## MARK - Cell View

%hook SPTNowPlayingCoverArtView

-(void)layoutSubviews {
    %orig;

    if (!SGTW_isEnabled)
        return;

    if (self.dataSource != nil) {
        [self.dataSource setUpGesturesForView:self];
    }

    else if (self.delegate != nil) {
        [self.delegate setUpGesturesForView:self];
    }

}

-(void)updateScrollability {
    %orig;

	if (SGTW_isEnabled) {
        UIScrollView* scrollView = [self coverArtView];
        [scrollView.panGestureRecognizer setEnabled:NO];
    }
}

%end


// ## Mark - Genius View

%hook SPTGeniusNowPlayingViewControllerImpl


-(void)setActive:(BOOL)active {
    %orig(NO);
    
}


-(void)setGeniusEnabled:(BOOL)enabled {
    %orig(NO);
    
}


-(void)setGeniusFeatureEnabled:(BOOL)enabled {
    %orig(NO);
    
}

%end

%hook SPTGeniusNowPlayingViewController


-(BOOL)isActive {
    if (SGTW_isEnabled)
        return NO;
    return %orig;
}


-(BOOL)isGeniusEnabled {
    if (SGTW_isEnabled)
        return NO;
    return %orig;
}


-(BOOL)userWantsGenius {
    if (SGTW_isEnabled)
        return NO;
    return %orig;
}

%end

// ## Mark - Scroll Down Gesture


@interface SPTNowPlayingToggleContainerViewContainer : UIViewController

@end

%hook SPTNowPlayingToggleContainerViewContainer


-(void)viewDidAppear:(BOOL)animated {
    %orig;
}


%end

@interface SPTBarInteractivePresentationController : NSObject

-(id)dismissPanGestureRecognizer;

@end


%hook SPTBarInteractivePresentationController


-(BOOL)gesturesEnabled {

    //if (SGTW_isEnabled)
        //return NO;
    
    return %orig; 
}


-(BOOL)gestureRecognizerShouldBegin:(id)gesture {
    if (SGTW_isEnabled && self.dismissPanGestureRecognizer == gesture)
        return NO;

    return %orig;
}

%end




// ## Mark - Always On Screen


%hook UIApplication


-(void)setIdleTimerDisabled:(BOOL)disabled {
    if (SGTW_alwaysScreenOn)
        disabled = YES;

    %orig(disabled);
}

%end

