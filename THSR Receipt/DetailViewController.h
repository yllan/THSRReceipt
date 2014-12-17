//
//  DetailViewController.h
//  THSR Receipt
//
//  Created by Yung-Luen Lan on 12/17/14.
//  Copyright (c) 2014 Solda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

