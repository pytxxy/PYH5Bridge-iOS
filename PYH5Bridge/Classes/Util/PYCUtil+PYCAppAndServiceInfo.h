//
//  PYUtil+AppAndServiceInfo.h
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
//
/**
 *  app信息以及设备信息获取
 */
#import "PYCUtil.h"

@interface PYCUtil (PYCAppAndServiceInfo)

/** 获取内部版本号,return:NSString */
+ (NSString *)appVersion;

/** 获取发布版本号,return:NSString */
+ (NSString *)appBuildVersion;


/** 获取设备的标示符,return:NSString */
+ (NSString *)getDeviceNameIdentifier;

#pragma mark App Authorization Status


/**
 判断App是否有访问相机权限

 @param isFirstSetting 是否是第一次进入设置（可为空）
 @return 是否有权限
 */
+ (BOOL)hasCameraRights:(BOOL *)isFirstSetting;

/**
 麦克风权限
 @param isFirstSetting 是否是第一次进入设置（可为空）
 @return 是否有权限
 */
+ (BOOL)hasAudioRights:(BOOL *)isFirstSetting;


/// 判断是否有操作相册权限
+ (BOOL)hasPhotoLibraryPermission;

#pragma mark -- devieceInfo
/** 屏幕宽 */
+ (CGFloat)screenWidth;

/** 屏幕宽 */
+ (CGFloat)screenHeight;

/**
 手机类型
 
 @return 手机类型
 */
+ (NSString *)iphoneType;

@end
