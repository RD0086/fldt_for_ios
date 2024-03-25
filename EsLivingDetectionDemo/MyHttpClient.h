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

/// 活体检测 认证初始化
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) ldtInit: (NSString *)body clientCallback:(ClientCallback) clientCallback;
    
/// 活体检测 获取认证结果
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) ldtVerify: (NSString *)body clientCallback:(ClientCallback) clientCallback;

/// 实名认证 认证初始化
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) rpInit: (NSString *)body clientCallback:(ClientCallback) clientCallback;
    
/// 实名认证 获取认证结果
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) rpVerify: (NSString *)body clientCallback:(ClientCallback) clientCallback;

// json字符串转dict字典
+ (NSDictionary *)json2Dict:(NSString *)json;

@end

NS_ASSUME_NONNULL_END
