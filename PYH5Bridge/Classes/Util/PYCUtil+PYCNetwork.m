//
//  PYUtil+Network.m
//  PYH5Bridge
//
//  Created by huwei on 2017/10/13.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import "PYCUtil+PYCNetwork.h"
#import "AFHTTPSessionManager.h"
#import "UIImage+PYCScaleSize.h"


static NSString *kTokenString               = @"token";
static NSString *kKeyString                 = @"key";
static NSString *kFileString                = @"file";
static NSString *kUrlString                 = @"url";
static NSString *kBodyString                = @"body";
static NSString *kWidthString               = @"width";
static NSString *kHeightString              = @"height";

@implementation PYCUtil (PYCNetwork)

/**
 Request请求封装
 
 @param dict H5返回参数
 @param resultData 回调的数据模型
 @param requestBlock 回调参数
 */
+ (void)actionRequest:(NSDictionary *)dict resultData:(PYCJSResultData *)resultData pyRequestBlock:(PYRequestBlock)requestBlock
{
    NSDictionary *data = dict[@"args"][@"data"];
    if (data == nil) {
        requestBlock([self generateBlockJSString:resultData.errorFunName
                                  responseObject:nil
                                           error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]
                                  sessionDataTask:nil]);
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
    NSString *postString = nil;
    //2.上传文件
    NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
    if ([data isKindOfClass:[NSString class]]) {//当取值为 String 时，不需要做任何处理，直接透传至服务器
        postString = [((NSString *)data) copy];
        [parametersDict setObject:postString forKey:@"data"];
    }
    
    NSString *urlString = [data objectForKey:@"url"];
    NSString *requestMethod = [data objectForKey:@"method"];
    NSDictionary *requestHeaders = [data objectForKey:@"headers"];
    NSNumber *timeout = [data objectForKey:@"timeout"];
    if (timeout != nil) {//设置超时时间
        manager.requestSerializer.timeoutInterval = timeout.doubleValue;
    }
    
    NSDictionary *dataDictionary = data[@"data"];
    //设置请求参数
    if ([dataDictionary isKindOfClass:[NSDictionary class]]) {
        [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [parametersDict setObject:obj forKey:key];
        }];
    }
    
    
    if ([requestMethod isEqualToString:@"POST"]) {
        //设置请求头
        if (requestHeaders != nil) {
            [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [manager.requestSerializer setValue:key forHTTPHeaderField:obj];
            }];
        }

        
        if (postString.length > 0 ) {//url请求
            [manager POST:urlString parameters:parametersDict progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                requestBlock([self generateBlockJSString:resultData.successFunName responseObject:responseObject error:nil sessionDataTask:task]);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
                if (statusCode >= 100) {
                    requestBlock([self generateBlockJSString:resultData.successFunName//成功的FUN
                                              responseObject:nil
                                                       error:error
                                             sessionDataTask:task]);
                }
                else
                    requestBlock([self generateBlockJSString:resultData.errorFunName//成功的FUN
                                              responseObject:nil
                                                       error:error
                                             sessionDataTask:task]);
            }];
        }
        else//传AFMultipartFormData请求
        {
            
            [manager POST:urlString parameters:parametersDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSArray *filesArray = [data objectForKey:@"files"];
                if ([filesArray isKindOfClass:[NSArray class]]) {
                    [filesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        //上传文件参数
                        NSString *localIdUrlString = [obj objectForKey:@"localId"];
                        NSString *fileName = localIdUrlString.length > 0?[[localIdUrlString componentsSeparatedByString:@"/"] lastObject]:@"";
                        
                        //这个就是参数
                        NSError *error;
                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:localIdUrlString] name:[obj objectForKey:@"dataKey"] fileName:fileName mimeType:@"image/png" error:&error];
                        if (error != nil) {
                            NSLog(@"upload file error: %@", error.localizedDescription);
                        }
//                        [formData appendPartWithFileData:imageData name:[obj objectForKey:@"dataKey"] fileName:fileName mimeType:@"image/png"];
                    }];
                }
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                static NSInteger nOldProgress = -1;
                //打印下上传进度
                NSInteger nProgress = 100.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                if (nProgress%5 == 0 && nProgress != nOldProgress) {//步进值设置为5
                    NSDictionary *progressDict = @{@"value":@(nProgress)};
                    NSString *jsString = [NSString stringWithFormat:@"%@(%@)", data[@"progress"], [self dataTojsonString:progressDict]];
                    nOldProgress = nProgress;
                    requestBlock(jsString);
                }
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                requestBlock([self generateBlockJSString:resultData.successFunName responseObject:responseObject error:nil sessionDataTask:task]);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
                if (statusCode >= 100) {
                    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                    
                    requestBlock([self generateBlockJSString:resultData.successFunName//成功的FUN
                                              responseObject:errorData
                                                       error:error
                                             sessionDataTask:task]);
                }
                else
                    requestBlock([self generateBlockJSString:resultData.errorFunName//成功的FUN
                                              responseObject:nil
                                                       error:error
                                             sessionDataTask:task]);
                
                
            }];
        }
        
    }
    else if ([requestMethod isEqualToString:@"GET"]) {
        [manager GET:urlString parameters:parametersDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            requestBlock([self generateBlockJSString:resultData.successFunName responseObject:responseObject error:nil sessionDataTask:task]);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSInteger statusCode = ((NSHTTPURLResponse *)operation.response).statusCode;
            if (statusCode >= 100) {
                requestBlock([self generateBlockJSString:resultData.successFunName responseObject:nil error:error sessionDataTask:operation]);
            }
            else
                requestBlock([self generateBlockJSString:resultData.errorFunName responseObject:nil error:error sessionDataTask:operation]);
        }];
    }
}

/**
 数据转化为JSON字符串
r @param object 数据对象
 @return JSON字符串
 */
+ (NSString *)dataTojsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (jsonData == nil) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

/**
 生成回调字符串

 @param funName 回调函数名称
 @param responseObject 后台返回的数据
 @param error 后台返回的错误
 @param sessionDataTask 包函HTTP状态码及头
 @return 返回回调字符串
 */
+ (NSString *)generateBlockJSString:(NSString *)funName
                     responseObject:(id)responseObject
                              error:(NSError *)error
                    sessionDataTask:(NSURLSessionTask *)sessionDataTask
{
    NSString *jsString = nil;
    NSInteger statusCode = ((NSHTTPURLResponse *)sessionDataTask.response).statusCode;
    NSString *returnString = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];
    if (statusCode >= 100) {//服务器有返回,则按照请求成功处理返回
        [returnDictionary setObject:@(statusCode) forKey:@"responseStatus"];
        if (returnString != nil) {
            [returnDictionary setObject:returnString forKey:@"responseBody"];
        }
        
        if (((NSHTTPURLResponse *)sessionDataTask.response).allHeaderFields) {
            [returnDictionary setObject:((NSHTTPURLResponse *)sessionDataTask.response).allHeaderFields forKey:@"responseHeaders"];
        }
        
        jsString = [NSString stringWithFormat:@"%@(%@)", funName, [self dataTojsonString:returnDictionary]];
    }
    else if (error != nil) {//请求出现错误
        [returnDictionary setObject:@"客户端网络错误" forKey:@"message"];
        if (error.code == NSURLErrorTimedOut) {//请求超时
            [returnDictionary setObject:@"error_10002" forKey:@"code"];
        }
        else
        {
            [returnDictionary setObject:@"error_10001" forKey:@"code"];
        }
        
        jsString = [NSString stringWithFormat:@"%@(%@)", funName, [self dataTojsonString:returnDictionary]];
    }
    
    return jsString;
}
@end
