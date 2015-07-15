//
//  NuevaCompraViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 27/08/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "NewShoppingViewController.h"
#import "MoreDataShoppingViewController.h"
#import "DatabaseHelper.h"
#import "QueComproUtils.h"
#import "Shopping+CRUD.h"
#import "Category+CRUD.h"
#import "Article+CRUD.h"
#import "Autocomplete.h"

#define SAVE_TITLE @"Guardar";
#define HIDE_TITLE @"Ocultar";
#define STATE_MORE_DATA @"STATE_MORE_DATA"
#define STATE_GEOLOCATION @"STATE_GEOLOCATION"
#define STATE_FAVOURITE @"STATE_FAVOURITE"


@interface NewShoppingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *article;
@property (weak, nonatomic) IBOutlet UITextField *category;
@property (weak, nonatomic) IBOutlet UITextField *cost;
@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UISwitch *geolocation;
@property (weak, nonatomic) IBOutlet UISwitch *moredata;
@property (weak, nonatomic) IBOutlet UISwitch *favourite;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveOrMoreData;

@property (strong, nonatomic) NSMutableDictionary *shoppingData;
@property (strong, nonatomic) Autocomplete  *categoryAutocomplete; //autocompletador para el campo category
@property (strong, nonatomic) Autocomplete  *articleAutocomplete;  //autocompletador para el campo article
@property (strong, nonatomic) CLLocationManager *locationManager;  //este objeto nos permite registrar la posicion del dispositivo
@property (strong, nonatomic) UIDatePicker *datePicker;            //para seleccionar fechas de una forma amigable :-)
@property (nonatomic) double latitude;                             //contendra la latitud de donde estamos
@property (nonatomic) double longitude;                            //contendra la longitud de donde estamos
@property (nonatomic) BOOL editDate;                               //sera YES si estamos editando la fecha
@property (strong, nonatomic) UIAlertView *alertData;              //con este alert mostramos los errores de validacion de campos
@end

@implementation NewShoppingViewController

@synthesize article = _article;
@synthesize category = _category;
@synthesize cost = _cost;
@synthesize date = _date;
@synthesize geolocation = _geolocation;
@synthesize moredata = _moredata;
@synthesize favourite = _favourite;
@synthesize saveOrMoreData = _saveOrMoreData;
@synthesize database = _database;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize datePicker = _datePicker;
@synthesize editDate = _editDate;
@synthesize shoppingData = _shoppingData;
@synthesize articleAutocomplete = _articleAutocomplete;
@synthesize categoryAutocomplete = _categoryAutocomplete;
@synthesize alertData = _alertData;
@synthesize shopping = _shopping;


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"NuevaCompraViewController cargado");
    //De entrada no estamos en edicion de la fecha
    self.editDate = NO;
    //recuperamos el estado de los tres switches de la ultima vez
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.moredata.on = [userDefault boolForKey:STATE_MORE_DATA];
    self.geolocation.on = [userDefault boolForKey:STATE_GEOLOCATION];
    self.favourite.on = [userDefault boolForKey:STATE_FAVOURITE];
    //si el boton de switch de geolocalizacion está en on, iniciamos el LocationManager
    if (self.geolocation.on){
        [self setUpGeoLocalization];
    }
    self.saveOrMoreData.title = SAVE_TITLE;
    
    //creamos el datePicker para seleccionar fecha y hora
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,50,200,200)];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker addTarget:self action:@selector(changeDate) forControlEvents:UIControlEventValueChanged];
    self.date.inputView = self.datePicker;
    
    //nos asignamos como delegados de los textfield para ocultar el teclado cuando presiona enter
    self.article.delegate = self;
    self.category.delegate = self;
    self.cost.delegate = self;
    //asignamos el teclado numérico para el importe
    self.cost.keyboardType = UIKeyboardTypeDecimalPad;
    //mapeamos la fecha y hora actuales
    [self changeDate];
    
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
    
    self.alertData = [[UIAlertView alloc] initWithTitle:@"Validación de datos"
                                                    message:@"La compra, la categoria, el importe y la fecha son obligatorios"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
}

