#import "IntroLayer.h"

@interface IntroLayer ()
@property (nonatomic, weak) CCSprite *headshot;
@property (nonatomic) float velX;
@property (nonatomic) float velY;
@property (nonatomic) float offset;
@property (nonatomic) float speed;
@end

@implementation IntroLayer

-(instancetype)init {
    if (self = [super init]) {
        self.offset = self.headshot.contentSize.width * 0.5;
        self.velX = 1.0f;
        self.velY = 1.0f;
        self.speed = 100;

        CCSprite *background = [CCSprite spriteWithFile:@"cat.png"];
        background.position = ccp(384, 512);
        background.anchorPoint = ccp(0.5, 0.5);

        [self addChild:background];
        [self addChild:self.headshot];
        [self scheduleUpdate];
    }
    return self;
}

-(CCSprite *)headshot {
    if (!_headshot) {
        _headshot = [CCSprite spriteWithFile:@"headshot.png"];
        _headshot.position = ccp(384, 512);
        _headshot.anchorPoint = ccp(0.5, 0.5);
    }
    return _headshot;
}

-(void)update:(ccTime)delta {
    float topEdge  = 0.0f + self.offset;
    float bottomEdge = 1024.0f - self.offset;
    float leftEdge = 0.0f + self.offset;
    float rightEdge = 768.0f - self.offset;

    if (self.headshot.position.x >= rightEdge || self.headshot.position.x <= leftEdge) {
        self.velX *= -1;
    }

    if (self.headshot.position.y >= bottomEdge || self.headshot.position.y <= topEdge) {
        self.velY *= -1;
    }

    self.headshot.position = ccp(self.headshot.position.x + delta * self.velX * self.speed,
                                 self.headshot.position.y + delta * self.velY * self.speed);
}

@end
