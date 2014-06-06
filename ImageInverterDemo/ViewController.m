//
//  ViewController.m
//  ImageInverterDemo
//
//  Created by lihao on 14-6-6.
//  Copyright (c) 2014年 OkCoin. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

{
    UIImageView * imageView;
}

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, 220, 220)];
    [imageView setImage:[UIImage imageNamed:@"IMG_0365.JPG"]];
    [self.view addSubview:imageView];
    
}

- (IBAction)sharedClickAction:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[imageView image]] applicationActivities:nil];
    
    //在extension提交修改以后，获取返回的returnedItems
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError * error){
        
        if ([returnedItems count] > 0)
            NSLog(@"returnedItems > 0");
            else
                NSLog(@"returnedItems < 0");
            
        if ([returnedItems count] > 0) {
            for (NSExtensionItem * extensionItem in returnedItems) {
                //查找所有Provider
                for (NSItemProvider * imageItemProvider in [extensionItem attachments]) {
                    //发现Provider有 kUTTypeImage类型的Image
                    if ([imageItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                        //加载返回的items和其他信息
                        [imageItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *item, NSError *error) {
                            if (item && !error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"find one item from extension");
                                    [imageView setImage:item];
                                });
                            }
                        }];
                    }
                }
            }
        }else{
            NSLog(@"expresion 没有提交任何信息");
        }
    }];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
