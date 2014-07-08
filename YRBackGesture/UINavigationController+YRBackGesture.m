//
//  UINavigationController+YRBackGesture.m
//  Mark
//
//  Created by 王晓宇 on 14-7-8.
//  Copyright (c) 2014年 王晓宇. All rights reserved.
//

#import "UINavigationController+YRBackGesture.h"
#import <objc/runtime.h>

static const char *assoKeyPanGesture="__yrakpanges";
static const char *assoKeyStartPanPoint="__yrakstartp";
static const char *assoKeyEnableGesture="__yrakenabg";

@implementation UINavigationController (YRBackGesture)
-(BOOL)enableBackGesture{
    NSNumber *enableGestureNum = objc_getAssociatedObject(self, assoKeyEnableGesture);
    if (enableGestureNum) {
        return [enableGestureNum boolValue];
    }
    return false;
}
-(void)setEnableBackGesture:(BOOL)enableBackGesture{
    NSNumber *enableGestureNum = [NSNumber numberWithBool:enableBackGesture];
    objc_setAssociatedObject(self, assoKeyEnableGesture, enableGestureNum, OBJC_ASSOCIATION_RETAIN);
    if (enableBackGesture) {
         [self.view addGestureRecognizer:[self panGestureRecognizer]];
    }else{
        [self.view removeGestureRecognizer:[self panGestureRecognizer]];
    }
}
-(UIPanGestureRecognizer *)panGestureRecognizer{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, assoKeyPanGesture);
    if (!panGestureRecognizer) {
        panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panToBack:)];
        [panGestureRecognizer setDelegate:self];
        objc_setAssociatedObject(self, assoKeyPanGesture, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
    }
    return panGestureRecognizer;
}
-(void)setStartPanPoint:(CGPoint)point{
    NSValue *startPanPointValue = [NSValue valueWithCGPoint:point];
    objc_setAssociatedObject(self, assoKeyStartPanPoint, startPanPointValue, OBJC_ASSOCIATION_RETAIN);
}
-(CGPoint)startPanPoint{
    NSValue *startPanPointValue = objc_getAssociatedObject(self, assoKeyStartPanPoint);
    if (!startPanPointValue) {
        return CGPointZero;
    }
    return [startPanPointValue CGPointValue];
}

-(void)panToBack:(UIPanGestureRecognizer*)pan{
    UIView *currentView=self.topViewController.view;
    if (self.panGestureRecognizer.state==UIGestureRecognizerStateBegan) {
        [self setStartPanPoint:currentView.frame.origin];
        CGPoint velocity=[pan velocityInView:self.view];
        if(velocity.x!=0){
            [self willShowPreViewController];
        }
        return;
    }
    CGPoint currentPostion = [pan translationInView:self.view];
    CGFloat xoffset = [self startPanPoint].x + currentPostion.x;
    CGFloat yoffset = [self startPanPoint].y + currentPostion.y;
    if (xoffset>0) {//向右滑
//        if (true) {
//            xoffset = xoffset>self.view.frame.size.width?self.view.frame.size.width:xoffset;
//        }else{
//            xoffset = 0;
//        }
    }else if(xoffset<0){//向左滑
        if (currentView.frame.origin.x>0) {
            xoffset = xoffset<-self.view.frame.size.width?-self.view.frame.size.width:xoffset;
        }else{
            xoffset = 0;
        }
    }
    if (!CGPointEqualToPoint(CGPointMake(xoffset, yoffset), currentView.frame.origin)) {
        [self layoutCurrentViewWithOffset:UIOffsetMake(xoffset, yoffset)];
    }
    if (self.panGestureRecognizer.state==UIGestureRecognizerStateEnded) {
        if (currentView.frame.origin.x==0) {
        }else{
            if (currentView.frame.origin.x<BackGestureOffsetXToBack){
//            if (CGRectContainsPoint(self.view.bounds, currentView.center)) {
                [self hidePreViewController];
            }else{
                [self showPreViewController];
            }
        }
    }
}

-(void)willShowPreViewController{
    NSInteger count=self.viewControllers.count;
    if (count>1) {
        UIViewController *currentVC = [self topViewController];
        UIViewController *preVC = [self.viewControllers objectAtIndex:count-2];
        [currentVC.view.superview insertSubview:preVC.view belowSubview:currentVC.view];
    }
}
-(void)showPreViewController{
    NSInteger count = self.viewControllers.count;
    if (count>1) {
        UIView *currentView = self.topViewController.view;
        NSTimeInterval animatedTime = 0;
        animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:animatedTime animations:^{
            [self layoutCurrentViewWithOffset:UIOffsetMake(self.view.frame.size.width, 0)];
        } completion:^(BOOL finished) {
            [self popViewControllerAnimated:false];
        }];
    }
}
-(void)hidePreViewController{
    NSInteger count = self.viewControllers.count;
    if (count>1) {
        UIViewController *preVC = [self.viewControllers objectAtIndex:count-2];
        UIView *currentView = self.topViewController.view;
        NSTimeInterval animatedTime = 0;
        animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:animatedTime animations:^{
            [self layoutCurrentViewWithOffset:UIOffsetMake(0, 0)];
        } completion:^(BOOL finished) {
            [preVC.view removeFromSuperview];
        }];
    }
}

-(void)layoutCurrentViewWithOffset:(UIOffset)offset{
    NSInteger count = self.viewControllers.count;
    if (count>1) {
        UIViewController *currentVC = [self topViewController];
        UIViewController *preVC = [self.viewControllers objectAtIndex:count-2];
        [currentVC.view setFrame:CGRectMake(offset.horizontal, self.view.bounds.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
        [preVC.view setFrame:CGRectMake(offset.horizontal/2-self.view.frame.size.width/2, self.view.bounds.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];
        if ([panGesture velocityInView:self.view].x < 600 && ABS(translation.x)/ABS(translation.y)>1) {
            return true;
        }
        return false;
    }
    return true;
}

@end
