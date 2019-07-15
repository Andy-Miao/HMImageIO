//
//  ViewController.m
//  ImageIO
//
//  Created by humiao on 2019/1/18.
//  Copyright © 2019年 humiao. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;

@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *imagePath = @"/Users/humiao/Desktop/ImageIO/ImageIO/PIC_20190112102832.jpg";
    NSLog(@"imagePath = %@",imagePath);
    _bigImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    [self.view addSubview:_bigImageView];
    
    NSString *thumPath = [self convertImagePathToThumPath: imagePath];
    NSLog(@"thumPath = %@",thumPath);
    NSData *thumbImageData = nil;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:imagePath], nil);
    if (CGImageSourceGetCount(imageSourceRef) > 0) {
        NSDictionary *thumbOpt = @ {
            (NSString *) kCGImageSourceCreateThumbnailFromImageAlways: @YES,
            (NSString *) kCGImageSourceThumbnailMaxPixelSize: [NSNumber numberWithInt: 390],
            (NSString *) kCGImageSourceCreateThumbnailWithTransform: @YES,
        };
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(imageSourceRef, 0, (__bridge CFDictionaryRef) thumbOpt);
        if (nil != imageRef) {
            thumbImageData = UIImageJPEGRepresentation([UIImage imageWithCGImage: imageRef], 1.0);
            CGImageRelease(imageRef);
            // 生成成功，跳过第二种生成方式
            goto lbl_genThumbSuccess;
        }
    }
    // 另一种方式生成缩略图
    thumbImageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile: imagePath], 0.3);
    
    lbl_genThumbSuccess: {
    if (imageSourceRef) {
        CFRelease(imageSourceRef);
    }
        if (nil != thumbImageData) {
            [thumbImageData writeToFile: thumPath atomically: YES];
            NSLog(@"写入成功");
#ifdef IS_DEBUG
            NSFileManager *fm = [NSFileManager defaultManager];
            long long size = [[fm attributesOfItemAtPath: thumPath error: nil] fileSize];
            NSLog(@"Thumbnail file size = %lld", size);
#endif
        } else {
            NSLog(@"Warning: Generate thumbnail failed.");
        }
    }
   
    
    _smallImageView.image = [UIImage imageWithContentsOfFile:thumPath];
    [self.view addSubview:_smallImageView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSString *) convertImageNameToThumName: (NSString *) imageName {
    NSUInteger location = NSNotFound;
    if (NSNotFound != (location = [imageName rangeOfString: @"_" options: NSLiteralSearch].location)) {
        imageName = [imageName substringFromIndex: location + 1]; // 去头
    }
    return [NSString stringWithFormat: @"Thum_%@", imageName];
}

- (NSString *) convertImagePathToThumPath: (NSString *) imagePath {
    NSUInteger location = NSNotFound;
    NSString *thumName = [self convertImageNameToThumName: imagePath];
    NSString *thumPath = imagePath;
    if (NSNotFound != (location = [imagePath rangeOfString: @"/" options: NSBackwardsSearch].location)) {
        thumPath = [imagePath substringToIndex: location + 1]; // 去尾
    }
    return [NSString stringWithFormat: @"%@%@", thumPath, thumName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
