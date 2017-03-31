//
//  SessionManager.m
//  SessionDownload
//
//  Created by commet on 17/3/30.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "SessionManager.h"

@interface SessionManager()<NSURLSessionDownloadDelegate>
@property (nonatomic ,strong)NSURLSession *backgroundSession;
@property (nonatomic ,strong)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic ,strong)NSData *resumeData;
@end

@implementation SessionManager
+ (instancetype)shareSession{
    static SessionManager* _instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (NSURLSession *)backgroundSession{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundSessionID"];//iOS8以前用+ (NSURLSessionConfiguration *)backgroundSessionConfiguration:(NSString *)identifier
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}

- (void)downloadWithUrl:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    //cancel last download task

    self.downloadTask = [self.backgroundSession downloadTaskWithURL:url];
    [self.downloadTask resume];
}

- (void)pause{
    __weak typeof(self) ws = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        //resumeData:续传的数据
        NSLog(@"数据长度 %tu", resumeData.length);
        ws.resumeData = resumeData;
        ws.downloadTask = nil;
    }];
}

- (void)resumeDownload{
    if (_resumeData == nil) {
        NSLog(@"没有暂停的任务");
        return;
    }
    //iOS之后的resumeData好像需要特别处理。待试验
    //cancelByProducingResumeData:之后task要重新创建
    self.downloadTask  = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
    [self.downloadTask resume];
    //self.resumeData清空
    self.resumeData = nil;
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {        
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            self.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
//            self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];//先不要新建task,它会在程序重启后就马上开启继续下载
//            [self.downloadTask resume];//
        }
    }else{
        NSLog(@"下载完成");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载完成"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//程序被系统杀死调用
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"%s",__func__);
    NSDictionary *userInfo = @{@"downloadID":session.configuration.identifier};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"completionHandlerNotification" object:nil userInfo:userInfo];
}

#pragma mark NSURLSessionDownloadDelegate
//下载完成时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"download finish %@",location);
    //生成沙盒的路径，对数据进行保存
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docs[0] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSURL *toURL = [NSURL fileURLWithPath:path];
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:toURL error:&error];
}

//跟踪下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float progress = (float)totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"%f",progress);
    //这里加一个通知吧
    NSDictionary *userInfo = @{@"progress": [[NSNumber alloc]initWithFloat:progress]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"progressNotification" object:nil userInfo:userInfo];
}

//下载恢复（resume）时调用 Tells the delegate that the download task has resumed downloading.在调用downloadTaskWithResumeData:或者 downloadTaskWithResumeData:completionHandler: 方法之后这个代理方法会被调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"%s------------fileOffset:%lld expectedTotalBytes:%lld", __func__,fileOffset,expectedTotalBytes);
}
@end
