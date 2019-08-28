//
//  UITableViewCell+TableBuilder.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "UITableViewCell+TableBuilder.h"
#import "TBTableViewElementHelper.h"

@implementation UITableViewCell (TableBuilder)

- (NSObject *)tb_model
{
    return [TBTableViewElementHelper modelForElement:self];
}

- (UITableView *)tb_tableView
{
    return [TBTableViewElementHelper tableViewForElement:self];
}

- (id<TBTableViewCellDelegate>)tb_delegate
{
    return [TBTableViewElementHelper delegateForElement:self];
}

- (BOOL)tb_forCalculateHeight
{
    return [TBTableViewElementHelper isHeightCalForElement:self];
}

- (void)setTb_defaultColor:(UIColor *)tb_defaultColor
{
    [TBTableViewElementHelper setDefaultColor:tb_defaultColor forElement:self];
}

- (UIColor *)tb_defaultColor
{
    return [TBTableViewElementHelper defaultColorForElement:self];
}

- (void)setTb_defaultSelectedColor:(UIColor *)tb_defaultSelectedColor
{
    [TBTableViewElementHelper setDefaultSelectedColor:tb_defaultSelectedColor forElement:self];
}

- (UIColor *)tb_defaultSelectedColor
{
    return [TBTableViewElementHelper defaultSelectedColorForElement:self];
}

@end
