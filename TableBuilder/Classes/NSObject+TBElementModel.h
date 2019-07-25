//
//  NSObject+TBElementModel.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTableViewElement.h"

@interface NSObject (TBElementModel)

// 如果不指定，默认为 self.class.tb_eleClass
@property (nonatomic, copy) Class tb_eleClass;
@property (nonatomic, copy, class) Class tb_eleClass;

// 如果不指定，默认为 NSStringFromClass(self.tb_eleClass)
@property (nonatomic, copy) NSString *tb_eleReuseID;

// 默认为NO，如果指定为YES，需要存在和 tb_eleClass 同名的xib文件
@property (nonatomic, assign) BOOL tb_eleUseXib;

@property (nonatomic, strong) id tb_eleDelegate;
// 如果会带来循环引用，则使用 weakEleDelegate 而不是 eleDelegate；
// 如果设置了 tb_eleWeakDelegate，而没有设置 eleDelegate，则通过 eleDelegate 获取到的是 tb_eleWeakDelegate
@property (nonatomic, weak) id tb_eleWeakDelegate;

@property (nonatomic, strong) id<TBElementModelSetter> tb_eleSetter;
@property (nonatomic, weak) id<TBElementModelSetter> tb_eleWeakSetter;

// 是否使用高度缓存。默认为 NO，即始终进行高度缓存
@property (nonatomic, assign) BOOL tb_eleDoNotCacheHeight;

// 标记是否在下次 element 刷新的时候更新高度缓存
// 如果为YES，则在 element 下次刷新的时候会重新计算高度来刷新缓存，然后自动变为NO；
// 如果为NO，则 element 直接使用高度缓存。
@property (nonatomic, assign) BOOL tb_eleRefreshHeightCache;

// 是否同步更新 element。
// 默认为NO，即异步更新（当element比较复杂时，异步更新可以避免列表卡顿）
@property (nonatomic, assign) BOOL tb_eleSetSync;

// 可以通过该属性指定element的高度；
// 如果没有指定高度，可以通过该属性获取计算后的高度
@property (nonatomic, assign) CGFloat tb_eleHeight;

// 如果设置了tb_eleHeight，则该属性返回YES
@property (nonatomic, readonly) BOOL tb_eleHeightIsFixed;

// 设置element的背景色
@property (nonatomic, copy) UIColor *tb_eleColor;

// 设置cell的选中颜色，只对UITableViewCell有效
@property (nonatomic, copy) UIColor *tb_cellSelectedColor;

// 默认为NO，即 优先尝试使用自动布局来计算element高度。
// 如果为YES，element必须实现 tb_elementHeightForModel: 方法。
// 如果使用自动布局计算出的高度大于0，但不是正确的高度，则需要将该属性指定为YES；
@property (nonatomic, assign) BOOL tb_eleUseManualHeight;

// 在cell选中之后调用，只对UITableViewCell有效。
// 该属性在默认情况下，cell选中后会执行 [tableView deselectRowAtIndexPath:indexPath animated:YES] 操作；
// 如果不想在cell选中时执行上面的操作，则需要主动将该属性置为nil。
@property (nonatomic, copy) void(^tb_cellDeselect)(UITableView *tableView, NSIndexPath *indexPath);

// 设置cell被选中时的回调，只对UITableViewCell有效
@property (nonatomic, copy) void(^tb_cellDidSelect)(id model, NSIndexPath *indexPath);

@end
