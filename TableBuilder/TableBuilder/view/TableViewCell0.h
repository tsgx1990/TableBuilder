//
//  TableViewCell0.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "UITableViewCell+TableBuilder.h"
#import "TableViewCellModel0.h"

@interface TableViewCell0 : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLbl;

@end

TBRedefineModelType(TableViewCell0, TableViewCellModel0);
