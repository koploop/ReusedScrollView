//
//  RootViewController.m
//  ReuseUIScrollView
//
//  Created by LiiHen on 15/8/19.
//  Copyright (c) 2015年 吕涵. All rights reserved.
//

#import "RootViewController.h"
#import "RootView.h"
#import "ReuseScrollView.h"

@interface RootViewController ()<UIScrollViewDelegate>
{
    NSInteger _pageIndex;          //存储索引
    NSMutableSet *_recycledPages;  //可重用的页面
    NSMutableSet *_visiblePages;   //现有的页面
    
    CGFloat _currentScale;     //记录scrollView的当前缩放比例
    
}
@property (nonatomic, strong) NSMutableArray *imageArr;     //图片资源
@end

@implementation RootViewController

#pragma mark - life cycle
- (void)loadView {
    self.rootView = [[RootView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = self.rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _pageIndex = 0;
    [self configureImageScrollView];
    [self addGestureToScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && !self.view.window) {
        //安全移除掉根视图
        self.view = nil;
    }
}

#pragma mark - lazy load
- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        self.imageArr = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            NSString *imageStr = [NSString stringWithFormat:@"per%d.jpg", i];
            [self.imageArr addObject:imageStr];
        }
    }
    return _imageArr;
}

#pragma mark - 配置scrollView
- (void)configureImageScrollView {
    self.rootView.imageScrollView.contentSize = CGSizeMake(self.imageArr.count * 375, 667);
    self.rootView.imageScrollView.delegate = self;
    //重用
    _recycledPages = [NSMutableSet setWithCapacity:0];
    _visiblePages = [NSMutableSet setWithCapacity:0];
    [self tilePages];
    
}

#pragma mark - 处理scrollView重用

- (void)tilePages {
    //计算哪些是现有页面
    CGRect visibleBounds = self.rootView.imageScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex = MIN(lastNeededPageIndex, (int)self.imageArr.count - 1);
    //重用不再使用的页面
    for (ReuseScrollView *reuseScroll in _visiblePages) {
        //不显示的判断条件
        if (reuseScroll.index < firstNeededPageIndex || reuseScroll.index > lastNeededPageIndex) {
            //将没有显示的ImageView保存在recycledPages
            [_recycledPages addObject:reuseScroll];
            //并且从scrollView移除
            [reuseScroll removeFromSuperview];
        }
    }
    //从_visiblePages中删除包含_recycledPages中的所有元素
    [_visiblePages minusSet:_recycledPages];
    
    while (_recycledPages.count > 2) {
        [_recycledPages removeObject:[_recycledPages anyObject]];
    }
    
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index ++) {
        if (![self isDisplayingPageForIndex:index]) {
            ReuseScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[ReuseScrollView alloc] init];
                page.bounces = YES;
                page.delegate = self;
                page.showsHorizontalScrollIndicator = NO;
                page.showsVerticalScrollIndicator = NO;
                page.directionalLockEnabled = YES;
                page.userInteractionEnabled = YES;
                page.zoomScale = 1.0;
                page.minimumZoomScale = 1.0;
                page.maximumZoomScale = 2.0;
            }
            //配置index对应的scrollView
            [self configurePage:page forIndex:index];
            //将page加入到visiblePages集合里
            [_visiblePages addObject:page];
            //将scrollView加入到大的scrollView中
            [self.rootView.imageScrollView addSubview:page];
        }
    }
}

- (ReuseScrollView *)dequeueRecycledPage {
    //查看是否有重用对象
    ReuseScrollView *page = [_recycledPages anyObject];
    if (page) {
        //返回重用对象,并从重用集合中删除
        [_recycledPages removeObject:page];
    }
    return page;
}
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (ReuseScrollView *page in _visiblePages) {
        if (page.index == index) { //如果index所对应的ImageView在可见数组中,将标志位标记为YES,否则返 回NO
            foundPage = YES;
            break;
        }
    }
    return foundPage;
    
}
- (void)configurePage:(ReuseScrollView *)page forIndex:(NSUInteger)index  {
    page.index = index; //这句要写，不然第一张会消失
    page.zoomScale = 1.0;
    page.frame = CGRectMake(375 * index, 0, 375, 667);
      page.imageView.contentMode = UIViewContentModeScaleAspectFit;
    page.imageView.frame = self.view.bounds;
    page.imageView.image = [UIImage imageNamed:self.imageArr[index]];
  

    _currentScale = 1.0;

}


#pragma mark - Delegate
#pragma mark - pageDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    
}
#pragma mark - _imageScrollViewDelegate
//结束缩放时让imageView居中
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    _currentScale = scale;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    ((UIImageView *)[[scrollView subviews] firstObject]).center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
}

//要实现缩放,此方法必须要重写
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [[scrollView subviews] firstObject];
}


#pragma mark - 给图片添加手势

- (void)addGestureToScrollView {
    //双击缩放
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
//    [[[self.rootView.imageScrollView subviews] firstObject] addGestureRecognizer:doubleTap];
    [self.rootView.imageScrollView addGestureRecognizer:doubleTap]; //给最外层的scrollView添加手势,而非内层scrollView

}


#pragma mark - handle action
//在scrollView的delegate里面记录当前倍率,再通过判断,是放大还是缩小
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if (_currentScale == 1.0) {
        [[self.rootView.imageScrollView subviews][0] setZoomScale:2.0 animated:YES];
    } else {
        [[self.rootView.imageScrollView subviews][0] setZoomScale:1.0 animated:YES];
    }
}



@end
