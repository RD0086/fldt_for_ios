//
//  AliyunHttpClient.m
//  ios-ocr
//
//  Created by ReidLee on 2020/8/20.
//  Copyright © 2020 ReidLee. All rights reserved.
//

#import "MyHttpClient.h"

@implementation MyHttpClient

// WARNNING！！ : 为了保护密钥，这段代码建议写在服务器端，这里为了方便演示，把密钥写客户端了。

// TODO 阿里云接入，请替换这里的APPCODE （为了保护APPCODE,此段代码通常放在服务器端）
#define APPCODE @"TODO"
#define ALIYUN_INIT_URL @"https://eface.market.alicloudapi.com/init"
#define ALIYUN_VERIFY_URL @"https://eface.market.alicloudapi.com/verify"
// TODO 非阿里云接入，请从管理控制台查询并替换这里的 APPCODE 和密钥, 参考文档： https://esandinfo.yuque.com/yv6e1k/aa4qsg/cdwove
#define E_APPCODE @"TODO"
#define E_SECRET @"TODO"

/// 服务调用
/// @param url 阿里云URL
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) requestSync: (NSString*) url body: (NSString *)body clientCallback:(ClientCallback) clientCallback
{
    NSLog(@"body内容 = %@", body);
    NSURL * _nsURL = [NSURL URLWithString: url];
    NSMutableURLRequest *nsMutableURLRequest = [NSMutableURLRequest requestWithURL:_nsURL
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:10];
    //POST请求
    [nsMutableURLRequest setHTTPMethod:@"POST"];
    //把bodyString转换为NSData数据
    body = [body stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSData *bodyData =  [body dataUsingEncoding:NSUTF8StringEncoding];
    [nsMutableURLRequest addValue:@"application/x-www-form-urlencoded ;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //防重放
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    [nsMutableURLRequest setValue:dateStr forHTTPHeaderField:@"X-Ca-Nonce"];
    
    NSString* appcodeStr = nil;
    if ([url containsString:@"alicloudapi.com"]) {
        appcodeStr = [[NSString alloc] initWithFormat:@"APPCODE %@",APPCODE];
    } else {
        appcodeStr = [[NSString alloc] initWithFormat:@"APPCODE %@",E_SECRET];
    }

    [nsMutableURLRequest setValue: appcodeStr forHTTPHeaderField:@"Authorization"];
    //body 数据
    [nsMutableURLRequest setHTTPBody:bodyData];
    //创建任务
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:nsMutableURLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@",((NSHTTPURLResponse*)response).allHeaderFields);
            NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            NSLog(@"%@", error);
            NSString* resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            clientCallback(resultStr);
        }else{
            clientCallback(nil);
        }
    }];
    //开启网络任务
    [task resume];
}

/// 活体检测-初始化
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) ldtInit: (NSString *)body clientCallback:(ClientCallback) clientCallback {
    NSString* url = nil;
    if ([APPCODE hasPrefix:@"TODO"] && ([E_APPCODE hasPrefix:@"TODO"] && [E_SECRET hasPrefix:@"TODO"])) {
        NSLog(@"如果是阿里云网关接入，请先设置 APPCODE , 如果非阿里云网关接入，请先设置 E_APPCODE, E_SECRET ， 如有疑问请联系 ：13691664797");
        clientCallback(nil);
        return;
    }
    
    if (![APPCODE hasPrefix:@"TODO"]) {
        url = ALIYUN_INIT_URL;
    } else {
        url = [[NSString alloc] initWithFormat:@"https://edis.esandcloud.com/gateways?APPCODE=%@&ACTION=%@",E_APPCODE, @"livingdetection/livingdetect/init"];
    }
    
    [MyHttpClient requestSync: url body:body clientCallback:clientCallback];
}

/// 活体检测-获取认证结果
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) ldtVerify: (NSString *)body clientCallback:(ClientCallback) clientCallback {
    NSString* url = nil;
    if (![APPCODE hasPrefix:@"TODO"]) {
        url = ALIYUN_VERIFY_URL;
    } else {
        url = [[NSString alloc] initWithFormat:@"https://edis.esandcloud.com/gateways?APPCODE=%@&ACTION=%@",E_APPCODE, @"livingdetection/livingdetect/verify"];
    }
    
    [MyHttpClient requestSync: url body:body clientCallback:clientCallback];
}


/// 实名认证-初始化
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) rpInit: (NSString *)body clientCallback:(ClientCallback) clientCallback {
    NSString* url = nil;
    if ([APPCODE hasPrefix:@"TODO"] && ([E_APPCODE hasPrefix:@"TODO"] && [E_SECRET hasPrefix:@"TODO"])) {
        NSLog(@"如果是阿里云网关接入，请先设置 APPCODE , 如果非阿里云网关接入，请先设置 E_APPCODE, E_SECRET ， 如有疑问请联系 ：13691664797");
        clientCallback(nil);
        return;
    }
    
    if (![APPCODE hasPrefix:@"TODO"]) {
        url = @"https://apprpv.market.alicloudapi.com/init";
    } else {
        url = [[NSString alloc] initWithFormat:@"https://edis.esandcloud.com/gateways?APPCODE=%@&ACTION=%@",E_APPCODE, @"livingdetection/rpverify/init"];
    }
    
    [MyHttpClient requestSync: url body:body clientCallback:clientCallback];
}

/// 实名认证-获取认证结果
/// @param body body字段数据
/// @param clientCallback 执行回调
+ (void) rpVerify: (NSString *)body clientCallback:(ClientCallback) clientCallback {
    NSString* url = nil;
    if (![APPCODE hasPrefix:@"TODO"]) {
        url = @"https://apprpv.market.alicloudapi.com/verify";
    } else {
        url = [[NSString alloc] initWithFormat:@"https://edis.esandcloud.com/gateways?APPCODE=%@&ACTION=%@",E_APPCODE, @"livingdetection/rpverify/verify"];
    }
    
    [MyHttpClient requestSync: url body:body clientCallback:clientCallback];
}


// json字符串转dict字典
+ (NSDictionary *)json2Dict:(NSString *)json
{
    if (json && json != nil &&(NSNull *)json != [NSNull null]&& 0 != json.length) {
        NSError *error;
        json = [json stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        json = [json stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            return nil;
        }

        return jsonDict;
    }

    return nil;
}
@end
