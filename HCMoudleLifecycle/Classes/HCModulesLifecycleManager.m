//
//  HCModulesLifecycleManager.m
//  HCMoudleLifecycle
//
//  Created by hechao on 2019/2/15.
//  Copyright © 2019 hechao. All rights reserved.
//

#import "HCModulesLifecycleManager.h"
#import <objc/runtime.h>
#import "HCModuleLifecycle.h"
#import <Aspects/Aspects.h>

@interface HCModulesLifecycleManager ()

@property (strong, nonatomic) NSMutableArray<NSObject *> *modules;

@end

@implementation HCModulesLifecycleManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HCModulesLifecycleManager *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    
    return _instance;
}

- (void)hookAppLifeCycleFromDelegate:(UIResponder<UIApplicationDelegate> *)appDelegate {
    unsigned int numOfModules = 0;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(@protocol(UIApplicationDelegate), NO, YES, &numOfModules);
    for (NSInteger i = 0; i < numOfModules; i++) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL selector = methodDescription.name;
        [appDelegate aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
            for (HCModuleLifecycle *moduleLifecycle in self.modules) {
                if ([moduleLifecycle isKindOfClass:[HCModuleLifecycle class]] && [moduleLifecycle respondsToSelector:selector]) {
                    NSInvocation *invocation = aspectInfo.originalInvocation;
                    invocation.target = moduleLifecycle;
                    invocation.selector = selector;
                    [invocation invoke];
                }
            }
        } error:nil];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _modules = [NSMutableArray arrayWithCapacity:0];
        // 获取所有实现了UIApplicationDelegate协议的HCModuleLifecycle的子类，就是app的模块
        int numberOfClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numberOfClasses);
        numberOfClasses = objc_getClassList(classes, numberOfClasses);
        
        if (numberOfClasses == 0) {
            free(classes);
        } else {
            Protocol *protocol = @protocol(UIApplicationDelegate);
            for (int i = 0; i < numberOfClasses; ++i) {
                Class candidateClass = classes[i];
                Class candidateOrSuper = candidateClass;
                while (candidateOrSuper != nil && class_conformsToProtocol(candidateOrSuper, protocol) == NO) {
                    candidateOrSuper = class_getSuperclass(candidateOrSuper);
                }
                
                if (candidateOrSuper != nil) {
                    id instance = [candidateClass new];
                    if ([instance isKindOfClass:[HCModuleLifecycle class]] && ![instance isMemberOfClass:[HCModuleLifecycle class]]) {
                        [_modules addObject:instance];
                    }
                }
            }
            
            free(classes);
        }
    }
    
    return self;
}

@end