//
//  TBTableViewElementHelper.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTableViewElement.h"

@interface TBTableViewElementHelper : NSObject

+ (CGFloat)heightWithModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;

+ (id)delegateForElement:(UIView<TBTableViewElement> *)element;

+ (void)setModel:(NSObject *)model forElement:(UIView<TBTableViewElement> *)element;
+ (NSObject *)modelForElement:(UIView<TBTableViewElement> *)element;

+ (void)setIsHeightCal:(BOOL)heightCal forElement:(UIView<TBTableViewElement> *)element;
+ (BOOL)isHeightCalForElement:(UIView<TBTableViewElement> *)element;

@end
