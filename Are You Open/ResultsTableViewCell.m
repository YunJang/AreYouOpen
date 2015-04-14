//
//  ResultsTableViewCell.m
//  Are You Open
//
//  Created by Yun Jang on 4/11/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import "ResultsTableViewCell.h"

@interface ResultsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UIView *openIndicator;
@end

@implementation ResultsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.openIndicator.layer setCornerRadius:self.openIndicator.frame.size.width/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Setters for UI

- (void)setOpenStatus:(id)openStatus
{
    if ([openStatus isKindOfClass:[NSString class]])    // yellow - unknown indicator
        [self.openIndicator setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1.0]];
    else if (![openStatus integerValue])                // red - closed indicator
        [self.openIndicator setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:0.0 blue:0.0 alpha:1.0]];
    else                                                // green - open indicator
        [self.openIndicator setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:193.0/255.0 blue:98.0/255.0 alpha:1.0]];
}

- (void) setStoreNameText:(NSString *)string
{
    [self.storeName setText:string];
}

- (void) setAddressText:(NSString *)string
{
    [self.address setText:string];
}

@end
