//
//  CircleSelectView.m
//  SelectCircleDemo
//
//  Created by huhaifeng on 16/3/15.
//  Copyright © 2016年 huhaifeng. All rights reserved.
//
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define BTNTAG 20
#define SPACE 20
#import "CircleSelectView.h"

@interface CircleSelectView()
{
    UIView * _btnBgView;
    NSMutableArray * _BtnsArray; //所有的按钮集合数组
    NSArray * _BtnTitlesArray; //按钮的title数组
    NSArray * _BtnImagesArray; //按钮的图片数组
    NSArray * _BtnHeightImagesArray; //按钮的高亮图片数组
    NSArray * _weakSelfColors;//自身背景颜色值

    CGSize _BtnSize; //单个btn 大小
    
    NSDate * _TouchDate ; //触碰时间
    
    CGPoint beginPoint; //触碰点
    CGPoint movePoint; //移动中的点
    
    CGFloat Radius; //半径
    
    double RunAngle;   //转动的角度
    double TapAngle; //触碰时的角度
    double speed; //转动速度
}
@property (strong ,nonatomic)UIPanGestureRecognizer * panGestureR;

@end

@implementation CircleSelectView

/*
 * 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self =[super initWithFrame:frame]){
        
        
        [self CreateSelfViewUI:frame];
        
        [self addTapGestureRecognizer];
        
    }
    return self;
}
/*
 * param \delegate 代理
 */
- (void)setViewDelegate:(id<CircleSelecteDelegate>)delegate{
    
    self.delegate =delegate;
    
    [self GetButtonData]; //获取所有数据
    
    [self drawViewUI]; //画颜色背景
    
    _btnBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _btnBgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_btnBgView];
    
    [self CreateButtonUI]; //创建button UI
    
    [self CreateHeaderImageUI]; //加载头像UI
    
    [self ReturnDefaultButton];//传出默认选项值
}
/*
 * 加载头像UI
 */
- (void)CreateHeaderImageUI{
    
    UIButton * centerBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.backgroundColor =[UIColor whiteColor];
    [self addSubview:centerBtn];
    [self bringSubviewToFront:centerBtn];
    
    UIImage *image;
    if ([self.centerImage length])
    {
        image =[UIImage imageNamed:self.centerImage];
    }
    else
    {
        image =[UIImage imageNamed:@"image.bundle/222.png"];
    }
    if (self.centerButtonSize.width>0)
    {
        centerBtn.frame =CGRectMake(0, 0, self.centerButtonSize.width, self.centerButtonSize.height);
    }
    else
    {
        centerBtn.frame =CGRectMake(0, 0, 100, 100);
    }
    centerBtn.center =CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [centerBtn setImage:image forState:UIControlStateNormal];
    //切圆形
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:centerBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:centerBtn.bounds.size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = centerBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    centerBtn.layer.mask = maskLayer;
}
/*
 *加载自身界面UI
 */
- (void)CreateSelfViewUI:(CGRect)frame{
    
    self.backgroundColor =[UIColor whiteColor];
    self.layer.cornerRadius =self.frame.size.height/2;
    //加阴影
    self.layer.shadowPath =[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height/2].CGPath;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 5;
    
    RunAngle =0;
    Radius =frame.size.width/2;
    
}
/*
 * 获取所有数据
 */
- (void)GetButtonData{
    //获取按钮的title数组
    if ([self.delegate respondsToSelector:@selector(buttonTitleWithItems)]) {
        _BtnTitlesArray =[self.delegate buttonTitleWithItems];
    }
    else
    {
        _BtnTitlesArray =@[@"一",@"二",@"三",@"四",@"五",@"六"];
    }
    
    //获取按钮的图片数组
    if ([self.delegate respondsToSelector:@selector(buttonImageWithItems)]) {
        _BtnImagesArray =[self.delegate buttonImageWithItems];
    }
    //获取按钮的高亮图片数组
    if ([self.delegate respondsToSelector:@selector(buttonHeightImageWithItems)]) {
        _BtnHeightImagesArray =[self.delegate buttonHeightImageWithItems];
    }
    
    //获取扇形背景颜色
    if ([self.delegate respondsToSelector:@selector(weakSelfColors)]) {
        _weakSelfColors =[self.delegate weakSelfColors];
    }
    else
    {
        _weakSelfColors =@[RGBColor(255, 0, 0),RGBColor(255, 153, 0),RGBColor(221, 221, 221),RGBColor(0, 0, 0),RGBColor(255, 153, 0),RGBColor(221, 221, 221)];
    }
    
    //获取按钮的大小
    if ([self.delegate respondsToSelector:@selector(buttonWithSIze)]) {
        _BtnSize =[self.delegate buttonWithSIze];
    }
    else
    {
        _BtnSize =CGSizeMake(60, 60);
    }
}
/*
 * 创建button UI
 */
