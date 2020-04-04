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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self constraintsDemo];
    [self frameDemo];
}

- (void)constraintsDemo {
    PDLinkLabel *linkLabel = [[PDLinkLabel alloc] init];
    linkLabel.backgroundColor = [UIColor systemGroupedBackgroundColor];
    linkLabel.translatesAutoresizingMaskIntoConstraints = NO;
    linkLabel.lineSpacing = 10.f;
    linkLabel.textColor = [UIColor redColor];
    // linkLabel.numberOfLines = 3;
    linkLabel.numberOfLines = 0;
    linkLabel.delegate = self;
    [self.view addSubview:linkLabel];
    
    [linkLabel automicFitHeight];
    [linkLabel drawText:[self string] withLinks:[self links]];
    
    [NSLayoutConstraint activateConstraints:@[
        [linkLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100.f],
        [linkLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:50.f],
        [linkLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-50.f],
    ]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        linkLabel.numberOfLines = 3;
    });
}

- (void)frameDemo {
    PDLinkLabel *linkLabel = [[PDLinkLabel alloc] init];
    linkLabel.frame = CGRectMake(50.f, 300.f, 300.f, 200.f);
    linkLabel.backgroundColor = [UIColor systemTealColor];
    linkLabel.lineSpacing = 10.f;
    linkLabel.textColor = [UIColor redColor];
     linkLabel.numberOfLines = 3;
    linkLabel.delegate = self;
    [self.view addSubview:linkLabel];

    [linkLabel drawText:[self string] withLinks:[self links]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        linkLabel.numberOfLines = 0;
        linkLabel.frame = CGRectMake(50.f, 300.f, 200.f, 400.f);
        linkLabel.textColor = [UIColor redColor];
        linkLabel.font = [UIFont boldSystemFontOfSize:18];
    });
}

#pragma mark - PDLinkLabelDelegate
- (void)linkLabel:(PDLinkLabel *)linkLabel didInteractWithLink:(PDLinkLabelLink *)link {
    NSLog(@"text => %@", link.text);
}

#pragma mark - Getter Methods
- (NSString *)string {
    NSString *string = @"Don't be afraid to shoot a single horse. What about being alone and brave? You can cry all the way, but you can't be angry. You have to go through the days when nobody cares about it to welcome applause and flowers.";
    return string;
}

- (NSArray<PDLinkLabelLink *> *)links {
    NSString *string = [self string];
    
    PDLinkLabelLink *link = [[PDLinkLabelLink alloc] init];
    link.text = @"afraid";
    link.textColor = [UIColor blueColor];
    link.range = [string rangeOfString:@"afraid"];
    link.meta = nil;
    
    PDLinkLabelLink *link2 = [[PDLinkLabelLink alloc] init];
    link2.text = @"being";
    link2.textColor = [UIColor blueColor];
    link2.range = [string rangeOfString:@"being"];
    link2.meta = nil;

    PDLinkLabelLink *link3 = [[PDLinkLabelLink alloc] init];
    link3.text = @"flowers.";
    link3.textColor = [UIColor blueColor];
    link3.range = [string rangeOfString:@"flowers."];
    link3.meta = nil;

    return @[link, link2, link3];
}

@end
