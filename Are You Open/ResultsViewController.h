//
//  ResultsViewController.h
//  Are You Open
//
//  Created by Yun Jang on 3/19/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//@property (strong, nonatomic) NSArray *placesArr;
@property (strong, nonatomic) NSString *searchTitle;
@property (strong, nonatomic) NSURL *urlData;

@end
