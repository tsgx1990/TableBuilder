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
    BOOL isForCalculate = element.tb_forCalculateHeight;
    if (!isForCalculate) {
        [self setSelectedColorWithModel:model forElement:element];
        // 将model和element关联起来
        [self setModel:model withElement:element];
    }
    
    // 解决 header 或者 footer 在转屏后的自动布局问题
    if (!element.contentView.translatesAutoresizingMaskIntoConstraints) {
        element.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    if (model.tb_eleSetBlock) {
        model.tb_eleSetBlock(model, element);
    }
    else if (model.tb_eleSetter) {
        if ([model.tb_eleSetter respondsToSelector:@selector(setModel:forElement:)]) {
            [model.tb_eleSetter setModel:model forElement:element];
        }
    }
    else {
        if ([element respondsToSelector:@selector(tb_syncSetModel:)]) {
            [element tb_syncSetModel:model];
        }
    }
}

+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    [self markElementAsHeightCalculate:element];
    [self setModel:model forElement:element];
    CGFloat cellHeight = 0;
    BOOL useManualHeight = model.tb_eleUseManualHeight;
    
    if (!useManualHeight && element.contentView.constraints.count > 0) {
        CGSize size = [element.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        // +0.5 是为了解决iOS自动布局计算高度的一个bug
        cellHeight = size.height + 0.5;
    }
    if (useManualHeight || cellHeight < 0.6) {
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
static void *_tb_elementPrevModelKey = &_tb_elementPrevModelKey;
static void *_tb_elementModelKey = &_tb_elementModelKey;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    if (!model || !element) {
        return;
    }
    objc_setAssociatedObject(element, _tb_elementPrevModelKey, element.tb_model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(element, _tb_elementModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    BOOL isForCalculate = element.tb_forCalculateHeight;
    if (!isForCalculate) {
        // 将element与之前的model解除关联
        [self setModel:element.tb_prevModel withElement:nil];
        // 同步设置element的背景色
        UIColor *color = model.tb_eleColor ?: element.tb_defaultColor;
        [self setColor:color forElement:element];
    }
    
    BOOL isSyncSet = model.tb_eleSetSync;
    if (isSyncSet || isForCalculate) {
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

+ (NSObject *)prevModelForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_elementPrevModelKey);
}

#pragma mark - - set model's element and tableView
static void *_tb_elementForModelKey = &_tb_elementForModelKey;
+ (void)setModel:(NSObject *)model withElement:(UIView<TBTableViewElement> *)element
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(model, _tb_elementForModelKey);
    if (!wrapper && element) {
        wrapper = [TBElementModelWeakWrapper weakWithData:element];
        objc_setAssociatedObject(model, _tb_elementForModelKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        wrapper.data = element;
    }
}

+ (UIView<TBTableViewElement> *)elementForModel:(NSObject *)model
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(model, _tb_elementForModelKey);
    return wrapper.data;
}

static void *_tb_tableViewForModelKey = &_tb_tableViewForModelKey;
+ (void)setModel:(NSObject *)model withTableView:(UITableView *)tableView
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(model, _tb_tableViewForModelKey);
    if (!wrapper && tableView) {
        wrapper = [TBElementModelWeakWrapper weakWithData:tableView];
        objc_setAssociatedObject(model, _tb_tableViewForModelKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        wrapper.data = tableView;
    }
}

+ (UITableView *)tableViewForModel:(NSObject *)model
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(model, _tb_tableViewForModelKey);
    return wrapper.data;
}

#pragma mark - - update element
+ (void)updateElementWithModel:(NSObject *)model
{
    if (!model.tb_tableView) {
        return;
    }
    UIView<TBTableViewElement> *element = model.tb_element;
    // 如果 element == nil，说明model相关的element未显示出来；
    // 但是这时仍然需要判断该model对应的element高度是否发生了变化；
    // 如果高度发生了变化，则需要 [tableView reloadData]。
    if (element) {
        assert(model.tb_eleClass == element.class);
        [self setModel:model forElement:element];
    }
    SEL aSel = @selector(_reloadDataWithModelIfNeeded:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:aSel object:model];
    [self performSelector:aSel withObject:model afterDelay:0];
}

// 如果model的改变引起element的高度变化，则需要 [tableView reloadData]
+ (void)_reloadDataWithModelIfNeeded:(NSObject *)model
{
    UITableView *tableView = model.tb_tableView;
    if (!tableView) {
        return;
    }
    CGFloat prevHeight = model.tb_eleHeight;
    model.tb_eleRefreshHeightCache = YES;
    CGFloat height = [self heightWithModel:model inTableView:tableView];
    if (fabs(prevHeight - height) >= 0.5) {
        [self _reloadTableView:tableView];
    }
}

+ (void)_reloadTableView:(UITableView *)tableView
{
    // 不使用局部刷新而是采用整体刷新的原因是：tableView的局部刷新方法会创建新的cell
    SEL aSel = @selector(reloadData);
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView selector:aSel object:nil];
    [tableView performSelector:aSel withObject:nil afterDelay:0];
}