- (void)CreateButtonUI{
    
    _BtnsArray = [NSMutableArray new];
    for (NSInteger i =0; i<[_BtnTitlesArray count]; i++) {
        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame =CGRectMake(0, 0, _BtnSize.width, _BtnSize.height);
        button.backgroundColor =[UIColor grayColor];
        button.layer.cornerRadius =button.frame.size.width/2;
        button.tag =BTNTAG +i;
        [_btnBgView addSubview:button];
        [_BtnsArray addObject:button];
        
        [button setTitle:(NSString *)[_BtnTitlesArray objectAtIndex:i] forState:UIControlStateNormal];
        if ([_BtnImagesArray count] ==[_BtnTitlesArray count])
        {
            [button setImage:[UIImage imageNamed:(NSString *)[_BtnImagesArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
        if ([_BtnHeightImagesArray count] ==[_BtnTitlesArray count])
        {
            [button setImage:[UIImage imageNamed:(NSString *)[_BtnHeightImagesArray objectAtIndex:i]] forState:UIControlStateHighlighted];
        }
    }
    
    [self BtnsLayout]; //调整 button 中心点位置
    
}
/*
 * 按钮方法
 */
- (void)BtnClick:(UIButton *)sender{
    
    if ([_delegate respondsToSelector:@selector(buttonClick:)]) {
        [_delegate buttonClick:sender.tag -BTNTAG];
    }
}
/*
 * 调整按钮中心位置
 */
- (void)BtnsLayout {
    for (NSInteger i=0; i<[_BtnTitlesArray count] ;i++) {
        UIButton *button=[_BtnsArray objectAtIndex:i];
        CGFloat number =[_BtnTitlesArray count];
        CGFloat yy=Radius+sin((i/number)*M_PI*2+RunAngle)*(self.frame.size.width/2-_BtnSize.width/2-SPACE);
        CGFloat xx=Radius+cos((i/number)*M_PI*2+RunAngle)*(self.frame.size.width/2-_BtnSize.width/2-SPACE);
        button.center=CGPointMake(xx, yy);
    }
}

/*
 *加载滑动手势
 */
- (void)addTapGestureRecognizer{
    
    _panGestureR =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(CircleViewGesture:)];
    [self addGestureRecognizer:_panGestureR];
    
}


/*
 * 滑动手势
 */
- (void)CircleViewGesture:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state ==UIGestureRecognizerStateBegan) {
        TapAngle = 0;
        _TouchDate =[NSDate date];
        beginPoint =[gesture locationInView:self];
    }
    else if (gesture.state ==UIGestureRecognizerStateChanged){
        double startAngle = RunAngle;
        movePoint =[gesture locationInView:self];
        double start =[self getAngle:beginPoint];
        double move =[self getAngle:movePoint];
        
        if ([self getQuadrant:movePoint] == 1 || [self getQuadrant:movePoint] == 4) {
            RunAngle += move - start;
            TapAngle += move - start;

        }
        else // 二、三象限，色角度值是负值
        {
            RunAngle += start - move;
            TapAngle += start - move;

        }
        
        [self BtnsLayout];
        beginPoint =movePoint;
        speed =RunAngle -startAngle;
        
        NSLog(@"RunAngle:%f\n",RunAngle);
    }
    else if (gesture.state ==UIGestureRecognizerStateEnded){
        
        [self RunAngleValue];
        self.userInteractionEnabled =NO;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
            [self BtnsLayout];
            self.userInteractionEnabled =YES;
        } completion:^(BOOL finished) {
            [self ReturnDefaultButton];
        }];
// 延时滑动
//        NSTimeInterval time =[[NSDate date]timeIntervalSinceDate:_TouchDate];
//        double per = TapAngle*50/ time;
//        if (fabs(per) > 300) {//快速滑动
//            for (int j =0; j<10; j++) {
//                RunAngle +=speed;
//            }
//            
//            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                [self BtnsLayout];
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
        
    }
}
/*
 * 传出默认选项值
 */
