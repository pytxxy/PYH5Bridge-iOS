//
//  PYUtil+Network.h
//  PYH5Bridge
//
//  Created by huwei on 2017/10/13.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import "PYCUtil.h"
#import "PYCJSResultData.h"


typedef void(^PYRequestBlock)(id result);

/**
 网络相关类
 */
@interface PYCUtil (PYCNetwork)

/**
 Request请求封装

 @param dict H5返回参数
 @param resultData 回调的数据模型
 @param requestBlock 回调参数
 */
+ (void)actionRequest:(NSDictionary *)dict resultData:(PYCJSResultData *)resultData pyRequestBlock:(PYRequestBlock)requestBlock;

/**
 数据转化为JSON字符串
 r @param object 数据对象
 @return JSON字符串
 */
+ (NSString *)dataTojsonString:(id)object;

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
                    sessionDataTask:(NSURLSessionTask *)sessionDataTask;
@end