//Inicializa el LocationManager para registrar la localización del móvil
-(void)setUpGeoLocalization
{
    if (!self.locationManager){
        NSLog(@"Inicializando la geo localizacion");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        NSLog(@"LocationManager setup");
    }
    [self.locationManager startUpdatingLocation];
    NSLog(@"LocationManager ON");
}

//Cuando el usuario accione el switch GeoLocation se dispara este evento
- (IBAction)changeGeolocation:(UISwitch *)sender
{
    NSLog(@"Press geolocalizacion");
    if (sender.on){
        [self setUpGeoLocalization];
    }else{
        [self.locationManager stopUpdatingLocation];
        NSLog(@"LocationManager OFF");
    }
}

//Cuando el usuario accione el switch MoreData se dispara este evento
- (IBAction)changeMoreData:(UISwitch *)sender
{
    NSLog(@"Press more data");
}

//Al entrar en el campo fecha
- (IBAction)startEditDate:(UITextField *)sender
{
    NSLog(@"Start editing");
    self.editDate = YES;
    self.saveOrMoreData.title = HIDE_TITLE;
    self.datePicker.hidden = NO;
}

//cuando se vaya a mostrar la vista rellenamos el formulario con los datos que tengamos en shopping
-(void)viewWillAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
    NSLog(@"LocationManager ON");
    self.article.text = self.shopping.article.name;
    self.category.text = self.shopping.article.category.name;
    self.cost.text = [QueComproUtils stringValue:self.shopping.cost withDecimals:2];
    if (self.shopping)
        self.favourite.on = NO;
}

#pragma mark UITextFieldDelegate methods
//cuando el usuario teclea en los campos de categoria y articulo se activa este metodo
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.category){
        //buscamos en la BBDD las categorias que contengan lo escrito por el usuario en el campo de texto
        NSArray *items = [Category getCategoriesContaining:substring inManagedObjectContext:self.database.managedObjectContext];
        if ([items count] > 0){
            [self.categoryAutocomplete setListItems:items];
            [self.categoryAutocomplete reloadData];
            self.categoryAutocomplete.hidden = NO;
        }else{
            self.categoryAutocomplete.hidden = YES;
        }
    }else if (textField == self.article){
        //buscamos en la BBDD los articulos que contengan lo escrito por el usuario en el campo de texto
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
    [self.cost resignFirstResponder];    
    return YES;
}

//Cuando el usuario cambie la fecha del DatePicker se activa este método
-(void)changeDate
{
    [self.date setText:[QueComproUtils getStringDate:self.datePicker.date ]];
}

//Cuando el autocomplete seleccione el item del listado invocará a este metodo para mostrarlo
-(void)setText:(NSString *)text toTextField:(UITextField *)textField fromTable:(UITableView *)tableView
{
    textField.text = text;
    tableView.hidden = YES;
}

//Se invocará cada vez que el dispositivo registre una localización
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    self.latitude = newLocation.coordinate.latitude;
    self.longitude = newLocation.coordinate.longitude;
}

//comprueba si se ha rellenado el campo article, category, import y la fecha y el importe son correctos. De lo contrario muestra un alert
-(BOOL)checkData
{
    BOOL correcto = YES;
    //campos obligatorios
    if (!self.article.text || [self.article.text isEqualToString:@""] ||
        !self.category.text || [self.category.text isEqualToString:@""] ||
        !self.cost.text || [self.cost.text isEqualToString:@""] ||
        !self.date.text || [self.date.text isEqualToString:@""]){
        [self.alertData setMessage:@"La compra, la categoria, el importe y la fecha son obligatorios."];
        [self.alertData show];
        correcto = NO;
    }else{
        //validacion de fecha
        NSDate *date = [QueComproUtils getDate:self.date.text];
        if (!date){
            correcto = NO;
            [self.alertData setMessage:@"La fecha no es correcta."];
            [self.alertData show];
        }else{
            //validacion del importe
            NSNumber *number = [QueComproUtils numberValue:self.cost.text];
            if (!number){
                correcto = NO;
                [self.alertData setMessage:@"El importe no es correcto."];
                [self.alertData show];
            }
        }
    }
    return correcto;
}

