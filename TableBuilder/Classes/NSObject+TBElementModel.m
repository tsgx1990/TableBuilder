//
//  NSObject+TBElementModel.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "NSObject+TBElementModel.h"
#import "TBTableViewElementHelper.h"
#import <objc/runtime.h>

@implementation TBElementModelWeakWrapper

+ (instancetype)weakWithData:(id)data
{
    TBElementModelWeakWrapper *wrapper = TBElementModelWeakWrapper.new;
    wrapper.data = data;
    return wrapper;
}

@end

@implementation NSObject (TBElementModel)

- (UITableView *)tb_tableView
{
    return [TBTableViewElementHelper tableViewForModel:self];
}

- (UIView<TBTableViewElement> *)tb_element
{
    return [TBTableViewElementHelper elementForModel:self];
}

- (void)setTb_eleClass:(Class)tb_eleClass
{
    Class eleClass = objc_getAssociatedObject(self, @selector(tb_eleClass));
    if (eleClass && eleClass == tb_eleClass) {
        return;
    }
    assert(!eleClass && tb_eleClass);
    objc_setAssociatedObject(self, @selector(tb_eleClass), tb_eleClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (Class)tb_eleClass
{
    Class eleClass = objc_getAssociatedObject(self, _cmd);
    if (eleClass) {
        return eleClass;
    }
    else {
        eleClass = self.class.tb_eleClass;
        assert(eleClass);
        self.tb_eleClass = eleClass;
        return eleClass;
    }
}

- (void)setTb_eleReuseID:(NSString *)tb_eleReuseID
{
    NSString *reuseID = objc_getAssociatedObject(self, @selector(tb_eleReuseID));
    if (reuseID && [reuseID isEqualToString:tb_eleReuseID]) {
        return;
    }
    assert(!reuseID && !!tb_eleReuseID.length);
    objc_setAssociatedObject(self, @selector(tb_eleReuseID), tb_eleReuseID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tb_eleReuseID
{
    NSString *reuseID = objc_getAssociatedObject(self, _cmd);
    if (reuseID) {
        return reuseID;
    }
    else {
        reuseID = NSStringFromClass(self.tb_eleClass);
        self.tb_eleReuseID = reuseID;
        return reuseID;
    }
}

- (void)setTb_eleUseXib:(BOOL)tb_eleUseXib
{
    NSNumber *useXibObj = objc_getAssociatedObject(self, @selector(tb_eleUseXib));
    if (useXibObj && useXibObj.boolValue == tb_eleUseXib) {
        return;
    }
    assert(!useXibObj);
    objc_setAssociatedObject(self, @selector(tb_eleUseXib), @(tb_eleUseXib), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tb_eleUseXib
{
    NSNumber *useXibObj = objc_getAssociatedObject(self, _cmd);
    if (useXibObj) {
        return useXibObj.boolValue;
    }
    else {
        self.tb_eleUseXib = NO;
        return NO;
    }
}

+ (void)setTb_eleClass:(Class)tb_eleClass
{
    Class eleClass = objc_getAssociatedObject(self, @selector(tb_eleClass));
    if (eleClass && eleClass == tb_eleClass) {
        return;
    }
    assert(!eleClass && tb_eleClass);
    objc_setAssociatedObject(self, @selector(tb_eleClass), tb_eleClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (Class)tb_eleClass
{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - - element delelgate
- (void)setTb_eleDelegate:(id)tb_eleDelegate
{
    objc_setAssociatedObject(self, @selector(tb_eleDelegate), tb_eleDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)tb_eleDelegate
{
    id delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        return self.tb_eleWeakDelegate;
    }
    return delegate;
}

- (void)setTb_eleWeakDelegate:(id)tb_eleWeakDelegate
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(self, @selector(tb_eleWeakDelegate));
    if (!wrapper && tb_eleWeakDelegate) {
        wrapper = [TBElementModelWeakWrapper weakWithData:tb_eleWeakDelegate];
        objc_setAssociatedObject(self, @selector(tb_eleWeakDelegate), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        wrapper.data = tb_eleWeakDelegate;
    }
}

- (id)tb_eleWeakDelegate
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(self, _cmd);
    return wrapper.data;
}

#pragma mark - - element model setter
- (void)setTb_eleSetter:(id<TBElementModelSetter>)tb_eleSetter
{
    objc_setAssociatedObject(self, @selector(tb_eleSetter), tb_eleSetter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<TBElementModelSetter>)tb_eleSetter
{
    id setter = objc_getAssociatedObject(self, _cmd);
    if (!setter) {
        return self.tb_eleWeakSetter;
    }
    return setter;
}

- (void)setTb_eleWeakSetter:(id<TBElementModelSetter>)tb_eleWeakSetter
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(self, @selector(tb_eleWeakSetter));
    if (!wrapper && tb_eleWeakSetter) {
        wrapper = [TBElementModelWeakWrapper weakWithData:tb_eleWeakSetter];
        objc_setAssociatedObject(self, @selector(tb_eleWeakSetter), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        wrapper.data = tb_eleWeakSetter;
    }
}

- (id<TBElementModelSetter>)tb_eleWeakSetter
{
    TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(self, _cmd);
    return wrapper.data;
}

- (void)setTb_eleSetBlock:(void (^)(id, id<TBTableViewElement>))tb_eleSetBlock
{
    objc_setAssociatedObject(self, @selector(tb_eleSetBlock), tb_eleSetBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id, id<TBTableViewElement>))tb_eleSetBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTb_eleDoNotCacheHeight:(BOOL)tb_eleDoNotCacheHeight
{
    objc_setAssociatedObject(self, @selector(tb_eleDoNotCacheHeight), @(tb_eleDoNotCacheHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tb_eleDoNotCacheHeight
{
    NSNumber *obj = objc_getAssociatedObject(self, _cmd);
    return obj.boolValue;
}

- (void)setTb_eleRefreshHeightCache:(BOOL)tb_eleRefreshHeightCache
{
    objc_setAssociatedObject(self, @selector(tb_eleRefreshHeightCache), @(tb_eleRefreshHeightCache), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tb_eleRefreshHeightCache
{
    NSNumber *obj = objc_getAssociatedObject(self, _cmd);
    return obj.boolValue;
}

- (void)setTb_eleSetSync:(BOOL)tb_eleSetSync
{
    objc_setAssociatedObject(self, @selector(tb_eleSetSync), @(tb_eleSetSync), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tb_eleSetSync
{
    NSNumber *obj = objc_getAssociatedObject(self, _cmd);
    return obj.boolValue;
}

- (void)setTb_eleHeight:(CGFloat)tb_eleHeight
{
    objc_setAssociatedObject(self, @selector(tb_eleHeight), @(tb_eleHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)tb_eleHeight
{
    NSNumber *obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj.floatValue;
    }
    else {
        CGFloat h = [TBTableViewElementHelper calculatedHeigthForModel:self];
        return h;
    }
}

- (BOOL)tb_eleHeightIsFixed
{
    NSNumber *obj = objc_getAssociatedObject(self, @selector(tb_eleHeight));
    return !!obj;
}

- (void)setTb_eleColor:(UIColor *)tb_eleColor
{
    objc_setAssociatedObject(self, @selector(tb_eleColor), tb_eleColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)tb_eleColor
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTb_cellSelectedColor:(UIColor *)tb_cellSelectedColor
{
    objc_setAssociatedObject(self, @selector(tb_cellSelectedColor), tb_cellSelectedColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)tb_cellSelectedColor
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTb_eleUseManualHeight:(BOOL)tb_eleUseManualHeight
{
    NSNumber *obj = objc_getAssociatedObject(self,  @selector(tb_eleUseManualHeight));
    if (obj && obj.boolValue == tb_eleUseManualHeight) {
        return;
    }
    assert(!obj);
    objc_setAssociatedObject(self, @selector(tb_eleUseManualHeight), @(tb_eleUseManualHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tb_eleUseManualHeight
{
    NSNumber *obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj.boolValue;
    }
    else {
        self.tb_eleUseManualHeight = NO;
        return NO;
    }
}

- (void)setTb_eleHorizontalMargin:(CGFloat)tb_eleHorizontalMargin
{
    objc_setAssociatedObject(self, @selector(tb_eleHorizontalMargin), @(tb_eleHorizontalMargin), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)tb_eleHorizontalMargin
{
    NSNumber *obj = objc_getAssociatedObject(self, _cmd);
    return obj.floatValue;
}

- (void)setTb_cellDeselectRow:(void (^)(UITableView *, NSIndexPath *))tb_cellDeselectRow
{
    objc_setAssociatedObject(self, _cmd, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, @selector(tb_cellDeselectRow), tb_cellDeselectRow, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITableView *, NSIndexPath *))tb_cellDeselectRow
{
    id setted = objc_getAssociatedObject(self, @selector(setTb_cellDeselectRow:));
    if (setted) {
        return objc_getAssociatedObject(self, _cmd);
    }
    else {
        return ^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        };
    }
}

- (void)setTb_cellDidSelect:(void (^)(id, NSIndexPath *))tb_cellDidSelect
{
    objc_setAssociatedObject(self, @selector(tb_cellDidSelect), tb_cellDidSelect, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id, NSIndexPath *))tb_cellDidSelect
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)tb_reload:(BOOL)reloadIfNeeded
{
    if (!self.tb_tableView) {
        return;
    }
    if (reloadIfNeeded) {
        // 判断该model对应的element高度是否发生了变化，
        // 如果高度发生了变化，则需要 [tableView reloadData]。
        [TBTableViewElementHelper reloadDataWithModelIfNeeded:self];
    }
    else {
        [TBTableViewElementHelper updateElementWithModel:self];
    }
}

@end
