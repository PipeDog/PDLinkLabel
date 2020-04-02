//
//  PDLinkLabel.h
//  PDLinkLabel
//
//  Created by liang on 2020/4/2.
//  Copyright © 2020 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDLinkLabelLink;
@protocol PDLinkLabelDelegate;

@interface PDLinkLabel : UIView

@property (nonatomic, weak, nullable) id<PDLinkLabelDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable, readonly) NSAttributedString *attributedText;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIFont *font; // Default system font 12 plain
@property (nonatomic, strong) UIColor *textColor; // Default is darkGrayColor
@property (nonatomic, assign) CGFloat lineSpacing; // Default 3.f
@property (nonatomic, assign) NSInteger numberOfLines; // Default 0, no limit

- (void)draw; // Call `drawWithLinks:` with argument nil
- (void)drawWithLinks:(nullable NSArray<PDLinkLabelLink *> *)links;

- (void)automicFitHeight; // Call this method if you need automic fit height
- (void)invalidAutomicFitHeight;

@end

@protocol PDLinkLabelDelegate <NSObject>

@optional
- (void)linkLabel:(PDLinkLabel *)linkLabel didInteractWithLink:(PDLinkLabelLink *)link;

@end

@interface PDLinkLabelLink : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *meta;

@end

NS_ASSUME_NONNULL_END
