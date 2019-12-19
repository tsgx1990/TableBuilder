//
//  TBTableViewElementHelper.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TBTableViewElementHelper.h"
#import <objc/runtime.h>

@implementation TBTableViewElementHelper

+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    [self markElementAsHeightCalculate:element];
    [self setModel:model forElement:element];
    CGFloat cellHeight = 0;
    BOOL useManualHeight = model.tb_eleUseManualHeight;
    
    if (!useManualHeight && element.contentView.constraints.count > 0) {
        CGSize size = [element.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        cellHeight = size.height;
    }
    if (useManualHeight || cellHeight < 0.1) {
        [element setNeedsLayout];
        [element layoutIfNeeded];
        if (model.tb_eleGetHeight) {
            cellHeight = model.tb_eleGetHeight(model);
        }
        else {
            assert([element respondsToSelector:@selector(tb_elementHeightForModel:)]);
            cellHeight = [element tb_elementHeightForModel:model];
        }
    }
    
    if (cellHeight < 0) {
        NSLog(@"element 高度计算异常，将自动设置为0！");
        return 0;
    }
    
    if (model.tb_tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        cellHeight += (1.0 / UIScreen.mainScreen.scale);
    }
    // 无论是否要求缓存，都将计算出的高度缓存起来，这样就可以通过 model.tb_eleHeight 获取这个高度
    [self _cacheCalculatedHeight:cellHeight forModel:model];
    return cellHeight;
}

// 缓存计算出来的cell高度
static void *_tb_modelCalculatedHeightKey = &_tb_modelCalculatedHeightKey;
+ (void)_cacheCalculatedHeight:(CGFloat)height forModel:(NSObject *)model
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
static void *_tb_elementModelKey = &_tb_elementModelKey;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    if (!model || !element) {
        return;
    }
    NSObject *prevModel = element.tb_model;
    objc_setAssociatedObject(element, _tb_elementModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([element respondsToSelector:@selector(tb_alwaysPerformWithModel:)]) {
        [element tb_alwaysPerformWithModel:model];
    }
    
    // 如果新model和prevModel是同一个model，则根据model的needUpdate标志来确定是否需要更新element。
    // 如果需要更新，则在更新element的同时把model的needUpdate标志置为NO
    if (model == prevModel) {
        BOOL needUpdate = [self needUpdateElementForModel:model];
        if (!needUpdate) {
            return;
        }
        else if (!element.tb_forCalculateHeight) {
            [self setNeedUpdateElement:NO forModel:model];
        }
    }
    // 如果新model和prevModel是不同的model，则通过比较两个model来决定是否需要刷新element
    else {
        BOOL isModelEqual = NO;
        if (model.tb_modelIsEqual) {
            isModelEqual = model.tb_modelIsEqual(model, prevModel);
        }
        else {
            isModelEqual = [model isEqual:prevModel];
        }
        if (isModelEqual) {
            return;
        }
    }
    [self _setModel:model forElement:element];
}

+ (void)_setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    BOOL isForCalculate = element.tb_forCalculateHeight;
    if (!isForCalculate) {
        // 同步设置element的背景色
        UIColor *color = model.tb_eleColor ?: element.tb_defaultColor;
        [self setColor:color forElement:element];
    }
    
    if ([element respondsToSelector:@selector(tb_preprocessWithModel:)]) {
        [element tb_preprocessWithModel:model];
    }
    
    if (isForCalculate) {
        [self _syncSetElement:element];
    }
    else {
        [self __setModel:model forElement:element];
    }
}

+ (void)__setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element
{
    // 如果正在对element用同一个model进行异步设置，则直接return
    static void *tb_elementSettingKey = &tb_elementSettingKey;
    NSObject *settingModel = objc_getAssociatedObject(element, tb_elementSettingKey);
    if (settingModel == model) {
        NSLog(@"同样的model正在对该element进行异步设置");
        return;
    }
    if (model.tb_eleSetSync) {
        [self _syncSetElement:element];
        return;
    }
    
    objc_setAssociatedObject(element, tb_elementSettingKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        objc_setAssociatedObject(element, tb_elementSettingKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (model == element.tb_model) {
            [self _syncSetElement:element];
        }
        else {
            NSLog(@"Model for this element is changed!");
        }
    });
}

