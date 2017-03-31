//
//  SessionManager.h
//  SessionDownload
//
//  Created by commet on 17/3/30.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SessionManager : NSObject
+ (instancetype)shareSession;

- (NSURLSession *)backgroundSession;

- (void)downloadWithUrl:(NSString *)urlStr;

- (void)pause;

- (void)resumeDownload;
@end
