//
//  AccordionTableViewController.m
//  
//
//  Created by Kim on 09/06/14.
//
//

#import "AccordionTableViewController.h"

@interface AccordionTableViewController () <KMAccordionTableViewControllerDataSource>

@end

@implementation AccordionTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.sections = [self getSectionArray];

    [self setupAppearence];
}

- (void)setupAppearence {
    [self setHeaderHeight:38];
    [self setHeaderArrowImageClosed:[UIImage imageNamed:@"carat-open"]];
    [self setHeaderArrowImageOpened:[UIImage imageNamed:@"carat"]];
    [self setHeaderFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self setHeaderTitleColor:[UIColor whiteColor]];
    [self setHeaderSeparatorColor:[UIColor colorWithRed:0.157 green:0.157 blue:0.157 alpha:1]];
    [self setHeaderColor:[UIColor colorWithRed:0.114 green:0.114 blue:0.114 alpha:1]];
}

- (NSArray *)getSectionArray {
    //view for the macro accordion section
    UIView *viewOfSectionDiet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
    
    //add the diet subview to the section view.
    NSArray *subviewArrayDiet = [[NSBundle mainBundle] loadNibNamed:@"BSAccordionDietDetailsView" owner:self options:nil];
    [viewOfSectionDiet addSubview:[subviewArrayDiet objectAtIndex:0]];
    
    viewOfSectionDiet.backgroundColor = [UIColor lightGrayColor];
    KMSection *section1 = [[KMSection alloc] init];
    section1.view = viewOfSectionDiet;
    section1.title = @"Diet Macros";
    
    //view for the measurement accordion section
    UIView *viewOfSectionMeasurement = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    
    //add the diet subview to the section view.
    NSArray *subviewArrayMeasurement = [[NSBundle mainBundle] loadNibNamed:@"BSAccordionBodyMeasurementsView" owner:self options:nil];
    [viewOfSectionMeasurement addSubview:[subviewArrayMeasurement objectAtIndex:0]];
    
    
    viewOfSectionMeasurement.backgroundColor = [UIColor lightGrayColor];
    KMSection *section2 = [[KMSection alloc] init];
    section2.view = viewOfSectionMeasurement;
    section2.title = @"Body Measurements";
    
    return @[section1, section2];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInAccordionTableViewController:(KMAccordionTableViewController *)accordionTableView {
    return [self.sections count];
}

- (KMSection *)accordionTableView:(KMAccordionTableViewController *)accordionTableView sectionForRowAtIndex:(NSInteger)index {
    
    return self.sections[index];
}

- (CGFloat)accordionTableView:(KMAccordionTableViewController *)accordionTableView heightForSectionAtIndex:(NSInteger)index {
    
    KMSection *section = self.sections[index];
    return section.view.frame.size.height;
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
