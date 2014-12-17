//
//  TRQRScannerController.h
//  THSR Receipt
//
//  Created by Yung-Luen Lan on 12/17/14.
//  Copyright (c) 2014 Solda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TRQRScannerControllerDelegate <NSObject>
- (void) codeUpdated: (NSSet *)codes;
@end

@interface TRQRScannerController : UIViewController

@property (nonatomic, weak) id<TRQRScannerControllerDelegate> delegate;
@end
