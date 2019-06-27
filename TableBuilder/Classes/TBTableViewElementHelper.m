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
    if (model.tb_eleSetter) {
        [model.tb_eleSetter setModel:model forElement:element];
    }
    else {
        [element tb_syncSetModel:model];
    }
}

+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    [self syncSetModel:model forElement:element];
    CGFloat cellHeight = 0;
    if (element.contentView.constraints.count > 0) {
        CGSize size = [element.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        cellHeight = size.height;
    }
    if (cellHeight < 0.6) {
        [element setNeedsLayout];
        [element layoutIfNeeded];
        cellHeight = [element tb_elementHeight];
    }
    return cellHeight + 0.5;
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
    if (element.tb_forHeightCalculate) {
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

+ (void)setIsHeightCal:(BOOL)heightCal forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_elementIsHCalKey, @(heightCal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)isHeightCalForElement:(UIView<TBTableViewElement> *)element
{
    NSNumber *obj = objc_getAssociatedObject(element, _tb_elementIsHCalKey);
    return obj.boolValue;
}

@end
