//
//  CircleSelectView.h
//  SelectCircleDemo
//
//  Created by huhaifeng on 16/3/15.
//  Copyright © 2016年 huhaifeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleSelecteDelegate <NSObject>

@optional
//返回buttons 的title
- (NSArray *)buttonTitleWithItems;
//返回buttons 的image
- (NSArray *)buttonImageWithItems;
//返回buttons 的image 高亮状态
- (NSArray *)buttonHeightImageWithItems;
//返回扇形背景区域的颜色值
- (NSArray *)weakSelfColors;
//返回button 的size
- (CGSize)buttonWithSIze;
//button 按钮方法
- (void)buttonClick:(NSInteger)Tag;
//返回默认区域的button
- (void)defaultReturnButton:(UIButton *)button;
@end

@interface CircleSelectView : UIView
//声明代理
@property (weak ,nonatomic)id<CircleSelecteDelegate>delegate;

- (void)setViewDelegate:(id<CircleSelecteDelegate>)delegate;

//中心button的图片
@property (copy ,nonatomic)NSString *centerImage;

//中心button的大小Size
@property (assign ,nonatomic)CGSize centerButtonSize;

//初始化控件方法
- (instancetype)initWithFrame:(CGRect)frame;
@end
