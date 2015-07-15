//
//  SearchStatsCategoryViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "SearchStatsCategoryViewController.h"
#import "StatsCategoryViewController.h"
#import "Shopping+CRUD.h"
#import "Article+CRUD.h"
#import "Category+CRUD.h"
#import "QueComproUtils.h"
#import "StatsData.h"

#define SEARCH_TITLE @"Ver"
#define HIDE_TITLE @"Ocultar"

@interface SearchStatsCategoryViewController ()
@property (weak, nonatomic) IBOutlet UITextField *dateFrom;
@property (weak, nonatomic) IBOutlet UITextField *dateUntil;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewStat;   

@property (strong, nonatomic) UIDatePicker *dateFromPicker;       //picker para seleccionar la fecha de inicio
@property (strong, nonatomic) UIDatePicker *dateUntilPicker;      //picker para seleccionar la fecha de fin
@property (strong, nonatomic) NSMutableDictionary *dictSearch;    //Diccionario que contiene la fecha de inicio y fin esocgida por el usuario.
@property (strong, nonatomic) StatsData *statsData;               //objeto estadístico que enviaremos a la grafica
@property (nonatomic) BOOL editDate;
@end

@implementation SearchStatsCategoryViewController
@synthesize database = _database;
@synthesize dateFrom = _dateFrom;
@synthesize dateUntil = _dateUntil;
@synthesize viewStat = _viewStat;
@synthesize dateFromPicker = _dateFromPicker;
@synthesize dateUntilPicker = _dateUntilPicker;
@synthesize dictSearch = _dictSearch;
@synthesize editDate = _editDate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.editDate = NO;
    self.viewStat.title = SEARCH_TITLE;
    self.dictSearch = [[NSMutableDictionary alloc] initWithCapacity:2];
    self.dateFromPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,50,200,200)];
    self.dateFromPicker.datePickerMode = UIDatePickerModeDate;
    [self.dateFromPicker addTarget:self action:@selector(changeDateFrom) forControlEvents:UIControlEventValueChanged];
    self.dateFrom.inputView = self.dateFromPicker;
    
    self.dateUntilPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,50,200,200)];
    self.dateUntilPicker.datePickerMode = UIDatePickerModeDate;
    [self.dateUntilPicker addTarget:self action:@selector(changeDateUntil) forControlEvents:UIControlEventValueChanged];
    self.dateUntil.inputView = self.dateUntilPicker;
    
    self.statsData = [[StatsData alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.editDate = NO;
    self.dateFromPicker.hidden = YES;
    self.dateUntilPicker.hidden = YES;
    self.viewStat.title = SEARCH_TITLE;
}

//Cuando el usuario cambie la fecha del DatePicker se activa este método
-(void)changeDateFrom
{
    [self.dateFrom setText:[QueComproUtils getStringShortDate:self.dateFromPicker.date ]];
}

//Cuando el usuario cambie la fecha del DatePicker se activa este método
-(void)changeDateUntil
{
    [self.dateUntil setText:[QueComproUtils getStringShortDate:self.dateUntilPicker.date ]];
}

//Cuando el usuario pulse el campo de texto de la fecha de inicio
- (IBAction)startDateFrom:(id)sender {
    NSLog(@"Start editing date from");
    [self changeDateFrom];
    self.editDate = YES;
    self.viewStat.title = HIDE_TITLE;
    self.dateFromPicker.hidden = NO;
}

//Cuando el usuario pulse el campo de texto de la fecha de fin
- (IBAction)startDateUntil:(id)sender {
    NSLog(@"Start editing date until");
    [self changeDateUntil];
    self.editDate = YES;
    self.viewStat.title = HIDE_TITLE;
    self.dateUntilPicker.hidden = NO;
}

//Controla cuando el usuario pulsa el boton del UINavigation. Puede ser para ver la estadística o para ocultar el datepicker
- (IBAction)viewStat:(UIBarButtonItem *)sender {
    if (self.editDate){
        self.editDate = NO;
        self.dateFromPicker.hidden = YES;
        self.dateUntilPicker.hidden = YES;
        self.viewStat.title = SEARCH_TITLE;
        NSLog(@"DatePickers cerrados");
    }else{
        [self.dictSearch removeAllObjects];
        if (![self.dateFrom.text isEqualToString:@""]){
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.dateFromPicker.date];
            [components setHour:0];
            [components setMinute:0];
            [self.dictSearch setObject:[calendar dateFromComponents:components] forKey:SHOPPING_DATE_FROM];
        }
        if (![self.dateUntil.text isEqualToString:@""]){
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.dateUntilPicker.date];
            [components setHour:0];
            [components setMinute:0];
            [self.dictSearch setObject:[calendar dateFromComponents:components] forKey:SHOPPING_DATE_UNTIL];
        }
        //Recuperamos las compras que corresponden desde la fecha de inicio y fin seleccionadas.
        NSArray *listShopping = [Shopping getShoppingListWithFilter:self.dictSearch InManagedObjectContext:self.database.managedObjectContext orderByDate:NO];
        //Guardamos la información estadística asociada a las compras
        [self.statsData makeCategoryStatsData:listShopping];
        [self performSegueWithIdentifier:@"View stat category" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setStatsData:self.statsData];
    NSLog(@"segue to StatsCategoryViewController");
}

- (void)viewDidUnload
{
    [self setDateFrom:nil];
    [self setDateUntil:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end
