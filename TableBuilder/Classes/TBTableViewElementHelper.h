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

+ (void)setNeedUpdateElement:(BOOL)need forModel:(NSObject *)model;

+ (void)setNeedRefreshHeightCache:(BOOL)need forModel:(NSObject *)model;

// 刷新model对应的element
+ (void)updateElementWithModel:(NSObject *)model;
+ (void)reloadDataWithModelIfNeeded:(NSObject *)model;

+ (UITableView *)tableViewForElement:(UIView<TBTableViewElement> *)element;

+ (UIView<TBTableViewElement> *)elementForModel:(NSObject *)model;

+ (UITableView *)tableViewForModel:(NSObject *)model;

// 在列表每次 reload 的时候会自动调用该方法来重置它所使用的model
+ (void)clearModelStoreInTableView:(UITableView *)tableView;

+ (BOOL)isHeightCalForElement:(UIView<TBTableViewElement> *)element;

// 设置默认背景色
+ (void)setDefaultColor:(UIColor *)defaultColor forElement:(UIView<TBTableViewElement> *)element;
+ (UIColor *)defaultColorForElement:(UIView<TBTableViewElement> *)element;

// 设置cell默认选中颜色
+ (void)setDefaultSelectedColor:(UIColor *)defaultSelectedColor forElement:(UIView<TBTableViewElement> *)element;
+ (UIColor *)defaultSelectedColorForElement:(UIView<TBTableViewElement> *)element;

@end
