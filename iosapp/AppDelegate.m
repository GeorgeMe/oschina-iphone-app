//
//  AppDelegate.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "AppDelegate.h"
#import "SwipeableViewController.h"
#import "TweetsViewController.h"
#import "PostsViewController.h"
#import "UIColor+Util.h"

@interface AppDelegate () <UIApplicationDelegate,UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SwipeableViewController *tweetsSVC = [[SwipeableViewController alloc] initWithTitle:@"动弹"
                                                                           andSubTitles:@[@"最新动弹", @"热门动弹", @"我的动弹"]
                                                                         andControllers:@[
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeAllTweets],
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeHotestTweets],
                                                                                          [[TweetsViewController alloc] initWithTweetsType:TweetsTypeOwnTweets],
                                                                                          ]];
    
    SwipeableViewController *postsSVC = [[SwipeableViewController alloc] initWithTitle:@"讨论区"
                                                                          andSubTitles:@[@"问答", @"分享", @"综合", @"职业", @"站务"]
                                                                        andControllers:@[
                                                                                         [[PostsViewController alloc] initWithPostsType:PostsTypeQA],
                                                                                         [[PostsViewController alloc] initWithPostsType:PostsTypeShare],
                                                                                         [[PostsViewController alloc] initWithPostsType:PostsTypeSynthesis],
                                                                                         [[PostsViewController alloc] initWithPostsType:PostsTypeSiteManager],
                                                                                         [[PostsViewController alloc] initWithPostsType:PostsTypeCaree]
                                                                                         ]];
    
    UINavigationController *tweetsNav = [[UINavigationController alloc] initWithRootViewController:tweetsSVC];
    UINavigationController *postsNav = [[UINavigationController alloc] initWithRootViewController:postsSVC];
    
    self.tabBarController = [UITabBarController new];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[tweetsNav, postsNav];
    
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"动弹"];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"讨论区"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHex:0x008000]];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];               //UIColorFromRGB(0xdadada)
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
