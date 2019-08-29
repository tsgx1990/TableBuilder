//
//  TableViewCell1.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "UITableViewCell+TableBuilder.h"
#import "TableViewCellModel1.h"

@interface TableViewCell1 : UITableViewCell

@end

TBRedefineModelType(TableViewCell1, TableViewCellModel1);
// 重复定义也不会报警告
TBRedefineModelType(TableViewCell1, TableViewCellModel1);

TBRedefineDelegateType(TableViewCell1, id);




