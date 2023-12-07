//
//  AliyunHttpClient.m
//  ios-ocr
//
//  Created by ReidLee on 2020/8/20.
//  Copyright © 2020 ReidLee. All rights reserved.
//

#import "AliyunHttpClient.h"

@implementation AliyunHttpClient

/// 调用阿里云服务（为了保护APPCODE,此段代码通常放在服务器端）
/// @param url 阿里云URL
/// @param body body字段数据
/// @param appcode APPCODE (切勿泄漏)
/// @param clientCallback 执行回调
+ (void) requestSync: (NSString*) url body: (NSString *)body appcode: (NSString*) appcode clientCallback:(ClientCallback) clientCallback
{
    NSLog(@"bodyString = %@", body);
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
    
    NSString* appcodeStr = [[NSString alloc] initWithFormat:@"APPCODE %@",appcode];
    [nsMutableURLRequest setValue: appcodeStr forHTTPHeaderField:@"Authorization"];
    //测试环境
//    [nsMutableURLRequest addValue:@"TEST" forHTTPHeaderField:@"X-Ca-Stage"];
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

@end
