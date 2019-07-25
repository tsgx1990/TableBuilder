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

@interface _TBElementModelWeakWrapper : NSObject

@property (nonatomic, weak) id data;

@end

@implementation _TBElementModelWeakWrapper

+ (instancetype)weakWithData:(id)data
{
    _TBElementModelWeakWrapper *wrapper = _TBElementModelWeakWrapper.new;
    wrapper.data = data;
    return wrapper;
}

@end

@implementation NSObject (TBElementModel)

- (void)setTb_eleClass:(Class)tb_eleClass
{
    objc_setAssociatedObject(self, @selector(tb_eleClass), tb_eleClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (Class)tb_eleClass
{
    Class eleClass = objc_getAssociatedObject(self, _cmd);
    if (eleClass) {
        return eleClass;
    }
    else {
        return self.class.tb_eleClass;
    }
}

- (void)setTb_eleReuseID:(NSString *)tb_eleReuseID
{
    objc_setAssociatedObject(self, @selector(tb_eleReuseID), tb_eleReuseID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tb_eleReuseID
{
    NSString *reuseID = objc_getAssociatedObject(self, _cmd);
    if (!reuseID) {
        reuseID = NSStringFromClass(self.tb_eleClass);
    }
    return reuseID;
}

- (void)setTb_eleUseXib:(BOOL)tb_eleUseXib
{
    objc_setAssociatedObject(self, @selector(tb_eleUseXib), @(tb_eleUseXib), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)tb_eleUseXib
{
    NSNumber *useXibObj = objc_getAssociatedObject(self, _cmd);
    return useXibObj.boolValue;
}

+ (void)setTb_eleClass:(Class)tb_eleClass
{
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
    _TBElementModelWeakWrapper *wrapper = [_TBElementModelWeakWrapper weakWithData:tb_eleWeakDelegate];
    objc_setAssociatedObject(self, @selector(tb_eleWeakDelegate), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)tb_eleWeakDelegate
{
    _TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(self, _cmd);
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
    _TBElementModelWeakWrapper *wrapper = [_TBElementModelWeakWrapper weakWithData:tb_eleWeakSetter];
    objc_setAssociatedObject(self, @selector(tb_eleWeakSetter), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<TBElementModelSetter>)tb_eleWeakSetter
{
    _TBElementModelWeakWrapper *wrapper = objc_getAssociatedObject(self, _cmd);
    return wrapper.data;
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

@end
