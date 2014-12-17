//
//  MasterViewController.h
//  THSR Receipt
//
//  Created by Yung-Luen Lan on 12/17/14.
//  Copyright (c) 2014 Solda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRQRScannerController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <TRQRScannerControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

- (IBAction)batch:(id)sender;

@end

