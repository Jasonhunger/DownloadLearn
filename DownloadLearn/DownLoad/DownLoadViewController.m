//
//  DownLoadViewController.m
//  DownloadLearn
//
//  Created by Jason on 2023/5/14.
//

#import "DownLoadViewController.h"

#import "DownloadView.h"

#import <Masonry/Masonry.h>

@interface DownLoadViewController ()

@property(nonatomic, strong) DownloadView *dlView;

@end

@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
    
}

- (void)setupViews {
    
    [self.view addSubview:self.dlView];
    
    [self makeConstraints];
}

- (void)makeConstraints {
    [self.dlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.width.equalTo(self.view);
//        make.top.left.equalTo(self.view);
//        make.height.width.mas_equalTo(@200);
    }];
}

# pragma mark - 懒加载
- (DownloadView *)dlView{
    if (!_dlView) {
        _dlView = [[DownloadView alloc] init];
    }
    return _dlView;
}



@end
