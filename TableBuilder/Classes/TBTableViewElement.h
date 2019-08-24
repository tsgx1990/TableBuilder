//
//  TBTableViewElement.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBTableViewElement <NSObject>

// 该属性用于判断当前element是否只是用于计算高度。
// 可以根据该属性进行一些优化：
// 比如cell上有网络图片，则可以根据是否为计算高度的cell来决定是否加载图片。
@property (nonatomic, readonly) BOOL tb_forCalculateHeight;

@property (nonatomic, weak, readonly) UITableView *tb_tableView;

// element的前一个model（考虑废弃，因为是强引用）
@property (nonatomic, readonly) NSObject *tb_prevModel;

// element的当前model
@property (nonatomic, readonly) NSObject *tb_model;
@property (nonatomic, readonly) id tb_delegate;

// 设置 element 的背景色
@property (nonatomic, copy) UIColor *tb_defaultColor;

@optional

// 只用于 UITableViewCell
@property (nonatomic, copy) UIColor *tb_defaultSelectedColor;

- (void)tb_syncSetModel:(NSObject *)model;

// you should override this method if you don't use autolayout
- (CGFloat)tb_elementHeightForModel:(NSObject *)model;

// 只用于 UITableViewCell
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath;


/* **************************** */
@required
@property (nonatomic, strong) UIView *contentView;

@optional
// 只用于 UITableViewCell
@property(nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property(nonatomic, strong) UIView *selectedBackgroundView;

@end


@protocol TBElementModelSetter <NSObject>

@optional
// 当同一种类型的 element 可以使用不同类型的 model 时，
// 需要设置 model.tb_eleSetter ，并在该 tb_eleSetter 中实现这个方法，用于给 element 赋值。
// (这样就可以创建不依赖于特定 model 的 element，使 element 更具有通用性)
- (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;

// 如果设置的 model.tb_eleSetter 是一个class，则需要在该class中实现该方法
+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;

@end

