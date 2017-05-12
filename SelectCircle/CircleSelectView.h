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
//返回button 的title
- (NSArray *)buttonTitleWithItems;
//返回button 的image
- (NSArray *)buttonImageWithItems;
//返回button 的image 高亮状态
- (NSArray *)buttonHeightImageWithItems;
//返回背景区域的颜色值
- (NSArray *)weakSelfColors;
//button 按钮方法
- (void)ButtonClick:(NSInteger)Tag;
//返回默认区域的button
- (void)DefaultReturnButton:(UIButton *)button;

@required
//返回button 的个数
- (NSInteger)buttonWithNumbers;
//返回button 的size
- (CGSize)buttonWithSIze;
@end

@interface CircleSelectView : UIView
//声明代理
@property (weak ,nonatomic)id<CircleSelecteDelegate>delegate;

- (void)setViewDelegate:(id<CircleSelecteDelegate>)delegate;

//初始化控件方法
- (instancetype)initWithFrame:(CGRect)frame;
@end
