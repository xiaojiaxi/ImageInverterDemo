//
//  ActionViewController.m
//  AAPLImageInverter
//
//  Created by lihao on 14-6-6.
//  Copyright (c) 2014年 OkCoin. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            // 在此执行你要对图片的操作
                            
                            UIImage* invertedImage = [self invertedImage:image];
                            
                            [imageView setImage:invertedImage];
                            
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

-(UIImage*)invertedImage:(UIImage*)originalImage{
    // Invert the image by applying an affine transformation
    UIGraphicsBeginImageContext(originalImage.size);
    
    // Apply an affine transformation to the original image to generate a vertically flipped image
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform affineTransformationInvert = CGAffineTransformMake(1,0,0,-1,0,originalImage.size.height);
    CGContextConcatCTM(context, affineTransformationInvert);
    [originalImage drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *invertedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return invertedImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"ImageInverterErrorDomain" code:0 userInfo:nil]];
}

- (IBAction)done{
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    NSExtensionItem* extensionItem = [[NSExtensionItem alloc] init];
    [extensionItem setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Inverted Image"]];
    [extensionItem setAttachments:@[[[NSItemProvider alloc] initWithItem:[_imageView image] typeIdentifier:(NSString*)kUTTypeImage]]];
    [self.extensionContext completeRequestReturningItems:@[extensionItem] completionHandler:nil];
}

@end
