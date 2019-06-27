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

@property (nonatomic, assign) BOOL tb_eleUseXib;

@property (nonatomic, strong) id tb_eleDelegate;
// 如果会带来循环引用，则使用 weakEleDelegate 而不是 eleDelegate；
// 如果设置了 tb_eleWeakDelegate，而没有设置 eleDelegate，则通过 eleDelegate 获取到的是 tb_eleWeakDelegate
@property (nonatomic, weak) id tb_eleWeakDelegate;

@property (nonatomic, strong) id<TBElementModelSetter> tb_eleSetter;
@property (nonatomic, weak) id<TBElementModelSetter> tb_eleWeakSetter;

@end
