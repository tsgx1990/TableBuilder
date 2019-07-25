//
//  TBTableViewElement.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBTableViewElement <NSObject>

@required
@property (nonatomic, strong) UIView *contentView;

// 该属性用于判断当前element是否只是用于计算高度。
// 可以根据该属性进行一些优化：
// 比如cell上有网络图片，则可以根据是否为计算高度的cell来决定是否加载图片。
@property (nonatomic, readonly) BOOL tb_forCalculateHeight;

@property (nonatomic, readonly) NSObject *tb_model;
@property (nonatomic, readonly) id tb_delegate;

- (void)tb_syncSetModel:(NSObject *)model;

@optional
// you should override this method if you don't use autolayout
- (CGFloat)tb_elementHeightForModel:(NSObject *)model;

// 只用于 UITableViewCell
@property(nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property(nonatomic, strong) UIView *selectedBackgroundView;

@end


@protocol TBElementModelSetter <NSObject>

@required
// 当同一种类型的 element 可以使用不同类型的 model 时，
// 需要设置 element.tb_cellDataSource ，并在该 tb_cellDataSource 中实现这个方法，用于给 element 赋值。
// (这样就可以创建不依赖于特定 model 的 element，使 element 更具有通用性)
- (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;

@end