+ (UITableView *)tableViewForElement:(UIView<TBTableViewElement> *)element
{
    static void *tb_elementTableViewKey = &tb_elementTableViewKey;
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(element, tb_elementTableViewKey);
    if (!wrapper) {
        wrapper = TBElementModelWeakWrapper.new;
        objc_setAssociatedObject(element, tb_elementTableViewKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UITableView *tv = wrapper.data;
    if (tv) {
        return tv;
    }
    tv = (id)element.superview;
    while (![tv isKindOfClass:UITableView.class]) {
        tv = (id)tv.superview;
    }
    wrapper.data = tv;
    return tv;
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

#pragma mark - - color
static void *_tb_elementDefaultColorKey = &_tb_elementDefaultColorKey;

+ (void)setDefaultColor:(UIColor *)defaultColor forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_elementDefaultColorKey, defaultColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setColor:defaultColor forElement:element];
}

+ (UIColor *)defaultColorForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_elementDefaultColorKey);
}

+ (void)setColor:(UIColor *)color forElement:(UIView<TBTableViewElement> *)element
{
    if (color) {
        element.backgroundColor = element.contentView.backgroundColor = color;
    }
}

#pragma mark - - selected color
static void *_tb_cellDefaultSelectedColorKey = &_tb_cellDefaultSelectedColorKey;

+ (void)setDefaultSelectedColor:(UIColor *)defaultSelectedColor forElement:(UIView<TBTableViewElement> *)element
{
    objc_setAssociatedObject(element, _tb_cellDefaultSelectedColorKey, defaultSelectedColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setSelectedColor:defaultSelectedColor forElement:element];
}

+ (UIColor *)defaultSelectedColorForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_cellDefaultSelectedColorKey);
}

