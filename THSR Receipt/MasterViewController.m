//
//  MasterViewController.m
//  THSR Receipt
//
//  Created by Yung-Luen Lan on 12/17/14.
//  Copyright (c) 2014 Solda. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TRQRScannerController.h"
#import "TRReceipt.h"
#import <NSCollectionAddition/NSCollectionAddition.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@interface MasterViewController ()
@property UIDocumentInteractionController *docController;
@property NSMutableArray *receipts;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    TRQRScannerController *scanner = [[TRQRScannerController alloc] init];
    scanner.delegate = self;
    [self.navigationController pushViewController: scanner animated: YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.receipts[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Scanner Delegate
- (void) codeUpdated: (NSSet *)codes
{
    self.receipts = [[[codes allObjects] map: ^(NSString *s) {
        return [TRReceipt receiptWithString: s];
    }] mutableCopy];
}

#pragma mark - Download

- (void) downloadReceipt: (TRReceipt *)receipt
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = receipt.urlForDownload;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent: [NSString stringWithFormat: @"%@%@.pdf", receipt.ticketNo, receipt.seatNo]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            receipt.downloadStatus = Failed;
        } else {
            receipt.localURL = filePath;
            receipt.downloadStatus = Downloaded;
            NSLog(@"File downloaded to: %@", filePath);
        }
        [self findNextReceiptToDownload];
    }];
    receipt.downloadStatus = Downloading;
    [downloadTask resume];
}

- (void) findNextReceiptToDownload
{
    if ([self.receipts forAll: ^(TRReceipt *r) { return (BOOL)(r.downloadStatus == Downloaded); }]) {
        // combine the pdf and mail
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *mergedURL = [documentsDirectoryURL URLByAppendingPathComponent: @"merged.pdf"];
        [[NSFileManager defaultManager] removeItemAtURL: mergedURL error: nil];
        
        
        CGRect mediaBox = CGRectMake(0, 0, 595, 842);
        CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef)mergedURL, &mediaBox, NULL);
        for (TRReceipt *r in self.receipts) {
            CGPDFContextBeginPage(context, NULL);
            
            CGPDFDocumentRef receiptPDF = CGPDFDocumentCreateWithURL((__bridge CFURLRef)r.localURL);
            CGPDFPageRef page = CGPDFDocumentGetPage(receiptPDF, 1); // hardcoded. only 1 page!
            
            CGContextDrawPDFPage(context, page);
            
            CGPDFDocumentRelease(receiptPDF);
            
            CGPDFContextEndPage(context);
        }
        CGPDFContextClose(context);
        
        // all pdf merged!
        MBProgressHUD *hud = [MBProgressHUD HUDForView: self.navigationController.view];
        [hud hide: YES];
        
        self.docController = [UIDocumentInteractionController interactionControllerWithURL: mergedURL];
        [self.docController presentOptionsMenuFromRect: CGRectZero inView: self.tableView animated: YES];
        
    } else {
        TRReceipt *next = [[self.receipts filter: ^(TRReceipt *r) {
            return (BOOL)(r.downloadStatus != Downloaded && r.downloadStatus != Downloading);
        }] head];
        [self downloadReceipt: next];
    }
}

- (IBAction) batch: (id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.navigationController.view animated: YES];
    hud.dimBackground = YES;
    [self findNextReceiptToDownload];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receipts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    TRReceipt *receipt = self.receipts[indexPath.row];
    cell.textLabel.text = receipt.ticketNo;
    cell.detailTextLabel.text = receipt.seatNo;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.receipts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
