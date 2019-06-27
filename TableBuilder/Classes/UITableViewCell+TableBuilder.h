//
//  UITableViewCell+TableBuilder.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTableViewElementHelper.h"

@protocol TBTableViewCellDelegate <NSObject>

@optional
- (void)didSelectCell:(UITableViewCell *)cell withModel:(NSObject *)model;

@end

@interface UITableViewCell (TableBuilder) <TBTableViewElement>

@property (nonatomic, readonly) id<TBTableViewCellDelegate> tb_delegate;

@end
