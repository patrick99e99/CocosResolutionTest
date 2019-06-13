    #import "Director.h"

    static const float designWidth = 768.0f;
    static const float designHeight = 1024.0f;

    @interface Director ()
    @property (nonatomic) float scaleX;
    @property (nonatomic) float scaleY;
    @end

    @interface CCDirectorIOS ()
    -(void) setNextScene;
    -(void) showStats;
    -(void) calculateDeltaTime;
    -(void) calculateMPF;
    -(void) updateContentScaleFactor;
    @end

    @implementation Director

    -(void)initialize {
        _projection = kCCDirectorProjection2D;
        [self enableRetinaDisplay:YES];
        [self setDisplayStats:NO];
        [self setAnimationInterval:1.0f / 60.0f];
    }

    -(void)setView:(UIView *)view {
        [super setView:view];
        CGSize size = _winSizeInPixels;
        self.scaleX = size.width / designWidth / CC_CONTENT_SCALE_FACTOR();
        self.scaleY = size.height / designHeight / CC_CONTENT_SCALE_FACTOR();
    }

    -(void)setViewport {
        CGSize size = _winSizeInPixels;

        float targetAspectRatio = designWidth / designHeight;
        
        int width = (int)size.width;
        int height = (int)(width / targetAspectRatio);
        
        if (height > size.height) {
            height = size.height;
            width = (int)(height * targetAspectRatio);
        }
        
        int x = (size.width - (width * CC_CONTENT_SCALE_FACTOR())) / 2;
        int y = (size.height - (height * CC_CONTENT_SCALE_FACTOR())) / 2;
        
        glViewport(x, y, width, height);
    }

    - (void) drawScene {
        /* calculate "global" dt */
        [self calculateDeltaTime];
        
        CCGLView *openGLview = (CCGLView*)[self view];
        
        [EAGLContext setCurrentContext: [openGLview context]];
        
        /* tick before glClear: issue #533 */
        if( ! _isPaused )
            [_scheduler update: _dt];
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        /* to avoid flickr, nextScene MUST be here: after tick and before draw.
         XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
        if( _nextScene )
            [self setNextScene];
        
        kmGLPushMatrix();
        kmGLScalef(self.scaleX, self.scaleY, 1.0f);

        [_runningScene visit];
        
        [_notificationNode visit];
        
        if( _displayStats )
            [self showStats];
        
        kmGLPopMatrix();
        
        _totalFrames++;
        
        [openGLview swapBuffers];
        
        if( _displayStats )
            [self calculateMPF];
    }

    @end
