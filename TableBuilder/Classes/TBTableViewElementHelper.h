//
//  TBTableViewElementHelper.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTableViewElement.h"

@interface TBTableViewElementHelper : NSObject

// 根据model计算element高度
+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;

// 将计算出的高度缓存到model中
+ (void)setCalculatedHeight:(CGFloat)height forModel:(NSObject *)model;

// 从缓存中获取element高度
+ (CGFloat)calculatedHeigthForModel:(NSObject *)model;

+ (id)delegateForElement:(UIView<TBTableViewElement> *)element;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;
+ (NSObject *)modelForElement:(UIView<TBTableViewElement> *)element;
+ (NSObject *)prevModelForElement:(UIView<TBTableViewElement> *)element;

+ (BOOL)isHeightCalForElement:(UIView<TBTableViewElement> *)element;

@end
