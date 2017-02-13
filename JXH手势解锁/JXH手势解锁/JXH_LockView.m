//
//  JXH_LockView.m
//  JXH手势解锁
//
//  Created by mac on 16/6/22.
//  Copyright © 2016年 JXH. All rights reserved.
//

#import "JXH_LockView.h"

@interface JXH_LockView ()

@property (nonatomic, strong) NSMutableArray *selectedBtns;

@property (nonatomic, assign) CGPoint curP;

@end


@implementation JXH_LockView

- (NSMutableArray *)selectedBtns
{
    if (_selectedBtns == nil) {
        _selectedBtns= [NSMutableArray array];
    }
    return _selectedBtns;
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    // 获取触摸点
    _curP = [pan locationInView:self];
    
    // 判断触摸点是不是在按钮上
    for (UIButton *btn in self.subviews) {
        // 点在不在某个范围内,并且按钮没被选中过
        if (CGRectContainsPoint(btn.frame, _curP) && btn.selected == NO) {
            // 点在按钮上
            btn.selected = YES;
            
            [self.selectedBtns addObject:btn];
        }
        
    }
    NSLog(@"selectedBtns%ld",self.selectedBtns.count);
    // 重绘
    [self setNeedsDisplay];
    
    // 松手之后移除
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 创建可变字符串记录
        NSMutableString *strM = [NSMutableString string];
        // 保存输入密码
        for (UIButton *btn in self.selectedBtns) {
            [strM appendFormat:@"%ld",btn.tag];
        }
        
        NSLog(@"%@",strM);
        
        // 还原界面
        // 取消选中的按钮
        [self.selectedBtns enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = NO;
        }];
        
        // 清楚划线,把选中的按钮数组清空
        [self.selectedBtns removeAllObjects];
    }
}
// 1.创建按钮
// 加载完xib的时候调用
- (void)awakeFromNib
{
    // 创建9个按钮
    for (int i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // 不允许交互,按钮不可点击,就能达到不高亮的状态
                btn.userInteractionEnabled = NO;
        
        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        
        btn.tag = i;
        [self addSubview:btn];
    }
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
}

// 1,布局按钮
// 为什么要在这个方法布局子控件，因为只要一调用这个方法，就表示父控件的尺寸确定
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSUInteger count = self.subviews.count;
    int cols = 3;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 74;
    CGFloat h = 74;
    CGFloat margin = (self.bounds.size.width - cols * w) / (cols + 1);
    
    CGFloat col = 0;
    CGFloat row = 0;
    for (NSUInteger i = 0; i < count; i++) {
        UIButton *btn = self.subviews[i];
        // 获取当前按钮的列数
        col = i % cols;
        row = i / cols;
        x = margin + col * (margin + w);
        y = row * (margin + w);
        
        btn.frame = CGRectMake(x, y, w, h);
        
    }
    
}

- (void)drawRect:(CGRect)rect
{
    // 如果没有选中按钮,就不需要连线
    if (self.selectedBtns.count == 0) return;
    
    // 把所有选中按钮中心点连接
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSUInteger count = self.selectedBtns.count;
    
    // 从最后一个按钮的中心连线到手指的触摸点
    for (int i = 0; i < count; i++) {
        UIButton *btn = self.selectedBtns[i];
        if (i == 0) {
            // 设置起点
            [path moveToPoint:btn.center];
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    // 连线到手指的触摸点
    [path addLineToPoint:_curP];
    
    [[UIColor greenColor] set];
    path.lineWidth = 10;
    path.lineJoinStyle = kCGLineJoinRound;
    [path stroke];
    
}
@end
