//
//  UIImage+ScaleSize.m
//  PYLibrary
//
//  Created on 16/9/14.
//  Copyright © 2016年 PYCredit. All rights reserved.
//

#import "UIImage+PYCScaleSize.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (PYCScaleSize)

+ (UIImage *)zoomImage:(UIImage *)image toScale:(CGSize)reSize
{
    CGSize size_new = CGSizeZero;
    if (image.size.width/reSize.width > image.size.height/reSize.height)
    {
        size_new.height = reSize.height;
        size_new.width  = reSize.height/image.size.height * image.size.width;
    }
    else
    {
        size_new.width = reSize.width;
        size_new.height  = reSize.width/image.size.width * image.size.height;
    }

    //绘制这个大小的图片
    UIGraphicsBeginImageContext(size_new);
    [image drawInRect:CGRectMake(0,0, size_new.width, size_new.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}



+ (UIImage *)py_scaleImage:(UIImage *)image toScale:(CGSize)reSize
{
    UIImage *scaledImage = [self zoomImage:image toScale:reSize];

    float drawW = 0.0;
    float drawH = 0.0;

    CGSize size_new = scaledImage.size;

    if (size_new.width > reSize.width) {
        drawW = (size_new.width - reSize.width)/2.0;
    }
    if (size_new.height > reSize.height) {
        drawH = (size_new.height - reSize.height)/2.0;
    }
    
    //截取截取大小为需要显示的大小。取图片中间位置截取
    CGRect myImageRect = CGRectMake(drawW, drawH, reSize.width, reSize.height);
    UIImage* bigImage= scaledImage;
    scaledImage = nil;
    CGImageRef imageRef = bigImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);

    UIGraphicsBeginImageContext(reSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}

+ (UIImage *)py_resizeImage:(UIImage *)image maxPixelSize:(CGFloat)size {
    if (size <= 0) {
        return image;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    CFDataRef dataRef = (__bridge CFDataRef)data;
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(size)
                                                           };
    // Create the image source
    CGImageSourceRef src = CGImageSourceCreateWithData(dataRef, NULL);
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    

    UIImage *toReturn = [UIImage imageWithCGImage:thumbnail];
    CFRelease(thumbnail);
    CFRelease(src);
    return toReturn;
}

//截取部分图像
-(UIImage*)py_getSubImage:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

/**
 压缩图片到指定文件大小

 @param image 待处理图片
 @param kb 图片大小
 @return 返回处理的图片
 */
+ (NSData *)scaleImage:(UIImage *)image toKb:(NSInteger)kb
{
    if (!image) {
        return nil;
    }
    if (kb<1) {
        return nil;
    }
    kb *=1024.0f;
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > kb && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}
@end
