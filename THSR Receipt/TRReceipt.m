//
//  TRReceipt.m
//  THSR Receipt
//
//  Created by Yung-Luen Lan on 12/17/14.
//  Copyright (c) 2014 Solda. All rights reserved.
//

#import "TRReceipt.h"

@implementation TRReceipt

+ (TRReceipt *) receiptWithString: (NSString *)string
{
    TRReceipt *r = [[TRReceipt alloc] init];
    NSAssert(string.length == 21, @"str.length == 21");
    r.seatNo = [string substringFromIndex: 13];
    r.ticketNo = [string substringToIndex: 13];
    return r;
}

@end
