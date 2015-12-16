//
//  ReuseScrollView.m
//  ReuseUIScrollView
//
//  Created by LiiHen on 15/8/19.
//  Copyright (c) 2015年 吕涵. All rights reserved.
//

#import "ReuseScrollView.h"

@implementation ReuseScrollView

- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _imageView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)dealloc {
}

@end
