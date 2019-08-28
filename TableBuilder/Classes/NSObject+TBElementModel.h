//
//  NSObject+TBElementModel.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTableViewElement.h"

@interface TBElementModelWeakWrapper : NSObject

@property (nonatomic, weak) id data;

+ (instancetype)weakWithData:(id)data;

@end

@interface NSObject (TBElementModel)

// 返回当前model所对应的tableView。只有在 [tableView reloadData] 之后才能获取到
@property (nonatomic, weak, readonly) UITableView *tb_tableView;

// 返回当前model所对应的element，如果没有，则返回nil。
// 需要注意的是，如果model对应的element不可见，则由于element复用的原因，该属性也可能为nil。
@property (nonatomic, weak, readonly) UIView<TBTableViewElement> *tb_element;

// 如果不指定，默认为 self.class.tb_eleClass
@property (nonatomic, copy) Class tb_eleClass;          // （设置之后不能再修改）
@property (nonatomic, copy, class) Class tb_eleClass;   // （设置之后不能再修改）

// 如果不指定，默认为 NSStringFromClass(self.tb_eleClass)
@property (nonatomic, copy) NSString *tb_eleReuseID;    // （设置之后不能再修改）

// 默认为NO，如果指定为YES，需要存在和 tb_eleClass 同名的xib文件
@property (nonatomic, assign) BOOL tb_eleUseXib;        // （设置之后不能再修改）

@property (nonatomic, strong) id tb_eleDelegate;
// 如果会带来循环引用，则使用 weakEleDelegate 而不是 eleDelegate；
// 如果设置了 tb_eleWeakDelegate，而没有设置 eleDelegate，则通过 eleDelegate 获取到的是 tb_eleWeakDelegate
@property (nonatomic, weak) id tb_eleWeakDelegate;

// 以下三个属性不需要同时设置，如果不小心同时设置了，
// 最后使用的优先级是 tb_eleSetBlock > tb_eleSetter > tb_eleWeakSetter。
// 如果这三个属性都没有设置，element 的 tb_syncSetModel: 方法将被调用。
// （tb_eleSetter和tb_eleWeakSetter可以用class进行设置）
// （如果动态修改了 setter 或 setBlock，由于这可能导致UI的变化，所以需要调用 tb_update:）
@property (nonatomic, strong) id<TBElementModelSetter> tb_eleSetter;
@property (nonatomic, weak) id<TBElementModelSetter> tb_eleWeakSetter;
@property (nonatomic, copy) void(^tb_eleSetBlock)(id model, id<TBTableViewElement> element);

// 是否使用高度缓存。默认为 NO，即始终进行高度缓存
@property (nonatomic, assign) BOOL tb_eleDoNotCacheHeight; // （设置之后仍可以修改）

// 是否同步更新 element。
// 默认为NO，即异步更新（当element比较复杂时，异步更新可以避免列表卡顿）
@property (nonatomic, assign) BOOL tb_eleSetSync;

// 可以通过该属性指定element的高度；
// 如果没有指定高度，可以通过该属性获取计算后的高度
@property (nonatomic, assign) CGFloat tb_eleHeight;

// 如果设置了tb_eleHeight，则该属性返回YES
@property (nonatomic, assign, readonly) BOOL tb_eleHeightIsFixed;

// 如果设置了该属性，在通过 autoLayout 计算高度失败的情况下，会优先从该属性中获取element高度，
// 而element类中实现的 tb_elementHeightForModel: 方法将不起作用
@property (nonatomic, copy) CGFloat(^tb_eleGetHeight)(id model);

// 设置element的背景色
@property (nonatomic, copy) UIColor *tb_eleColor;

// 设置cell的选中颜色，只对UITableViewCell有效
@property (nonatomic, copy) UIColor *tb_cellSelectedColor;

// 默认为NO，即 优先尝试使用自动布局来计算element高度。
// 如果为YES，element必须实现 tb_elementHeightForModel: 方法。
// 如果使用自动布局计算出的高度大于0，但不是正确的高度，则需要将该属性指定为YES；
@property (nonatomic, assign) BOOL tb_eleUseManualHeight;   // （设置之后不能再修改）

// 默认为0。表示 element 和 element.contentView 的宽度差值。
// 修改该属性可能会影响cell的高度，所以需要调用 tb_update:
@property (nonatomic, assign) CGFloat tb_eleHorizontalMargin;

// 在cell选中之后调用，只对UITableViewCell有效。
// 该属性在默认情况下，cell选中后会执行 [tableView deselectRowAtIndexPath:indexPath animated:YES] 操作；
// 如果不想在cell选中时执行上面的操作，则需要主动将该属性置为nil。
@property (nonatomic, copy) void(^tb_cellDeselectRow)(UITableView *tableView, NSIndexPath *indexPath);

// 设置cell被选中时的回调，只对UITableViewCell有效
@property (nonatomic, copy) void(^tb_cellDidSelect)(id model, NSIndexPath *indexPath);

// 如果element的新旧model不是同一个，
// 则在element刷新UI之前会通过该block来比较新旧model，从而决定是否刷新element；
// 如果这个block == nil，则会通过model类的 isEqual: 方法来比较新旧model。
// 需要注意的是，如果element的新旧model是同一个，则该block属性和isEqual:方法都不起作用。
// （model为当前model；prevModel为element之前的model，可能为nil，也可能和model类型不同）
@property (nonatomic, copy) BOOL(^tb_modelIsEqual)(id model, id prevModel);

// 调用该方法将会使 element 在下次刷新的时候重新计算高度来刷新缓存
- (void)tb_needRefreshHeightCache;

// 修改model属性之后调用该方法，将会刷新model当前所对应的element UI。
// 如果确定对model的修改不影响element的UI变化，则不用调用该方法。
// 如果确定对model的修改不会影响element的高度，则 reloadIfNeeded 传 NO。
// 调用该方法，将会使 model 的 needUpdate 标志置为YES。
// (reloadIfNeeded 表示是否在 element 高度变化时 reload 整个列表)
- (void)tb_update:(BOOL)reloadIfNeeded;

@end
