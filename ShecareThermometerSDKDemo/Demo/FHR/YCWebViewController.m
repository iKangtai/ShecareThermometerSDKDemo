//
//  YCWebViewController.m
//  SCBLESDK
//
//  Created by mac on 2021/4/1.
//

#import "YCWebViewController.h"
#import <WebKit/WebKit.h>
#import "sys/sysctl.h"

@interface YCWebViewController ()<WKNavigationDelegate, UIGestureRecognizerDelegate>

///  webView
@property (nonatomic, strong) WKWebView *webView;
@property (assign, nonatomic) double lastProgress;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation YCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self loadWebView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.progressView.alpha = 0.0;
}

-(void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

-(void)setupUI {
    [self webView];
}

- (void)updateProgress:(double)progress {
    self.progressView.alpha = 1.0;
    if (progress > self.lastProgress) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    } else {
        [self.progressView setProgress:self.webView.estimatedProgress];
    }
    self.lastProgress = progress;
    if (progress >= 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.alpha = 0.0;
            [self.progressView setProgress:0.0];
            self.lastProgress = 0.0;
        });
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (keyPath == nil) {
        return;
    }
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self updateProgress:self.webView.estimatedProgress];
    } else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WebView Delegate

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateProgress:webView.estimatedProgress];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateProgress:webView.estimatedProgress];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self handleError:error];
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self handleError:error];
}

-(void)handleError:(NSError *)error {
    [self updateProgress:self.webView.estimatedProgress];
    if (error.code == -999) {
        NSAssert(true, @"Network Error: -999");
        return;
    }
    
    NSLog(@"Error: %@", error);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)loadWebView {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
//    BLEInfo(@"Will load URL: %@", self.url.absoluteString);
    [self.webView loadRequest:request];
}

-(void)reload {
    [self.webView reload];
}

#pragma mark - lazy load

-(NSString *)getMachineInfo {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

-(WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.suppressesIncrementalRendering = YES;
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.navigationDelegate = self;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSString *appName = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey];
        NSString *appVersion =  [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey];
        NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@)", appName, appVersion, [self getMachineInfo], [[UIDevice currentDevice] systemVersion]];
        _webView.customUserAgent = userAgent;
        
        [self.view addSubview:_webView];
        _webView.translatesAutoresizingMaskIntoConstraints = false;
        if (@available(iOS 11.0, *)) {
            [_webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
            [_webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = true;
        } else {
            [_webView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = true;
            [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = true;
        }
        [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = true;
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = true;
    }
    return _webView;
}

-(UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.tintColor = [UIColor colorWithRed:(0x5B/255.0) green:(0xDD/255.0) blue:(0x67/255.0) alpha:1.0];
        _progressView.trackTintColor = [UIColor clearColor];
        [self.view addSubview:_progressView];
        _progressView.translatesAutoresizingMaskIntoConstraints = false;
        if (@available(iOS 11.0, *)) {
            [_progressView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
        } else {
            [_progressView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = true;
        }
        [_progressView.heightAnchor constraintEqualToConstant:3].active = true;
        [_progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = true;
        [_progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = true;
    }
    return _progressView;
}

@end
