//
//  DownloadView.m
//  DownloadLearn
//
//  Created by Jason on 2023/5/14.
//

#import "DownloadView.h"

#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>


@interface DownloadView()

@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) UILabel *progressLabel;
@property(nonatomic, strong) UIButton *startButton;
@property(nonatomic, strong) UIButton *pauseButton;
@property(nonatomic, strong) UIButton *startAndPauseButton;
@property (nonatomic, assign) BOOL isPaused;

/** AFNetworking断点下载（支持离线）需用到的属性 **********/
/** 文件的总长度 */
@property (nonatomic, assign) NSInteger fileLength;
/** 当前下载长度 */
@property (nonatomic, assign) NSInteger currentLength;
/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
/* AFURLSessionManager */
@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation DownloadView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupViews];
        [self addKVO];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.progressView];
    [self addSubview:self.progressLabel];
    [self addSubview:self.startButton];
    [self addSubview:self.pauseButton];
    [self addSubview:self.startAndPauseButton];
    
    [self makeConstraints];
}

- (void)makeConstraints {
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(200);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(@200);
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).offset(2);
        make.centerX.equalTo(self.progressView);
        make.height.mas_equalTo(@20);
    }];
    
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressLabel).offset(20);
        make.height.mas_equalTo(@50);
        make.width.mas_equalTo(@100);
        make.centerX.equalTo(self.progressView.mas_left);
    }];
    
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).offset(20);
        make.height.mas_equalTo(@50);
        make.width.mas_equalTo(@100);
        make.centerX.equalTo(self.progressView.mas_right);
    }];
    
    [self.startAndPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pauseButton.mas_bottom).offset(20);
        make.height.mas_equalTo(@50);
        make.width.mas_equalTo(@100);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self loadData];
}

- (void) loadData{
    self.isPaused = NO;
}

- (void)addKVO{
    // 添加观察者
    [self addObserver:self forKeyPath:@"progressView.progress" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progressView.progress"]) {
        if ([change[NSKeyValueChangeNewKey] isEqualToNumber:@(1.0)]) {
            [self pauseButtonClick];
        }
    }
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"progressView.progress"];
}

/**
 * 获取已下载的文件大小
 */
- (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        // 获取文件属性
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

#pragma mark - buttonClick

-  (void)startButtonClick{
    NSLog(@"startButtonClick");

    // 沙盒文件路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"licecap132.dmg"];
    
    NSInteger currentLength = [self fileLengthForPath:path];
    if (currentLength > 0) {  // [继续下载]
        self.currentLength = currentLength;
    }
    
    [self.downloadTask resume];
}

-  (void)pauseButtonClick{
    NSLog(@"pauseButtonClick");
    [self.downloadTask suspend];
    self.downloadTask = nil;
    
    [self setStartAndPauseButtonTitle:@"开始" ImageName:@"desktopPic.JPG"];
}

-  (void)startAndPauseButtonClick{
    NSLog(@"startAndPauseButtonClick");
    self.isPaused = !self.isPaused;
    if (self.isPaused) {
//        [_startAndPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
//        [_startAndPauseButton setBackgroundImage:[UIImage imageNamed:@"stopImage.jpg"] forState:UIControlStateNormal];
        [self setStartAndPauseButtonTitle:@"暂停" ImageName:@"stopImage.jpg"];
        [self startButtonClick];
    }else{
//        [_startAndPauseButton setTitle:@"开始" forState:UIControlStateNormal];
//        [_startAndPauseButton setBackgroundImage:[UIImage imageNamed:@"desktopPic.JPG"] forState:UIControlStateNormal];
        [self setStartAndPauseButtonTitle:@"开始" ImageName:@"desktopPic.JPG"];
        [self pauseButtonClick];
    }
}

- (void)setStartAndPauseButtonTitle:(NSString *)title ImageName:(NSString *)imageName{
    [_startAndPauseButton setTitle:title forState:UIControlStateNormal];
    [_startAndPauseButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

#pragma mark - 懒加载

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor redColor];
    }
    return _progressView;
}

- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text = @"当前下载进度:00.00%";
        _progressLabel.textColor = [UIColor blackColor];
        _progressLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _progressLabel;
}

- (UIButton *)startButton{
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _startButton.imageView.image = [UIImage imageNamed:@"desktopPic.JPG"];
        [_startButton setBackgroundImage:[UIImage imageNamed:@"desktopPic.JPG"] forState:UIControlStateNormal];
        [_startButton setTitle:@"下载" forState:UIControlStateNormal];
        _startButton.layer.cornerRadius = 10;
//        _startButton.clipsToBounds = YES;
        _startButton.layer.masksToBounds = YES;
        [_startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton *)pauseButton{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_pauseButton setBackgroundImage:[UIImage imageNamed:@"desktopPic.JPG"] forState:UIControlStateNormal];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        _pauseButton.layer.cornerRadius = 10;
        [_pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _pauseButton.layer.masksToBounds = YES;
    }
    return _pauseButton;
}

