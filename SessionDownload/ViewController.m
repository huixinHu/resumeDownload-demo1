//
//  ViewController.m
//  SessionDownload
//
//  Created by commet on 17/3/30.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "ViewController.h"
#import "SessionManager.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
@property (weak, nonatomic) IBOutlet UIProgressView *progressIndicator;

@property (nonatomic ,strong)SessionManager *shareSession;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.shareSession = [SessionManager shareSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressUpdate:) name:@"progressNotification" object:nil];
}

- (void)progressUpdate:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat fProgress = [userInfo[@"progress"] floatValue];
    self.progressLab.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.progressIndicator.progress = fProgress;
}

- (IBAction)start:(id)sender {
//    http://p2.ifengimg.com/web/2017_13/4369db6c66bb9e1_w633_h315.jpg
    [self.shareSession downloadWithUrl:@"https://dldir1.qq.com/music/clntupate/mac/QQMusic4.2.3Build02.dmg"];
}
- (IBAction)pause:(id)sender {
    [self.shareSession pause];
}

- (IBAction)resumeDownload:(id)sender {
    [self.shareSession resumeDownload];
}

- (void)dealloc{
    
}

@end
