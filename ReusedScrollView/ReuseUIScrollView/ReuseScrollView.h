//
//  ReuseScrollView.h
//  ReuseUIScrollView
//
//  Created by LiiHen on 15/8/19.
//  Copyright (c) 2015年 吕涵. All rights reserved.
//

#import <UIKit/UIKit.h>

//重用的scrollView
@interface ReuseScrollView : UIScrollView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSInteger index;
@end
