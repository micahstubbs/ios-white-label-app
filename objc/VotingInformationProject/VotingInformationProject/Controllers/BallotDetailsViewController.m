//
//  BallotDetailsViewController.m
//  VotingInformationProject
//
//  Created by Andrew Fink on 3/13/14.
//

#import "BallotDetailsViewController.h"
#import "VIPEmptyTableViewDataSource.h"
#import "VIPTabBarController.h"
#import "ContactsSearchViewController.h"
#import "UIWebViewController.h"
#import "State+API.h"
#import "VIPColor.h"

#import "ContestUrlCell.h"

@interface BallotDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *electionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *electionDateLabel;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) VIPEmptyTableViewDataSource *emptyDataSource;
@end

@implementation BallotDetailsViewController

const NSUInteger VIP_TABLE_HEADER_HEIGHT = 32;
const NSUInteger VIP_DETAILS_TABLECELL_HEIGHT = 44;

- (NSMutableArray*)tableData
{
    if (!_tableData) {
        _tableData = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _tableData;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emptyDataSource = [[VIPEmptyTableViewDataSource alloc]
                            initWithEmptyMessage:NSLocalizedString(@"No Election Details Available",
                                                                   @"Text displayed by the table view if there are no election details to display")];

    self.screenName = @"Ballot Details Screen";
    self.electionNameLabel.textColor = [VIPColor primaryTextColor];
    self.electionDateLabel.textColor = [VIPColor secondaryTextColor];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    VIPTabBarController *vipTabBarController = (VIPTabBarController *)self.tabBarController;
    self.election = (Election*) vipTabBarController.currentElection;
    [self updateUI];
}

- (id<UITableViewDataSource>)configureDataSource
{
    return ([self.tableData[0] count] > 0) ? self : self.emptyDataSource;
}

- (void) updateUI
{
    if (!self.election) {
        return;
    }

    self.electionNameLabel.text = self.election.electionName;
    self.electionDateLabel.text = [self.election getDateString];

    [self.tableData removeAllObjects];
    NSArray *states = [self.election.states allObjects];
    //TODO: Allow for multiple state selection. In US the states set will only ever have 0-1 entries
    if ([states count] == 1) {
        State *state = (State*)states[0];
        NSMutableArray *eabProperties = [state.electionAdministrationBody getProperties];
        [self.tableData addObject:eabProperties];
        self.tableView.dataSource = [self configureDataSource];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSDictionary *property = (NSDictionary *)self.tableData[section][indexPath.item];
    // Check if we can make a url from the data property
    NSURL *dataUrl = nil;
    if ([property isKindOfClass:[NSDictionary class]]) {
        dataUrl = [NSURL URLWithString:property[@"data"]];
    }

    // If we have a url, make this cell segue to UIWebViewController
    if (dataUrl.scheme && [dataUrl.scheme length] > 0) {
        ContestUrlCell *cell = (ContestUrlCell*)[tableView dequeueReusableCellWithIdentifier:CONTEST_URL_CELLID
                                                                                forIndexPath:indexPath];
        [cell configure:property[@"title"] withUrl:property[@"data"]];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ElectionDetailsCell"
                                                                forIndexPath:indexPath];
        [self configureDetailsCell:cell withDictionary:property];
        return cell;
    }
}

- (void)configureDetailsCell:(UITableViewCell*)cell
                withDictionary:(NSDictionary*)property
{
    UIColor *primaryTextColor = [VIPColor primaryTextColor];
    cell.textLabel.text = property[@"title"];
    cell.textLabel.textColor = primaryTextColor;
    cell.detailTextLabel.text = property[@"data"];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.detailTextLabel.textColor = primaryTextColor;
    cell.userInteractionEnabled = NO;
}

#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *primaryTextColor = [VIPColor primaryTextColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, VIP_TABLE_HEADER_HEIGHT)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, VIP_TABLE_HEADER_HEIGHT)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = primaryTextColor;
    label.text = NSLocalizedString(@"Election Administration Body", nil);
    [view addSubview:label];
    [view setBackgroundColor:[VIPColor tableHeaderColor]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return VIP_TABLE_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self.tableData[0] count] > 0) ? VIP_DETAILS_TABLECELL_HEIGHT : VIP_EMPTY_TABLECELL_HEIGHT;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UIColor *textColor = [VIPColor primaryTextColor];
    view.backgroundColor = [VIPColor color:textColor withAlpha:0.5];
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BallotUrlCellSegue"]) {
        UIWebViewController *webView = (UIWebViewController*) segue.destinationViewController;
        ContestUrlCell *cell = (ContestUrlCell*)sender;
        webView.title = cell.textLabel.text;
        webView.url = cell.url;
    } else if ([segue.identifier isEqualToString:@"HomeSegue"]) {
        UINavigationController *navController = (UINavigationController*) segue.destinationViewController;
        ContactsSearchViewController *csvc = (ContactsSearchViewController*) navController.viewControllers[0];
        csvc.delegate = self;
    }
}

#pragma mark - ContactsSearchViewControllerDelegate
- (void)contactsSearchViewControllerDidClose:(ContactsSearchViewController *)controller
                               withElections:(NSArray *)elections
                             currentElection:(Election *)election
                                    andParty:(NSString *)party
{
    VIPTabBarController *vipTabBarController = (VIPTabBarController*)self.tabBarController;
    vipTabBarController.elections = elections;
    vipTabBarController.currentElection = election;
    vipTabBarController.currentParty = party;
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
