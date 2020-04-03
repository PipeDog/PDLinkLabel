//
//  ViewController.m
//  PDLinkLabel
//
//  Created by liang on 2020/4/2.
//  Copyright © 2020 liang. All rights reserved.
//

#import "ViewController.h"
#import "PDLinkLabel.h"

@interface ViewController () <PDLinkLabelDelegate>

@property (nonatomic, strong) PDLinkLabel *linkLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self demo];
}

- (void)demo {
    self.linkLabel = [[PDLinkLabel alloc] init];
    self.linkLabel.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.linkLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.linkLabel.frame = CGRectMake(50.f, 100.f, 300.f, 100.f);
    self.linkLabel.lineSpacing = 10.f;
    self.linkLabel.textColor = [UIColor redColor];
    self.linkLabel.numberOfLines = 3;
    [self.linkLabel automicFitHeight];
    self.linkLabel.delegate = self;
    [self.view addSubview:self.linkLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.linkLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100.f],
        [self.linkLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:50.f],
        [self.linkLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-50.f],
    ]];
    
    NSString *string = @"Don't be afraid to shoot a single horse. What about being alone and brave? You can cry all the way, but you can't be angry. You have to go through the days when nobody cares about it to welcome applause and flowers.";
    
    PDLinkLabelLink *link = [[PDLinkLabelLink alloc] init];
    link.text = @"afraid";
    link.textColor = [UIColor blueColor];
    link.range = [string rangeOfString:@"afraid"];
    link.meta = nil;
    
    PDLinkLabelLink *link2 = [[PDLinkLabelLink alloc] init];
    link2.text = @"flowers.";
    link2.textColor = [UIColor blueColor];
    link2.range = [string rangeOfString:@"flowers."];
    link2.meta = nil;

    [self.linkLabel drawText:string withLinks:@[link, link2]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.linkLabel drawText:nil];
    });
}

#pragma mark - PDLinkLabelDelegate
- (void)linkLabel:(PDLinkLabel *)linkLabel didInteractWithLink:(PDLinkLabelLink *)link {
    NSLog(@"text => %@", link.text);
}

@end
