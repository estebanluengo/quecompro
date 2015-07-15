//
//  SearchShoppingViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 07/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "SearchShoppingViewController.h"
#import "ListShoppingViewController.h"
#import "Shopping+CRUD.h"
#import "Article+CRUD.h"
#import "Category+CRUD.h"
#import "QueComproUtils.h"

#define SEARCH_TITLE @"Ver"
#define HIDE_TITLE @"Ocultar"

@interface SearchShoppingViewController () 
@property (weak, nonatomic) IBOutlet UITextField *dateFrom;
@property (weak, nonatomic) IBOutlet UITextField *dateUntil;
@property (weak, nonatomic) IBOutlet UITextField *article;
@property (weak, nonatomic) IBOutlet UITextField *category;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (strong, nonatomic) NSMutableDictionary *dictSearch;        //contiene los valores que el usuario ha introducido en el buscador
@property (strong, nonatomic) Autocomplete  *categoryAutocomplete;    //autocompletador para el campo categoria
@property (strong, nonatomic) Autocomplete  *articleAutocomplete;     //autocompletador para el campo articulo
@property (strong, nonatomic) UIDatePicker *dateFromPicker;           //picker para el campo fecha desde
@property (strong, nonatomic) UIDatePicker *dateUntilPicker;          //picker para el campo fecha hasta
@property (nonatomic) BOOL editDate;                                  //sera true si estamos seleccionando una fecha
@end

@implementation SearchShoppingViewController
@synthesize dateFrom = _dateFrom;
@synthesize dateUntil = _dateUntil;
@synthesize article = _article;
@synthesize category = _category;
@synthesize searchButton = _searchButton;
@synthesize dictSearch = _dictSearch;
@synthesize articleAutocomplete = _articleAutocomplete;
@synthesize categoryAutocomplete = _categoryAutocomplete;
@synthesize dateFromPicker = _dateFromPicker;
@synthesize dateUntilPicker = _dateUntilPicker;
@synthesize editDate = _editDate;
@synthesize database = _database;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.editDate = NO;
    self.searchButton.title = SEARCH_TITLE;
    self.dictSearch = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    self.dateFromPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,50,200,200)];
    self.dateFromPicker.datePickerMode = UIDatePickerModeDate;
    [self.dateFromPicker addTarget:self action:@selector(changeDateFrom) forControlEvents:UIControlEventValueChanged];
    self.dateFrom.inputView = self.dateFromPicker;

    self.dateUntilPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,50,200,200)];
    self.dateUntilPicker.datePickerMode = UIDatePickerModeDate;
    [self.dateUntilPicker addTarget:self action:@selector(changeDateUntil) forControlEvents:UIControlEventValueChanged];
    self.dateUntil.inputView = self.dateUntilPicker;
    
    //nos asignamos como delegados de los textfield para ocultar el teclado cuando presiona enter
    self.article.delegate = self;
    self.category.delegate = self;
    
    //creamos la tabla para autocompletar en articulos
    self.articleAutocomplete = [[Autocomplete alloc] initWithFrame:CGRectMake(0, 80, 320, 120) style:UITableViewStylePlain];
    self.articleAutocomplete.delegate = self.articleAutocomplete;
    self.articleAutocomplete.dataSource = self.articleAutocomplete;
    self.articleAutocomplete.scrollEnabled = YES;
    self.articleAutocomplete.hidden = YES;
    self.articleAutocomplete.delegateTextField = self;
    self.articleAutocomplete.textField = self.article;
    [self.view addSubview:self.articleAutocomplete];
    
    //creamos la tabla para autocompletar en categorias
    self.categoryAutocomplete = [[Autocomplete alloc] initWithFrame:CGRectMake(0, 145, 320, 120) style:UITableViewStylePlain];
    self.categoryAutocomplete.delegate = self.categoryAutocomplete;
    self.categoryAutocomplete.dataSource = self.categoryAutocomplete;
    self.categoryAutocomplete.scrollEnabled = YES;
    self.categoryAutocomplete.hidden = YES;
    self.categoryAutocomplete.delegateTextField = self;
    self.categoryAutocomplete.textField = self.category;
    [self.view addSubview:self.categoryAutocomplete];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.editDate = NO;
    self.dateFromPicker.hidden = YES;
    self.dateUntilPicker.hidden = YES;
    self.searchButton.title = SEARCH_TITLE;
    [self.article resignFirstResponder];
    [self.category resignFirstResponder];
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

