//
//  ViewController.m
//  WKwebview
//
//  Created by 张君泽 on 16/9/21.
//  Copyright © 2016年 CloudEducation. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#define HTML @"<head></head><img src='http://www.nsu.edu.cn/v/2014v3/img/background/3.jpg' />"
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong)WKWebView *wkWebView;
@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     //想要JS交互,添加监听, 让JS调用原生方法;
    [self.wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"setTitle"];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"setTitle"];
    [self.wkWebView.configuration.userContentController removeAllUserScripts];
}
- (void)viewDidLoad {
    [super viewDidLoad];
     NSString *js = @"var count = document.images.length;for (var i = 0; i < count; i++) {var image = document.images[i];image.style.width=320;};window.alert('找到' + count + '张图');";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    [configuration.userContentController addUserScript:script];
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    [_wkWebView loadHTMLString:HTML baseURL:nil];
    [self.view addSubview:_wkWebView];

    
      // Do any additional setup after loading the view, typically from a nib.
}
- (void)loadBaiDu{
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.preferences = [WKPreferences new];
    configuration.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    configuration.preferences.javaScriptEnabled = YES;
    //不通过用户交互,是否可以打开窗口
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [_wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    _wkWebView.backgroundColor = [UIColor cyanColor];
    
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    [self.view addSubview:_wkWebView];

}
#pragma mark WKScriptMessageHandler
/** 通过网页返回的方法名调用我们写的方法 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"setTitle"]) {
        NSLog(@"调用方法");
    }
    #pragma mark    如果JS想要我们给他们传递参数-----下面代码效果:通过JS代码的setUser(参数)方法把原生App的一些没内容传递过去(参数类型,约定好+++++++一般是字符串)
    [self.wkWebView evaluateJavaScript:[NSString stringWithFormat:@"setUser(%@)",@"传递的参数"] completionHandler:nil];
}
#pragma mark WKNavigationDelegate-- 常用加载页面基本代理方法<可以自己添加监听,实现页面上方的加载页面进度progress进度条的效果, 自行尝试>
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{//加载临时导航条
    NSLog(@"开始加载临时导航条");
    
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
     NSLog(@"%s百度界面内容返回", __FUNCTION__);
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{//provisional:临时
    NSLog(@"开始加载临时导航条失败");
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"%s百度界面加载完成", __FUNCTION__);
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s百度界面加载失败", __FUNCTION__);
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求之后调用");
}
//截取HTML5页面的跳转事件----接到响应时机
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    if ([navigationResponse.response.URL.host.lowercaseString containsString:@"baidu"]) {
        //禁止跳转
        decisionHandler(WKNavigationResponsePolicyCancel);
        NSLog(@"过滤跳转");
        return;
    }
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
////    [self.storyboard instantiateViewControllerWithIdentifier:@"12345"];
//}
#pragma mark WKUIDelegate

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
