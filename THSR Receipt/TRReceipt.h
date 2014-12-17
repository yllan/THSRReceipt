//
//  TRReceipt.h
//  THSR Receipt
//
//  Created by Yung-Luen Lan on 12/17/14.
//  Copyright (c) 2014 Solda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NotYet,
    Downloading,
    Downloaded,
    Failed
} DownloadStatus;

@interface TRReceipt : NSObject
@property (nonatomic, strong) NSString *seatNo;
@property (nonatomic, strong) NSString *ticketNo;
@property (readonly) NSURL *urlForDownload;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic) DownloadStatus downloadStatus;

+ (TRReceipt *) receiptWithString: (NSString *)string;
@end
