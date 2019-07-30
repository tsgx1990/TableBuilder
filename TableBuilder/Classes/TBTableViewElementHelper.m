//
//  TBTableViewElementHelper.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TBTableViewElementHelper.h"
#import <objc/runtime.h>
#import "NSObject+TBElementModel.h"

@implementation TBTableViewElementHelper

+ (void)syncSetModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    // 解决 header 或者 footer 在转屏后的自动布局问题
    if (!element.contentView.translatesAutoresizingMaskIntoConstraints) {
        element.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    if (model.tb_eleSetBlock) {
        model.tb_eleSetBlock(model, element);
    }
    else if (model.tb_eleSetter) {
        if ([model.tb_eleSetter respondsToSelector:@selector(setModel:forElement:)]) {
            [model.tb_eleSetter setModel:model forElement:element];
        }
    }
    else {
        if ([element respondsToSelector:@selector(tb_syncSetModel:)]) {
            [element tb_syncSetModel:model];
        }
    }
}

+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    [self markElementAsHeightCalculate:element];
    [self setModel:model forElement:element];
    CGFloat cellHeight = 0;
    BOOL useManualHeight = model.tb_eleUseManualHeight;
    
    if (!useManualHeight && element.contentView.constraints.count > 0) {
        CGSize size = [element.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        // +0.5 是为了解决iOS自动布局计算高度的一个bug
        cellHeight = size.height + 0.5;
    }
    if (useManualHeight || cellHeight < 0.6) {
        [element setNeedsLayout];
        [element layoutIfNeeded];
        assert([element respondsToSelector:@selector(tb_elementHeightForModel:)]);
        cellHeight = [element tb_elementHeightForModel:model];
    }
    return cellHeight;
}

// 缓存计算出来的cell高度
static void *_tb_modelCalculatedHeightKey = &_tb_modelCalculatedHeightKey;

+ (void)setCalculatedHeight:(CGFloat)height forModel:(NSObject *)model
{
    objc_setAssociatedObject(model, _tb_modelCalculatedHeightKey, @(height), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (CGFloat)calculatedHeigthForModel:(NSObject *)model
{
    NSNumber *obj = objc_getAssociatedObject(model, _tb_modelCalculatedHeightKey);
    return obj.floatValue;
}

#pragma mark - - delegate
+ (id)delegateForElement:(UIView<TBTableViewElement> *)element
{
    return element.tb_model.tb_eleDelegate;
}

#pragma mark - - setModel
static void *_tb_elementPrevModelKey = &_tb_elementPrevModelKey;
static void *_tb_elementModelKey = &_tb_elementModelKey;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_elementPrevModelKey, element.tb_model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(element, _tb_elementModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    BOOL isForCalculate = element.tb_forCalculateHeight;
    BOOL isSyncSet = model.tb_eleSetSync;
    if (!isForCalculate) {
        // 同步设置element的背景色
        UIColor *color = model.tb_eleColor ?: element.tb_defaultColor;
        [self setColor:color forElement:element];
    }
    if (!isForCalculate && isSyncSet) {
        [self setSelectedColorWithModel:model forElement:element];
    }
    
    if (isSyncSet || isForCalculate) {
        [self syncSetModel:model forElement:element];
        [element setNeedsLayout];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (model == element.tb_model) {
            [self setSelectedColorWithModel:model forElement:element];
            [self syncSetModel:model forElement:element];
            [element setNeedsLayout];
        }
        else {
            NSLog(@"model is changed! hehe");
        }
    });
}

+ (NSObject *)modelForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_elementModelKey);
}

+ (NSObject *)prevModelForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_elementPrevModelKey);
}

#pragma mark - - isForHeightCalculating
static void *_tb_elementIsHCalKey = &_tb_elementIsHCalKey;

+ (void)markElementAsHeightCalculate:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_elementIsHCalKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)isHeightCalForElement:(UIView<TBTableViewElement> *)element
{
    NSNumber *obj = objc_getAssociatedObject(element, _tb_elementIsHCalKey);
    return !!obj;
}

#pragma mark - - color
static void *_tb_elementDefaultColorKey = &_tb_elementDefaultColorKey;

+ (void)setDefaultColor:(UIColor *)defaultColor forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_elementDefaultColorKey, defaultColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setColor:defaultColor forElement:element];
}

+ (UIColor *)defaultColorForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_elementDefaultColorKey);
}

+ (void)setColor:(UIColor *)color forElement:(UIView<TBTableViewElement> *)element
{
    if (color) {
        element.backgroundColor = element.contentView.backgroundColor = color;
    }
}

#pragma mark - - selected color
static void *_tb_cellDefaultSelectedColorKey = &_tb_cellDefaultSelectedColorKey;

+ (void)setDefaultSelectedColor:(UIColor *)defaultSelectedColor forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_cellDefaultSelectedColorKey, defaultSelectedColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setSelectedColor:defaultSelectedColor forElement:element];
}

+ (UIColor *)defaultSelectedColorForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_cellDefaultSelectedColorKey);
}

+ (void)setSelectedColor:(UIColor *)selectedColor forElement:(UIView<TBTableViewElement> *)element
{
    if (selectedColor
        && [element respondsToSelector:@selector(selectedBackgroundView)]
        && [element respondsToSelector:@selector(selectionStyle)]) {
        
        static void *customSelectedBackgroundViewKey = &customSelectedBackgroundViewKey;
        if (!objc_getAssociatedObject(element.selectedBackgroundView, customSelectedBackgroundViewKey)) {
            element.selectedBackgroundView = UIView.new;
            objc_setAssociatedObject(element.selectedBackgroundView, customSelectedBackgroundViewKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        element.selectionStyle = UITableViewCellSelectionStyleDefault;
        element.selectedBackgroundView.backgroundColor = selectedColor;
    }
}

// 设置cell的选中颜色
+ (void)setSelectedColorWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    if ([element respondsToSelector:@selector(setTb_defaultSelectedColor:)]) {
        UIColor *selectedColor = model.tb_cellSelectedColor ?: element.tb_defaultSelectedColor;
        [self setSelectedColor:selectedColor forElement:element];
    }
}

@end
