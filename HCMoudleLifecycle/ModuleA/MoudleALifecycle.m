//
//  MoudleALifecycle.m
//  HCMoudleLifecycle
//
//  Created by hechao on 2019/2/15.
//  Copyright © 2019 hechao. All rights reserved.
//

#import "MoudleALifecycle.h"

@implementation MoudleALifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // do sth that your module needs,eg: fecth module configs
    NSLog(@"%@--%s", NSStringFromClass(self.class), __FUNCTION__);
    
    return YES;
}

@end