- (UIButton *)startAndPauseButton{
    if (!_startAndPauseButton) {
        _startAndPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _startAndPauseButton.layer.cornerRadius = 10;
        [_startAndPauseButton addTarget:self action:@selector(startAndPauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (self.isPaused) {
            [_startAndPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
            [_startAndPauseButton setBackgroundImage:[UIImage imageNamed:@"stopImage.jpg"] forState:UIControlStateNormal];
        }else{
            [_startAndPauseButton setTitle:@"开始" forState:UIControlStateNormal];
            [_startAndPauseButton setBackgroundImage:[UIImage imageNamed:@"desktopPic.JPG"] forState:UIControlStateNormal];
        }
        [_startAndPauseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _startAndPauseButton.titleLabel.font = [UIFont systemFontOfSize:26];
        _startAndPauseButton.layer.masksToBounds = YES;
    }
    return _startAndPauseButton;
}

// 下载相关懒加载
/**
 * manager的懒加载
 */
- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}

/**
 * downloadTask的懒加载
 */
- (NSURLSessionDataTask *)downloadTask {
    if (!_downloadTask) {
        // 1. 创建下载URL
        NSURL *url = [NSURL URLWithString:@"https://www.cockos.com/licecap/licecap132.dmg"];
        
        // 2. 创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置HTTP请求头中的Range(只请求指定部分的实体)
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        __weak typeof(self) weakSelf = self;
        
        // 3.1 调用manager中的dataTaskWithRequest方法构建downloadTask
        _downloadTask = [self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSLog(@"dataTaskWithRequest");
            
            // 设置完成回调（不然完成一次之后，下次就下载不了了）
            // 清空长度
            weakSelf.currentLength = 0;
            weakSelf.fileLength = 0;
            
            // 关闭fileHandle
            [weakSelf.fileHandle closeFile];
            weakSelf.fileHandle = nil;
            
        }];
        
        // 3.2 设置响应block（文件长度、文件路径、文件句柄、返回值）
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            NSLog(@"NSURLSessionResponseDisposition");
            
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.fileLength = response.expectedContentLength + self.currentLength;
            
            // 沙盒文件路径
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"licecap132.dmg"];
            
            NSLog(@"File downloaded to: %@",path);
            
            NSFileManager *manager = [NSFileManager defaultManager];
            
            if (![manager fileExistsAtPath:path]) {
                // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
                [manager createFileAtPath:path contents:nil attributes:nil];
            }
            
            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            
            /*
             NSURLSessionResponseCancel：取消请求并关闭连接。
             NSURLSessionResponseAllow：继续处理请求。
             NSURLSessionResponseBecomeDownload：将请求转化为下载任务。
             */
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        
        // 3.3 设置数据block（根据文件句柄来判断从哪里开始写）
        [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            NSLog(@"setDataTaskDidReceiveDataBlock");
        
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];
            
            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];
            
            // 拼接文件总长度
            weakSelf.currentLength += data.length;
            
            // 获取主线程，不然无法正确显示进度。
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                // 下载进度
                if (weakSelf.fileLength == 0) {
                    weakSelf.progressView.progress = 0.0;
                    weakSelf.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:00.00%%"];
                } else {
                    weakSelf.progressView.progress =  1.0 * weakSelf.currentLength / weakSelf.fileLength;
                    weakSelf.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * weakSelf.currentLength / weakSelf.fileLength];
//                    // 下载完成之后，再点击下载会出现下载进度为100.04%，并且文件已损坏（但文件下载进度是100点%的时候是好的）
//                    // 这个解决方案不行，只解决了显示的问题，没解决下载的问题
//                    if (weakSelf.progressView.progress > 1.0) {
//                        weakSelf.progressView.progress = 1.00;
//                    }
                    
//                    if (weakSelf.progressView.progress >= 1.0) {
//                        // 下载完成后的处理
//                        [weakSelf pauseButtonClick];
//                        [weakSelf.fileHandle closeFile];
//                        weakSelf.fileHandle = nil;
//                        weakSelf.downloadTask = nil;
////                        weakSelf.progressLabel.text = @"下载已完成";
//                    }
                }
            }];
            
        }];
    }
    return _downloadTask;
}



@end
