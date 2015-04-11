//
//  ResultsTableViewCell.h
//  Are You Open
//
//  Created by Yun Jang on 4/11/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsTableViewCell : UITableViewCell

- (void) setStoreNameText:(NSString *)string;
- (void) setAddressText:(NSString *)string;
- (void) setOpenStatus:(id)openStatus;

@end
