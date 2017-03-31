//
//  AppDelegate.m
//  SessionDownload
//
//  Created by commet on 17/3/30.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "AppDelegate.h"
#import "SessionManager.h"
@interface AppDelegate ()
@property (nonatomic ,strong)NSMutableDictionary *completionHandlerDictionary;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.completionHandlerDictionary = [NSMutableDictionary dictionary];
    
    [[SessionManager shareSession]backgroundSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callCompletionHandlerForSession:) name:@"completionHandlerNotification" object:nil];
    return YES;
}

- (void)callCompletionHandlerForSession:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *sessionConfigID = userInfo[@"downloadID"];
    void (^completionHandler)() = [self.completionHandlerDictionary objectForKey:sessionConfigID];
    
    if (completionHandler) {
        [self.completionHandlerDictionary removeObjectForKey: sessionConfigID];
        NSLog(@"Calling completion handler for session %@", sessionConfigID);
        completionHandler();
    }
}

//程序被系统杀死才会调用
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    NSURLSession *backgroundSession = [[SessionManager shareSession]backgroundSession];
    NSLog(@"Rejoining session with identifier %@ %@", identifier, backgroundSession);
    
    // 保存 completion handler 以在处理 session 事件后更新 UI
    if ([self.completionHandlerDictionary objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    [self.completionHandlerDictionary setObject:completionHandler forKey:identifier];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