+ (void)setSelectedColor:(UIColor *)selectedColor forElement:(UIView<TBTableViewElement> *)element
{
    if (selectedColor
        && [element respondsToSelector:@selector(selectedBackgroundView)]
        && [element respondsToSelector:@selector(selectionStyle)]) {
        
        static void *customSelectedBackgroundViewKey = &customSelectedBackgroundViewKey;
        if (!objc_getAssociatedObject(element.selectedBackgroundView, customSelectedBackgroundViewKey)) {
            element.selectedBackgroundView = UIView.new;
            objc_setAssociatedObject(element.selectedBackgroundView, customSelectedBackgroundViewKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        element.selectionStyle = UITableViewCellSelectionStyleDefault;
        element.selectedBackgroundView.backgroundColor = selectedColor;
    }
}

// 设置cell的选中颜色
+ (void)setSelectedColorWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    if ([element respondsToSelector:@selector(setTb_defaultSelectedColor:)]) {
        UIColor *selectedColor = model.tb_cellSelectedColor ?: element.tb_defaultSelectedColor;
        [self setSelectedColor:selectedColor forElement:element];
    }
}

#pragma mark - - calculate height
+ (CGFloat)heightWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    if (!eleClass || !reuseID) {
        return 0;
    }
    
    // 设置model所对应的tableView
    [self setModel:model withTableView:tableView];
    
    // 注册element复用标识，返回的element可以用于后续的高度计算；如果已经注册过，则返回nil
    UIView<TBTableViewElement> *elementForCal = [self registerElementWithModel:model inTableView:tableView];
    
    // 如果通过model指定了element的高度，则直接返回该高度
    if (model.tb_eleHeightIsFixed) {
        return model.tb_eleHeight;
    }
    
    // 处理不需要缓存高度的情况
    if (model.tb_eleDoNotCacheHeight) {
        CGFloat eleHeight = [self calHeightWithElement:elementForCal andModel:model inTableView:tableView];
        return eleHeight;
    }
    
    NSString *tableWidthKeyStr = [NSStringFromSelector(_cmd) stringByAppendingFormat:@"%p", tableView];
    SEL tableWidthKey = NSSelectorFromString(tableWidthKeyStr);
    NSNumber *tableWidthObj = objc_getAssociatedObject(model, tableWidthKey);
    
    // 刷新高度缓存时将该标志置为NO，为了下次element刷新的时候依然使用缓存
    if (model.tb_eleRefreshHeightCache) {
        model.tb_eleRefreshHeightCache = NO;
    }
    // 如果tableView的宽度未发生改变，则直接从缓存中获取高度
    else if (tableWidthObj && fabs(tableWidthObj.floatValue - tableView.frame.size.width) < DBL_EPSILON) {
        return [self calculatedHeigthForModel:model];
    }
    
    objc_setAssociatedObject(model, tableWidthKey, @(tableView.frame.size.width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 如果tableView的宽度发生了改变，element 的高度需要重新计算，并缓存到model中
    CGFloat eleHeight = [self calHeightWithElement:elementForCal andModel:model inTableView:tableView];
    [self setCalculatedHeight:eleHeight forModel:model];
    return eleHeight;
}

+ (CGFloat)calHeightWithElement:(UIView<TBTableViewElement> *)element andModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    // 创建用于计算高度的 element，这些 element 在计算完高度之后会被释放
    UIView<TBTableViewElement> *elementForCal = [self elementWithModel:model initialElement:element inTableView:tableView];
    CGFloat eleHeight = [self heightWithModel:model forElement:elementForCal];
    return eleHeight;
}

+ (UIView<TBTableViewElement> *)registerElementWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    
    static void *elementRegister = &elementRegister;
    // register elementClass or elementNib
    NSMutableSet *reuseIDStore = objc_getAssociatedObject(tableView, elementRegister);
    if (!reuseIDStore) {
        reuseIDStore = [NSMutableSet setWithCapacity:3];
        objc_setAssociatedObject(tableView, elementRegister, reuseIDStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // 如果已经注册过，不再重复注册
    if ([reuseIDStore containsObject:reuseID]) {
        return nil;
    }
    
    UIView<TBTableViewElement> *element = nil;
    if (model.tb_eleUseXib) {
        NSString *xibName = NSStringFromClass(eleClass);
        @try {
            element = [[NSBundle.mainBundle loadNibNamed:xibName owner:nil options:nil] lastObject];
        } @catch (NSException *exception) {
            // 如果 xib 文件不存在，则会抛出该异常
            NSLog(@">>> %@", exception);
        }
        if (element) {
            UINib *nib = [UINib nibWithNibName:xibName bundle:nil];
            if ([eleClass isSubclassOfClass:UITableViewCell.class]) {
                [tableView registerNib:nib forCellReuseIdentifier:reuseID];
            }
            else {
                [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:reuseID];
            }
        }
    }
    if (!element) {
        if ([eleClass isSubclassOfClass:UITableViewCell.class]) {
            [tableView registerClass:eleClass forCellReuseIdentifier:reuseID];
        }
        else {
            [tableView registerClass:eleClass forHeaderFooterViewReuseIdentifier:reuseID];
        }
    }
    [reuseIDStore addObject:reuseID];
    return element;
}

+ (UIView<TBTableViewElement> *)elementWithModel:(NSObject *)model initialElement:(UIView<TBTableViewElement> *)initialElement inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    
    static void *elementCalculator = &elementCalculator;
    NSMutableDictionary *calEleStore = objc_getAssociatedObject(tableView, elementCalculator);
    if (!calEleStore) {
        calEleStore = [NSMutableDictionary dictionaryWithCapacity:3];
        objc_setAssociatedObject(tableView, elementCalculator, calEleStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSArray *arr = [calEleStore valueForKey:reuseID];
    NSNumber *storeTableWidth = arr.firstObject;
    UIView<TBTableViewElement> *element = arr.lastObject;
    
    BOOL shouldUpdate = NO;
    if (!element) {
        shouldUpdate = YES;
        element = initialElement;
        if (!element && model.tb_eleUseXib) {
            NSString *xibName = NSStringFromClass(eleClass);
            @try {
                element = [[NSBundle.mainBundle loadNibNamed:xibName owner:nil options:nil] lastObject];
            } @catch (NSException *exception) {
                NSLog(@">>> %@", exception);
            }
        }
        if (!element) {
            if ([eleClass isSubclassOfClass:UITableViewCell.class]) {
                element = [eleClass.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            }
            else {
                element = [eleClass.alloc initWithReuseIdentifier:reuseID];
            }
        }
        // 在计算完 element 的高度之后，最后一次性全部移除这些用于计算高度的 element，防止不必要的内存占用
        if (!calEleStore.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [calEleStore removeAllObjects];
            });
        }
    }
    if (!storeTableWidth || fabs(storeTableWidth.floatValue - tableView.frame.size.width) > DBL_EPSILON) {
        shouldUpdate = YES;
        element.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
        if (element.contentView.constraints.count > 0) {
            [element.contentView.constraints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSLayoutConstraint *obj, NSUInteger idx, BOOL *stop) {
                if (obj.firstItem == element.contentView
                    && (obj.firstAttribute == NSLayoutAttributeWidth || obj.firstAttribute == NSLayoutAttributeHeight)) {
                    obj.active = NO;
                    // *stop = YES; // 某些情况下会导致无法计算高度
                }
            }];
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:element.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:tableView.frame.size.width];
            if (@available(iOS 8.0, *)) {
                widthConstraint.active = YES;
            } else {
                [element.contentView addConstraint:widthConstraint];
            }
        }
    }
    
    if (shouldUpdate) {
        arr = @[@(tableView.frame.size.width), element];
        [calEleStore setValue:arr forKey:reuseID];
    }
    return element;
}

@end
