//
//  RootView.m
//  ReuseUIScrollView
//
//  Created by LiiHen on 15/8/19.
//  Copyright (c) 2015年 吕涵. All rights reserved.
//

#import "RootView.h"

@implementation RootView

- (UIScrollView *)imageScrollView {
    if (!_imageScrollView) {
        self.imageScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.imageScrollView.pagingEnabled = YES;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.showsVerticalScrollIndicator = NO;
        self.imageScrollView.directionalLockEnabled = YES;
    }
    return _imageScrollView;
}



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageScrollView];
    }
    return self;
}

- (void)dealloc {
    
}

@end
