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

+ (CGFloat)heightWithModel:(NSObject *)model inTableView:(UITableView *)tableView;

// 从缓存中获取element高度
+ (CGFloat)calculatedHeigthForModel:(NSObject *)model;

+ (id)delegateForElement:(UIView<TBTableViewElement> *)element;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;
+ (NSObject *)modelForElement:(UIView<TBTableViewElement> *)element;
+ (NSObject *)prevModelForElement:(UIView<TBTableViewElement> *)element;

// 刷新model对应的element
+ (void)updateElementWithModel:(NSObject *)model;

+ (UITableView *)tableViewForElement:(UIView<TBTableViewElement> *)element;

+ (BOOL)isHeightCalForElement:(UIView<TBTableViewElement> *)element;

// 设置默认背景色
+ (void)setDefaultColor:(UIColor *)defaultColor forElement:(UIView<TBTableViewElement> *)element;
+ (UIColor *)defaultColorForElement:(UIView<TBTableViewElement> *)element;

// 设置cell默认选中颜色
+ (void)setDefaultSelectedColor:(UIColor *)defaultSelectedColor forElement:(UIView<TBTableViewElement> *)element;
+ (UIColor *)defaultSelectedColorForElement:(UIView<TBTableViewElement> *)element;

@end
