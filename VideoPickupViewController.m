//
//  VideoPickupViewController.m
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "VideoPickupViewController.h"

@implementation VideoPickupViewController
@synthesize tableView, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Choose a Method";
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cut video_banner.png"]];
    CGRect fr = self.navigationController.navigationBar.frame;
    fr.size.width += 2;
    fr.origin.x -= 1;
    imageView.frame = fr;
    [[self.navigationController.navigationBar.subviews objectAtIndex:0] addSubview:imageView];
    [imageView release];
    self.tableView.backgroundView = nil;
    docVideoBrowserViewController *browser = [[docVideoBrowserViewController alloc] init];
    browser.delegate = self;
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"typeCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"typeCell"] autorelease];
    }
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Select video from local document";
			break;
		case 1:
			cell.textLabel.text = @"Select video from iTunes";
			break;
		default:
			break;
	}
	cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        docVideoBrowserViewController *browser = [[docVideoBrowserViewController alloc] init];
        browser.delegate = self;
        [self.navigationController pushViewController:browser animated:YES];
        [browser release];
    }
}

#pragma mark - Custom Function
- (void)dismiss:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)next:(id)sender{
    VideoCutViewController *tmp = [[VideoCutViewController alloc] initWithNibName:@"VideoCutViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:tmp animated:YES];
    NSLog(@"next");
    [tmp release];
}


#pragma mark - docVideoBrowserViewController Delegate
- (void)assetBrowser:(docVideoBrowserViewController *)assetBrowser didChooseAsset:(AVAsset *)asset{
    [self.delegate videoPicker:self didChooseAsset:asset];
}

@end

