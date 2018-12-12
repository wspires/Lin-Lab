//
//  MAExpressionCell.h
//  Lin Lab
//
//  Created by Wade Spires on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAExpressionCell : UITableViewCell

@property (copy, nonatomic) NSString *expression;

@property (strong, nonatomic) IBOutlet UILabel *expressionLabel;

@end