//Controla cuando el usuario pulsa el boton del UINavigation. Puede ser para guardar la compra o para ocultar el datepicker
- (IBAction)saveShopping:(UIBarButtonItem *)sender
{
    NSLog(@"saveShopping pressed");
    if (self.editDate){
        self.editDate = NO;
        self.datePicker.hidden = YES;
        self.saveOrMoreData.title = SAVE_TITLE;
        NSLog(@"DatePicker cerrado");
    }else{
        if ([self checkData]){
            //1. recoger datos de controles y montar diccionario
            self.shoppingData = [[NSMutableDictionary alloc] initWithCapacity:12];
            [self.shoppingData setValue:self.article.text forKey:SHOPPING_ARTICLE_NAME];
            [self.shoppingData setValue:self.category.text forKey:SHOPPING_CATEGORY_NAME];
            [self.shoppingData setValue:self.cost.text forKey:SHOPPING_COST];
            [self.shoppingData setValue:self.datePicker.date forKey:SHOPPING_DATE];
            [self.shoppingData setValue:[NSNumber numberWithBool:self.favourite.on] forKey:SHOPPING_FAVOURITE];
            if (self.geolocation.on){
                [self.shoppingData setValue:[NSNumber numberWithDouble:self.latitude] forKey:SHOPPING_LATITUDE];
                [self.shoppingData setValue:[NSNumber numberWithDouble:self.longitude] forKey:SHOPPING_LONGITUDE];
            }
            [self.shoppingData setValue:[NSNumber numberWithBool:NO] forKey:SHOPPING_PHOTO];
            [self.shoppingData setValue:[NSNumber numberWithBool:NO] forKey:SHOPPING_TICKET];
            //save to database
            NSLog(@"Ready to save shopping");
            [self.database.managedObjectContext performBlock:^{
                Shopping *shopping = [Shopping createShopping:[self.shoppingData copy] inManagedObjectContext:self.database.managedObjectContext];
                [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
                    NSLog(@"Shopping saved with id:%@",shopping.unique);
                    [self.shoppingData setValue:shopping.unique forKey:SHOPPING_UNIQUE];
                    if (self.moredata.on){
                        //2. si esta on mas datos entonces el segue es hacia MoraData y se le pasa el diccionario
                        [self performSegueWithIdentifier:@"More data" sender:self];
                    }else{
                        //3. si esta off se inserta en base de datos y el segue es haciea QueCompro
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue to MoreDataShopping");
    [segue.destinationViewController setDatabase:self.database];
    [segue.destinationViewController setShoppingData:self.shoppingData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithBool:self.moredata.on] forKey:STATE_MORE_DATA];
    [userDefault setObject:[NSNumber numberWithBool:self.geolocation.on] forKey:STATE_GEOLOCATION];
    [userDefault setObject:[NSNumber numberWithBool:self.favourite.on] forKey:STATE_FAVOURITE];
    NSLog(@"LocationManager OFF");
}

- (void)viewDidUnload
{
    [self setArticle:nil];
    [self setCategory:nil];
    [self setCost:nil];
    [self setDate:nil];
    [self setGeolocation:nil];
    [self setMoredata:nil];
    [self setFavourite:nil];
    [self setSaveOrMoreData:nil];
    [self setArticleAutocomplete:nil];
    [self setCategoryAutocomplete:nil];
    [self setDatePicker:nil];
    [self setShoppingData:nil];
    [self setAlertData:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