//Se activa este método cuando se pulsa el campo de fecha desde
- (IBAction)startEditDateFrom:(UITextField *)sender {
    NSLog(@"Start editing date from");
    [self changeDateFrom];
    self.editDate = YES;
    self.searchButton.title = HIDE_TITLE;
    self.dateFromPicker.hidden = NO;
}

//se activa el método cuando se pulsa el campo de fecha hasta
- (IBAction)startEditDateUntil:(UITextField *)sender {
    NSLog(@"Start editing date until");
    [self changeDateUntil];
    self.editDate = YES;
    self.searchButton.title = HIDE_TITLE;
    self.dateUntilPicker.hidden = NO;
}

#pragma mark UITextFieldDelegate methods
//cuando el usuario teclea en los campos de categoria y articulo se activa este metodo
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.category){
        NSArray *items = [Category getCategoriesContaining:substring inManagedObjectContext:self.database.managedObjectContext];
        if ([items count] > 0){
            [self.categoryAutocomplete setListItems:items];
            [self.categoryAutocomplete reloadData];
            self.categoryAutocomplete.hidden = NO;
        }else{
            self.categoryAutocomplete.hidden = YES;
        }
    }else if (textField == self.article){
        NSArray *items = [Article getArticlesContaining:substring inManagedObjectContext:self.database.managedObjectContext];
        if ([items count] > 0){
            [self.articleAutocomplete setListItems:items];
            [self.articleAutocomplete reloadData];
            self.articleAutocomplete.hidden = NO;
        }else{
            self.articleAutocomplete.hidden = YES;
        }
    }
    return YES;
}

//Este metodo es llamado cuando se pulsa enter para esconder el teclado virtual
- (BOOL) textFieldShouldReturn:(UITextField *)theTextField
{
    NSLog(@"Ocultamos teclado");
    [self.article resignFirstResponder];
    [self.category resignFirstResponder];
    return YES;
}

//Cuando el autocomplete seleccione el item del listado invocará a este metodo para mostrarlo
-(void)setText:(NSString *)text toTextField:(UITextField *)textField fromTable:(UITableView *)tableView
{
    textField.text = text;
    tableView.hidden = YES;
}

//Se activa este método cuando el usuario pulsa sobre el botón del UINavigation. Puede ser para buscar o para ocultar el datepicker
- (IBAction)searchShopping:(UIBarButtonItem *)sender {
    if (self.editDate){
        self.editDate = NO;
        self.dateFromPicker.hidden = YES;
        self.dateUntilPicker.hidden = YES;
        self.searchButton.title = SEARCH_TITLE;
        NSLog(@"DatePickers cerrados");
    }else{
        [self.dictSearch removeAllObjects];
        //se construye el diccionario con los valores para realizar la búsqueda
        if (![self.article.text isEqualToString:@""])
            [self.dictSearch setObject:self.article.text forKey:SHOPPING_ARTICLE_NAME];
        if (![self.category.text isEqualToString:@""])
            [self.dictSearch setObject:self.category.text forKey:SHOPPING_CATEGORY_NAME];
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
        [self performSegueWithIdentifier:@"Shopping list" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue to MoreDataShopping");
    [segue.destinationViewController setSearchShopping:self.dictSearch];//Enviamos el diccionario con el filtro de búsqueda al controlador que muesta la lista de compras
    [segue.destinationViewController setDatabase:self.database];
}

- (void)viewDidUnload
{
    [self setDateFrom:nil];
    [self setDateUntil:nil];
    [self setArticle:nil];
    [self setCategory:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
