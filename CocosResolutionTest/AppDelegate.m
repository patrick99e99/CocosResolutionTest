#import "cocos2d.h"
#import "AppDelegate.h"
#import "IntroLayer.h"

@implementation NavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end

@interface AppDelegate ()
@property (nonatomic, strong) NavigationController *navController;
@property (nonatomic, weak) CCDirectorIOS *director;
@property (nonatomic, strong) UIWindow *mainWindow;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"main window bounds: %@", NSStringFromCGRect([self.mainWindow bounds]));
    
	CCGLView *glView = [CCGLView viewWithFrame:[self.mainWindow bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:GL_DEPTH24_STENCIL8_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    self.director = (CCDirectorIOS *)[CCDirector sharedDirector];
    
	// Display FSP and SPF
	[self.director setDisplayStats:NO];
	
	// set FPS at 60
	[self.director setAnimationInterval:1.0f / 60.0f];
	
	// attach the openglView to the director
	[self.director setView:glView];

	// 2D projection
	[self.director setProjection:kCCDirectorProjection2D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    if (![self.director enableRetinaDisplay:YES]) {
		CCLOG(@"Retina Display Not supported");
    }
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@""];
    [sharedFileUtils setiPadSuffix:@""];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-hd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// Create a Navigation Controller with the Director
	self.navController = [[NavigationController alloc] initWithRootViewController:self.director];
	self.navController.navigationBarHidden = YES;
	
	// for rotation and other messages
	[self.director setDelegate:self.navController];
	
	// set the Navigation Controller as the root view controller
	[self.mainWindow setRootViewController:self.navController];

	// make main window visible
	[self.mainWindow makeKeyAndVisible];

    CCScene *scene = [CCScene node];
    [scene addChild:[[IntroLayer alloc] init]];
    [self.director runWithScene:scene];

	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if( [self.navController visibleViewController] == self.director )
		[self.director resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(UIWindow *)mainWindow {
    if (!_mainWindow) {
        CGRect frame = [[UIScreen mainScreen] bounds];
        _mainWindow = [[UIWindow alloc] initWithFrame:frame];
        for (UIGestureRecognizer *gestureRecognizer in [_mainWindow gestureRecognizers]) {
            gestureRecognizer.delegate = self;
        }
    }
    return _mainWindow;
}

# pragma mark - UIGestureRecognizerDelegate

    -(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
        return NO;
    }

    -(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
        return NO;
    }

    -(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
        return NO;
    }

@end

