//
//  TBTableViewElement.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define _TB_CONCAT2(A, B) A ## B
#define TB_CONCAT2(A, B) _TB_CONCAT2(A, B)

#define TBRedefinePropertyType(_className, _categoryName, _properties) \
@interface _className (TB_CONCAT2(_categoryName, __COUNTER__)) \
    _properties   \
@end


/** 用于重新规定element类中 tb_model 的类型 **/
#define TBRedefineModelType(_eleClass, _modelType) \
    \
TBRedefinePropertyType(     \
    _eleClass, _tb_model_type_,    \
    @property (nonatomic, readonly) _modelType *tb_model;    \
)

/** 用于重新规定element类中 tb_delegate 的类型 **/
#define TBRedefineDelegateType(_eleClass, _delegateType)   \
    \
TBRedefinePropertyType(     \
    _eleClass, _tb_delegate_type_,     \
    @property (nonatomic, readonly) _delegateType tb_delegate;        \
)

@protocol TBTableViewElement <NSObject>

// 该属性用于判断当前element是否只是用于计算高度。
// 可以根据该属性进行一些优化：
// 比如cell上有网络图片，则可以根据是否为计算高度的cell来决定是否加载图片。
@property (nonatomic, readonly) BOOL tb_forCalculateHeight;

// 返回element当前所在的tableView，如果element没有添加到tableView上，则返回nil
@property (nonatomic, weak, readonly) UITableView *tb_tableView;

// element的当前model
@property (nonatomic, readonly) NSObject *tb_model;
@property (nonatomic, readonly) id tb_delegate;

// 设置 element 的背景色
@property (nonatomic, copy) UIColor *tb_defaultColor;

@optional

// 只用于 UITableViewCell
@property (nonatomic, copy) UIColor *tb_defaultSelectedColor;

// 子类可以实现该方法用于给element赋值。
// 需要注意的是：在element上的model未发生改变的情况下，该方法并不会在每次element显示时都会执行。
// 如果需要在每次element显示时都执行一些操作，你可以实现 tb_alwaysPerformWithModel: 方法。
- (void)tb_syncSetModel:(NSObject *)model;

// 子类可以实现该方法，返回element应该设置成的高度。
// 如果使用了自动布局且能通过自动布局自动计算出高度，
// 或者设置了 model 的 tb_eleHeight 或 tb_eleGetHeight 属性，则可以不实现该方法。
// 需要注意的是：由于高度缓存的存在，并不是每次 element 尝试获取高度的时候都会调用该方法。
- (CGFloat)tb_elementHeightForModel:(NSObject *)model;

// 在给element正式赋值前的预操作，子类可以实现该方法用于优化element异步赋值的视觉体验。
// 为了防止卡顿，建议不要在该方法中进行一些耗时或者过于复杂的操作。
- (void)tb_preprocessWithModel:(NSObject *)model;

// 每次尝试给element赋值之前都会执行的操作。
// 子类可以实现该方法用于执行element每次显示时都需要执行的操作。
// 在该方法中，如果对element的操作不会影响element的高度，则为了防止卡顿，可以异步执行。
// 如果对element的操作会影响element的高度，则必须同步执行。
// 同步执行和异步执行的代码在该方法中可以同时存在。
- (void)tb_alwaysPerformWithModel:(NSObject *)model;

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