- (void)ReturnDefaultButton {
    
    CGFloat number=[_BtnTitlesArray count];
    NSNumber * end =[NSNumber numberWithFloat:0.5* (1/number) *M_PI];//横坐标对应0 ，-0 纵坐标对应1，-1
    NSNumber * start =[NSNumber numberWithFloat:-0.5* (1/number) *M_PI];

    for(UIButton * button in _BtnsArray){
        
        double value =[self getAngle:button.center];
        
        if ([self getQuadrant:button.center] == 2 ||[self getQuadrant:button.center] == 3) { //红色区域和黑色区域对应的值相同，按象限划分
            
            if (value>[start doubleValue] && value< [end doubleValue]) {
                if ([self.delegate respondsToSelector:@selector(defaultReturnButton:)]) {
                    [self.delegate defaultReturnButton:button];
                    break;
                }
            }
        }
        
    }
}
/*
 * 计算角度 不足半格不转动,超过半格转动一格
 */
- (double)RunAngleValue{
    
    double number =[_BtnTitlesArray count];
    
    double valuer =2 * M_PI /number; //每一格的弧度
    
    double va =fmod(RunAngle, valuer);//取余数
    
    if (RunAngle >0 || RunAngle ==0) {
        if (fabs(va) >(valuer/2)){
            RunAngle -=fabs(va);
            RunAngle +=valuer;
        }
        else
        {
            RunAngle -=fabs(va);
        }
    }
    else
    {
        if (fabs(va) >(valuer/2)){
            RunAngle +=fabs(va);
            RunAngle -=valuer;
        }
        else
        {
            RunAngle +=fabs(va);
        }
    }
    return RunAngle;
}

#pragma  mark --获取当前点的弧度
- (double)getAngle:(CGPoint)point{
    
    double x = point.x - Radius;
    double y = point.y - Radius;
    return (double) (asin(y / hypot(x, y)));
}

#pragma mark --获取当前点所处的象限
-(int) getQuadrant:(CGPoint) point {
    
    int tmpX = (int) (point.x - Radius);
    int tmpY = (int) (point.y - Radius);
    if (tmpX >= 0) {
        return tmpY >= 0 ? 1 : 4;
    } else {
        return tmpY >= 0 ? 2 : 3;
    }
}

/*
 * 画颜色背景
 */
- (void)drawViewUI {
    
    CGFloat numbers =[_BtnTitlesArray count];
    NSNumber * radian =[NSNumber numberWithFloat:1/numbers];
    
    if ([_weakSelfColors count]!=[_BtnTitlesArray count]) {
        _weakSelfColors =@[RGBColor(255, 0, 0),RGBColor(255, 153, 0),RGBColor(221, 221, 221),RGBColor(0, 0, 0),RGBColor(255, 153, 0),RGBColor(221, 221, 221)];
    }
    
    CGPoint center =CGPointMake(self.frame.size.width/2, self.frame.size.height/2);;
    
    CGFloat redius = Radius;
    CGFloat start = 0;
    CGFloat angle = 0;
    CGFloat end = -radian.floatValue *M_PI; //偏移半个格子弧度
    
    for(NSInteger i =0;i<[_BtnTitlesArray count];i++){ //路径 拼接
        start =end;
        angle =radian.floatValue * 2*M_PI;
        end = start + angle;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:redius startAngle:start endAngle:end clockwise:YES];//顺时针 YES
        
        [path addLineToPoint:center];
        UIColor *color=(UIColor*)[_weakSelfColors objectAtIndex:i];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = color.CGColor;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineWidth = 0;
        layer.path = path.CGPath;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
        animation.fromValue = @0;
        animation.toValue = @1;
        animation.duration = 0.1;
        [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
        [self.layer addSublayer:layer];
    }

}

BOOL animating;
- (void)spinWithOptions:(UIViewAnimationOptions)options {
    [UIView animateWithDuration:0.1 delay:0.0 options:options animations:^{
        _btnBgView.transform = CGAffineTransformRotate(_btnBgView.transform, M_PI / 2);
    } completion:^(BOOL finished) {
        if (finished) {
            if (animating) {
                [self spinWithOptions: UIViewAnimationOptionCurveLinear];
            }
        }
    }];
}
- (void)startAnimation {
    if (!animating) {
        animating = YES;
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn];
    }
}
- (void)stopAnimation {
    animating = NO;
    _btnBgView.transform = CGAffineTransformIdentity;
}

- (void)runLocation:(double)angle {
    CGFloat value = angle/360.0;
    RunAngle = value * 2 * M_PI;
    [self RunAngleValue];
    [self BtnsLayout];
}
@end
