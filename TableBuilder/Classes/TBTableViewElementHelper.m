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
    
    if (!element.tb_forCalculateHeight) {
        // 设置element的背景色
        if (model.tb_eleColor) {
            element.backgroundColor = element.contentView.backgroundColor = model.tb_eleColor;
        }
        // 设置cell的选中颜色
        if (model.tb_cellSelectedColor
            && [element respondsToSelector:@selector(selectedBackgroundView)]
            && [element respondsToSelector:@selector(selectionStyle)]) {
            
            static void *customSelectedBackgroundViewKey = &customSelectedBackgroundViewKey;
            if (!objc_getAssociatedObject(element.selectedBackgroundView, customSelectedBackgroundViewKey)) {
                element.selectedBackgroundView = UIView.new;
                objc_setAssociatedObject(element.selectedBackgroundView, customSelectedBackgroundViewKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            element.selectionStyle = UITableViewCellSelectionStyleDefault;
            element.selectedBackgroundView.backgroundColor = model.tb_cellSelectedColor;
        }
    }
    if (model.tb_eleSetter) {
        [model.tb_eleSetter setModel:model forElement:element];
    }
    else {
        [element tb_syncSetModel:model];
    }
}

+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    [self markElementAsHeightCalculate:element];
    [self setModel:model forElement:element];
    CGFloat cellHeight = 0;
    if (element.contentView.constraints.count > 0) {
        CGSize size = [element.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        // +0.5 是为了解决iOS自动布局计算高度的一个bug
        cellHeight = size.height + 0.5;
    }
    if (cellHeight < 0.6) {
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
static void *_tb_elementModelKey = &_tb_elementModelKey;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_elementModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (model.tb_eleSetSync || element.tb_forCalculateHeight) {
        [self syncSetModel:model forElement:element];
        [element setNeedsLayout];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (model == element.tb_model) {
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

@end
