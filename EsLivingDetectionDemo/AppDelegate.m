//
//  AppDelegate.m
//  EsLivingDetectionDemo
//
//  Created by ReidLee on 2020/12/23.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "EsRootViewController.h"
#import "RootViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    ViewController *viewController=[[ViewController alloc]init];
    EsRootViewController *esRoot=[[EsRootViewController alloc]initWithRootViewController:viewController];
    
//    RootViewController *rw = [[RootViewController alloc]init];
    self.window.rootViewController=esRoot;
    [self.window makeKeyAndVisible];
//    [rw presentViewController:esRoot animated:true completion:nil];
    return YES;
}
@end
