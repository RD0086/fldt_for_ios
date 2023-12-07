//
//  AliyunHttpClient.h
//  ios-ocr
//
//  Created by ReidLee on 2020/8/20.
//  Copyright © 2020 ReidLee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunHttpClient : NSObject

typedef void (^ClientCallback)(NSString* resultStr);

/// 调用阿里云服务（为了保护APPCODE,此段代码通常放在服务器端）
/// @param url 阿里云URL
/// @param body body字段数据
/// @param appcode APPCODE (切勿泄漏)
/// @param clientCallback 执行回调
+ (void) requestSync: (NSString*) url body: (NSString *)body appcode: (NSString*) appcode clientCallback:(ClientCallback) clientCallback;

@end

NS_ASSUME_NONNULL_END