+ (void)_syncSetElement:(UIView<TBTableViewElement> *)element
{
    NSObject *model = element.tb_model;
    if (!element.tb_forCalculateHeight) {
        [self setSelectedColorWithModel:model forElement:element];
    }
    
    // 解决 header 或者 footer 在转屏后的自动布局问题
    if (!element.contentView.translatesAutoresizingMaskIntoConstraints) {
        element.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    if (model.tb_eleSetBlock) {
        model.tb_eleSetBlock(model, element);
    }
    else if ([model.tb_eleSetter respondsToSelector:@selector(setModel:forElement:)]) {
        [model.tb_eleSetter setModel:model forElement:element];
    }
    else if ([element respondsToSelector:@selector(tb_syncSetModel:)]) {
        [element tb_syncSetModel:model];
    }
    [element setNeedsLayout];
}

+ (NSObject *)modelForElement:(UIView<TBTableViewElement> *)element
{
    return objc_getAssociatedObject(element, _tb_elementModelKey);
}

#pragma mark - - set model's indexPath or section
static void *_tb_modelIndexPathKey = &_tb_modelIndexPathKey;
+ (void)setModel:(NSObject *)model withIndexPath:(NSIndexPath *)indexPath
{
    if (model) {
        objc_setAssociatedObject(model, _tb_modelIndexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

+ (NSIndexPath *)indexPathForModel:(NSObject *)model
{
    NSIndexPath *indexPath = objc_getAssociatedObject(model, _tb_modelIndexPathKey);
    if (indexPath && model.tb_tableView) {
        return indexPath;
    }
    return nil;
}

static void *_tb_modelSectionKey = &_tb_modelSectionKey;
+ (void)setModel:(NSObject *)model withSection:(NSInteger)section type:(TBElementModelType)eleType
{
    if (model) {
        objc_setAssociatedObject(model, _tb_modelSectionKey, @(section), OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self _setModel:model withType:eleType];
    }
}

+ (NSInteger)sectionForModel:(NSObject *)model
{
    NSNumber *obj = objc_getAssociatedObject(model, _tb_modelSectionKey);
    if (obj && model.tb_tableView) {
        return [obj integerValue];
    }
    NSIndexPath *indexPath = model.tb_indexPath;
    if (indexPath) {
        return indexPath.section;
    }
    return NSNotFound;
}

static void *_tb_modelEleTypeKey = &_tb_modelEleTypeKey;
+ (void)_setModel:(NSObject *)model withType:(TBElementModelType)type
{
    assert(type == TBElementModelTypeHeader || type == TBElementModelTypeFooter);
    objc_setAssociatedObject(model, _tb_modelEleTypeKey, @(type), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (TBElementModelType)eleTypeForModel:(NSObject *)model
{
    if ([model.tb_eleClass isSubclassOfClass:UITableViewCell.class]) {
        return TBElementModelTypeCell;
    }
    NSNumber *obj = objc_getAssociatedObject(model, _tb_modelEleTypeKey);
    if (obj && model.tb_tableView) {
        return (TBElementModelType)[obj integerValue];
    }
    return TBElementModelTypeUnknown;
}

#pragma mark - - need update element
static void *_tb_needUpdateElementKey = &_tb_needUpdateElementKey;
+ (void)setNeedUpdateElement:(BOOL)need forModel:(NSObject *)model
{
    objc_setAssociatedObject(model, _tb_needUpdateElementKey, @(need), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// 默认返回YES
+ (BOOL)needUpdateElementForModel:(NSObject *)model
{
    NSNumber *obj = objc_getAssociatedObject(model, _tb_needUpdateElementKey);
    if (obj) {
        return obj.boolValue;
    }
    return YES;
}

#pragma mark - - need update height cache
static void *_tb_needRefreshHeightCacheKey = &_tb_needRefreshHeightCacheKey;
+ (void)setNeedRefreshHeightCache:(BOOL)need forModel:(NSObject *)model
{
    objc_setAssociatedObject(model, _tb_needRefreshHeightCacheKey, @(need), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (BOOL)needRefreshHeightCacheForModel:(NSObject *)model
{
    NSNumber *obj = objc_getAssociatedObject(model, _tb_needRefreshHeightCacheKey);
    return obj.boolValue;
}

+ (UIView<TBTableViewElement> *)elementForModel:(NSObject *)model
{
    UITableView *tableView = model.tb_tableView;
    if (!tableView) {
        return nil;
    }
    UIView<TBTableViewElement> *element = nil;
    TBElementModelType eleType = model.tb_eleType;
    if (eleType == TBElementModelTypeCell) {
        element = (id)[tableView cellForRowAtIndexPath:model.tb_indexPath];
    }
    else if (eleType == TBElementModelTypeHeader) {
        element = (id)[tableView headerViewForSection:model.tb_section];
    }
    else if (eleType == TBElementModelTypeFooter) {
        element = (id)[tableView footerViewForSection:model.tb_section];
    }
    else {
        assert(0);
    }
    return element;
}

#pragma mark - - set model's tableView
static void *_tb_tableViewForModelKey = &_tb_tableViewForModelKey;
// 在 model 中存储一个 tableView 的弱引用
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
    // 将 model 的 version 和 tableView 的保持一致
    NSUInteger version = [self versionForReloadObject:tableView];
    [self setVersion:version forReloadObject:model];
}

// 若 model 中存在一个 tableView 的弱引用，并不能确定 model 已经加入列表，
// 还需要判断该 model 和 tableView 的version是否一致
+ (UITableView *)tableViewForModel:(NSObject *)model
{
    if (!model) {
        return nil;
    }
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(model, _tb_tableViewForModelKey);
    if (!wrapper || !wrapper.data) {
        return nil;
    }
    UITableView *tableView = wrapper.data;
    NSUInteger tableVersion = [self versionForReloadObject:tableView];
    NSUInteger modelVersion = [self versionForReloadObject:model];
    if (tableVersion == modelVersion) {
        return tableView;
    }
    wrapper.data = nil;
    return nil;
}

#pragma mark - - update element
+ (void)updateElementWithModel:(NSObject *)model
{
    [self _cancelUpdateElementWithModel:model];
    [self performSelector:@selector(_updateElementWithModel:) withObject:model afterDelay:0];
}

+ (void)_updateElementWithModel:(NSObject *)model
{
    UIView<TBTableViewElement> *element = model.tb_element;
    if (element) {
        assert(model.tb_eleClass == element.class);
        [self setModel:model forElement:element];
    }
}

+ (void)_cancelUpdateElementWithModel:(NSObject *)model
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateElementWithModel:) object:model];
}

// 如果model的改变引起element的高度变化，则需要 [tableView reloadData]
+ (void)reloadDataIfNeededWithModel:(NSObject *)model
{
    [self _cancelUpdateElementWithModel:model];
    SEL reloadSel = @selector(_reloadDataIfNeededWithModel:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:reloadSel object:model];
    [self performSelector:reloadSel withObject:model afterDelay:0];
}

+ (void)_reloadDataIfNeededWithModel:(NSObject *)model
{
    UITableView *tableView = model.tb_tableView;
    if (!model || !tableView) {
        return;
    }
    [self updateElementWithModel:model];
    BOOL isCellClass = [model.tb_eleClass isSubclassOfClass:UITableViewCell.class];
    UIView<TBTableViewElement> *element = model.tb_element;
    
    // 如果 model.needRefreshHeightCache == YES（比如修改了 model.tb_eleHeight），则直接刷新列表
    if ([self needRefreshHeightCacheForModel:model]) {
        // 如果element是一个 UITableViewCell 且未显示，则不需要刷新列表，只需重新计算高度
        if (!element && isCellClass) {
            // 重新计算 UITableViewCell 的高度并缓存起来
            [self heightWithModel:model inTableView:tableView];
        }
        else {
            [self _delayReloadTableView:tableView];
        }
        return;
    }
    
    CGFloat prevHeight = model.tb_eleHeight;
    [model tb_needRefreshHeightCache];
    // 调用该方法将会重新计算model的高度，并缓存起来
    CGFloat currHeight = [self heightWithModel:model inTableView:tableView];
    
    // 对于未显示出来的 UITableViewCell，就算高度发生变化也不需要刷新列表，
    // 因为从iOS8开始，cell每次显示的时候都会尝试获取新高度。
    if (!element && isCellClass) {
        return;
    }
    
    // 对于 header 和 footer，以及正在显示的 UITableViewCell 的处理。
    // header和footer不会在每次显示的时候都去获取新高度，所以如果高度发生变化需要刷新列表
    if (fabs(prevHeight - currHeight) > 0.1) {
        [self _delayReloadTableView:tableView];
    }
}

+ (void)_delayReloadTableView:(UITableView *)tableView
{
    // 不使用局部刷新而是采用整体刷新的原因是：tableView的局部刷新方法会创建新的cell
    SEL aSel = @selector(_reloadTableView:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:aSel object:tableView];
    [self performSelector:aSel withObject:tableView afterDelay:0];
}

+ (void)_reloadTableView:(UITableView *)tableView
{
    [self setNeedResetReloadVersion:NO inTableView:tableView];
    [tableView reloadData];
    [self setNeedResetReloadVersion:YES inTableView:tableView];
}

static void *_tb_needResetReloadVersionKey = &_tb_needResetReloadVersionKey;
+ (void)setNeedResetReloadVersion:(BOOL)need inTableView:(UITableView *)tableView
{
    objc_setAssociatedObject(tableView, _tb_needResetReloadVersionKey, @(need), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// 默认返回YES
+ (BOOL)needResetReloadVersionInTableView:(UITableView *)tableView
{
    NSNumber *obj = objc_getAssociatedObject(tableView, _tb_needResetReloadVersionKey);
    return obj ? obj.boolValue : YES;
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
    if (tv && [element isDescendantOfView:tv]) {
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

#pragma mark - - tableView's reload version
static void *_tb_tableReloadVersionKey = &_tb_tableReloadVersionKey;
+ (void)setVersion:(NSUInteger)version forReloadObject:(id)obj
{
    objc_setAssociatedObject(obj, _tb_tableReloadVersionKey, @(version), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (NSUInteger)versionForReloadObject:(NSObject *)obj
{
    NSNumber *version = objc_getAssociatedObject(obj, _tb_tableReloadVersionKey);
    return [version unsignedIntegerValue];
}

+ (void)resetTableViewReloadVersion:(UITableView *)tableView
{
    if (tableView && [self needResetReloadVersionInTableView:tableView]) {
        NSUInteger version = [self versionForReloadObject:tableView];
        [self setVersion:(version+1) forReloadObject:tableView];
    }
}

+ (void)setModelIfNeeded:(NSObject *)model withTableView:(UITableView *)tableView
{
    if (!tableView || !model) {
        return;
    }
    // 如果 model 已经加入到 tableView 中，则无需重复添加
    if (model.tb_tableView == tableView) {
        return;
    }
    // 当 model 首次或重新加入到 tableView 时，需要设置它的 needUpdate 标志为 YES
    [self setNeedUpdateElement:YES forModel:model];
    [self setModel:model withTableView:tableView];
}

#pragma mark - - calculate height
// 该方法将会计算model的高度，并缓存起来
+ (CGFloat)heightWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    if (!eleClass || !reuseID) {
        return 0;
    }
    [self setModelIfNeeded:model withTableView:tableView];
    
    // 注册element复用标识，返回的element可以用于后续的高度计算；如果已经注册过，则返回nil
    UIView<TBTableViewElement> *elementForCal = [self registerElementWithModel:model inTableView:tableView];
    
    BOOL needRefreshHeightCache = [self needRefreshHeightCacheForModel:model];
    // 刷新高度缓存时将该标志置为NO，为了下次获取element高度时依然使用缓存
    if (needRefreshHeightCache) {
        [self setNeedRefreshHeightCache:NO forModel:model];
    }
    
    // 如果通过model指定了element的高度，则直接返回该高度
    if (model.tb_eleHeightIsFixed) {
        return model.tb_eleHeight;
    }
    
    // 处理不需要缓存高度的情况
    if (model.tb_eleDoNotCacheHeight) {
        CGFloat eleHeight = [self calHeightWithElement:elementForCal andModel:model inTableView:tableView];
        return eleHeight;
    }
    
    CGFloat contentWidth = [self contentWidthWithModel:model inTableView:tableView];
    NSString *contentWidthKeyStr = [NSStringFromSelector(_cmd) stringByAppendingFormat:@"%p", tableView];
    SEL contentWidthKey = NSSelectorFromString(contentWidthKeyStr);
    NSNumber *contentWidthObj = objc_getAssociatedObject(model, contentWidthKey);
    
    // 如果不需要刷新高度缓存且 contentWidth 未发生改变，则直接从缓存中获取高度
    if (!needRefreshHeightCache
        && contentWidthObj
        && fabs(contentWidthObj.floatValue - contentWidth) <= FLT_EPSILON) {
        return [self calculatedHeigthForModel:model];
    }
    
    objc_setAssociatedObject(model, contentWidthKey, @(contentWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 如果 contentWidth 发生了改变，element 的高度需要重新计算，并缓存到model中
    CGFloat eleHeight = [self calHeightWithElement:elementForCal andModel:model inTableView:tableView];
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
    NSNumber *storeContentWidth = arr.firstObject;
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
    
    CGFloat contentWidth = [self contentWidthWithModel:model inTableView:tableView];
    if (!storeContentWidth || fabs(storeContentWidth.floatValue - contentWidth) > FLT_EPSILON) {
        shouldUpdate = YES;
        element.contentView.frame = CGRectMake(0, 0, contentWidth, 0);
        CGFloat elementWidth = contentWidth + model.tb_eleHorizontalMargin;
        element.frame = CGRectMake(0, 0, elementWidth, 0);
        if (element.contentView.constraints.count > 0) {
            [element.contentView.constraints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSLayoutConstraint *obj, NSUInteger idx, BOOL *stop) {
                if (obj.firstItem == element.contentView
                    && (obj.firstAttribute == NSLayoutAttributeWidth || obj.firstAttribute == NSLayoutAttributeHeight)) {
                    obj.active = NO;
                    // *stop = YES; // 某些情况下会导致无法计算高度
                }
            }];
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:element.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentWidth];
            if (@available(iOS 8.0, *)) {
                widthConstraint.active = YES;
            } else {
                [element.contentView addConstraint:widthConstraint];
            }
        }
    }
    
    if (shouldUpdate) {
        arr = @[@(contentWidth), element];
        [calEleStore setValue:arr forKey:reuseID];
    }
    return element;
}

+ (CGFloat)contentWidthWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    CGFloat marginX = 0;
    if (@available(iOS 11.0, *)) {
        // 主要是为了处理 X、XR、XS 系列手机横屏的情况
        marginX = tableView.safeAreaInsets.left + tableView.safeAreaInsets.right;
    } else {
        // Fallback on earlier versions
    }
    marginX += model.tb_eleHorizontalMargin;
    return tableView.frame.size.width - marginX;
}

@end
