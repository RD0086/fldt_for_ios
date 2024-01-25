//
//  AliyunHttpClient.h
//  ios-ocr
//
//  Created by ReidLee on 2020/8/20.
//  Copyright © 2020 ReidLee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyHttpClient : NSObject

typedef void (^ClientCallback)(NSString* resultStr);

/// 认证初始化
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) init: (NSString *)body clientCallback:(ClientCallback) clientCallback;
    
/// 获取认证结果
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) verify: (NSString *)body clientCallback:(ClientCallback) clientCallback;

@end

NS_ASSUME_NONNULL_END
