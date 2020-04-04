//
//  PDLinkLabel.m
//  PDLinkLabel
//
//  Created by liang on 2020/4/2.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDLinkLabel.h"

// Internal const values
static NSString *const kInteractURLPrefix = @"act://www.pipedog.com/interact/click?word=";

@interface _PDLinkTextView : UITextView

@end

@implementation _PDLinkTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (UITextRange *)selectedTextRange {
    return nil;
}

@end

@interface PDLinkLabel () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, copy) NSDictionary<NSString *, PDLinkLabelLink *> *links;
@property (nonatomic, copy) NSArray<PDLinkLabelLink *> *metaLinks;

@end

@implementation PDLinkLabel {
    NSLineBreakMode _lineBreakMode;
    NSLayoutConstraint *_heightConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commitInit];
        [self _createViewHierarchy];
        [self _layoutContentViews];
    }
    return self;
}

- (void)_commitInit {
    _textAlignment = NSTextAlignmentLeft;
    _font = [UIFont systemFontOfSize:12];
    _textColor = [UIColor darkGrayColor];
    _lineSpacing = 3.f;
    /**
     Wrong:
        NSLineBreakByCharWrapping
        NSLineBreakByClipping
        NSLineBreakByTruncatingHead
        NSLineBreakByTruncatingTail
        NSLineBreakByTruncatingMiddle

     Correct:
        NSLineBreakByWordWrapping
     */
    _lineBreakMode = NSLineBreakByWordWrapping;
    _numberOfLines = 0;
    self.clipsToBounds = YES;
}

- (void)_createViewHierarchy {
    [self addSubview:self.textView];
}

- (void)_layoutContentViews {
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.textView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
        [self.textView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
    ]];
}

#pragma mark - Public Methods
- (void)drawText:(NSString *)text {
    [self drawText:text withLinks:nil];
}

- (void)drawText:(NSString *)text withLinks:(NSArray<PDLinkLabelLink *> *)links {
    _text = [text copy];
    _metaLinks = [links copy];
    self.textView.attributedText = _attributedText = nil;
    
    if (!self.text.length) {
        return;
    }
    
    NSInteger len = self.text.length;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = self.lineSpacing;
    style.lineBreakMode = _lineBreakMode;
    style.alignment = self.textAlignment;
    style.headIndent = 0.f;
    style.tailIndent = 0.f;
    
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, len)];
    [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, len)];

    for (PDLinkLabelLink *link in links) {
        NSString *text = link.text; // word in string
        if (!text.length) {
            NSAssert(NO, @"The property `text` from `PDLinkLabelLink` can not be nil!");
            continue;
        }
        
        UIColor *textColor = link.textColor;
        if (!textColor) {
            NSAssert(NO, @"The property `textColor` from `PDLinkLabelLink` can not be nil!");
            continue;
        }
        
        NSRange range = link.range;
        if (!range.length || (range.location + range.length > len)) { // maybe out of bounds
            NSAssert(NO, @"The property `range` from `PDLinkLabelLink` should be valid!");
            continue;
        }
        
        NSString *substring = [self.text substringWithRange:range];
        if (![text isEqualToString:substring]) { // Unmatched, maybe error from Chivox
            NSAssert(NO, @"The substring from `range` should equal to `text`!");
            continue;
        }
        
        NSString *URLString = [self _formatURLStringWithWord:text];
        [attributedText addAttribute:NSLinkAttributeName value:URLString range:range];
        [attributedText addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        dict[text] = link;
    }
    
    self.links = [dict copy];
    self.textView.attributedText = _attributedText = [attributedText copy];
}

- (void)automicFitHeight {
    if (_heightConstraint) { return; }
    
    _heightConstraint = [self.heightAnchor constraintEqualToAnchor:self.textView.heightAnchor multiplier:1];
    [NSLayoutConstraint activateConstraints:@[_heightConstraint]];
}

- (void)invalidAutomicFitHeight {
    if (!_heightConstraint) { return; }
    
    [NSLayoutConstraint deactivateConstraints:@[_heightConstraint]];
    _heightConstraint = nil;
}

#pragma mark - Tool Methods
- (NSString *)_formatURLStringWithWord:(NSString *)word {
    NSString *format = [NSString stringWithFormat:@"%@%@", kInteractURLPrefix, word];
    format = [format stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return format;
}

- (NSString *)_parseWordFromURLString:(NSString *)URLString {
    URLString = [URLString stringByRemovingPercentEncoding];
    return [URLString substringFromIndex:kInteractURLPrefix.length];
}

- (BOOL)_notifyIfNeeded:(NSURL *)URL {
    if (![self.delegate respondsToSelector:@selector(linkLabel:didInteractWithLink:)]) {
        return YES;
    }

    NSString *URLString = URL.absoluteString;
    NSString *key = [self _parseWordFromURLString:URLString];
    PDLinkLabelLink *link = self.links[key];
    if (!link) {
        return YES;
    }

    [self.delegate linkLabel:self didInteractWithLink:link];
    return NO;
}

- (void)_drawIfNeeded {
    if (!self.superview) { return; }
    
    [self drawText:self.text withLinks:self.metaLinks];
}

#pragma mark - UITextViewDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return [self _notifyIfNeeded:URL];
}
#pragma clang diagnostic pop

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    return [self _notifyIfNeeded:URL];
}

#pragma mark - Override Methods
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.textView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(frame), 0.f);
}

- (CGSize)intrinsicContentSize {
    return [self.textView intrinsicContentSize];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self _drawIfNeeded];
}

#pragma mark - Setter Methods
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.textView.textAlignment = _textAlignment;
    [self _drawIfNeeded];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.textView.font = _font;
    [self _drawIfNeeded];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textView.textColor = _textColor;
    [self _drawIfNeeded];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    self.textView.textContainer.maximumNumberOfLines = _numberOfLines;
    [self _drawIfNeeded];
}

#pragma mark - Getter Methods
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[_PDLinkTextView alloc] init];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.editable = NO;
        _textView.scrollEnabled = NO;
        _textView.delegate = self;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor clearColor];
        _textView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor clearColor]};
        _textView.textContainerInset = UIEdgeInsetsMake(0, -5.f, 0, -5.f);
        _textView.font = _font;
        _textView.textContainer.maximumNumberOfLines = _numberOfLines;
        _textView.textContainer.lineBreakMode = _lineBreakMode;
        _textView.textContainer.heightTracksTextView = YES;
        _textView.linkTextAttributes = @{};
    }
    return _textView;
}

@end

@implementation PDLinkLabelLink

@end
