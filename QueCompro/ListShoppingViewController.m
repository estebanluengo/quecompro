//
//  ListShoppingViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 05/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "ListShoppingViewController.h"
#import "QueComproUtils.h"
#import "ShoppingCell.h"
#import "Shopping+CRUD.h"
#import "Article.h"
#import "Category.h"
#import "ShoppingAnnotation.h"
#import "MapViewShoppingViewController.h"

#define SHOW_CATEGORIES @"Ver por categorías"
#define SHOW_SIMPLE @"Ver listado"
#define SORT_ALPHABETIC @"Orden alfabético"
#define SORT_DATE @"Orden por fecha"

@interface ListShoppingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *shopppingTable;
@property (weak, nonatomic) IBOutlet UIButton *buttonSortShopping;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowCategories;
@property (weak, nonatomic) IBOutlet UILabel *gastoTotal;

@property (nonatomic, strong) NSDictionary *shoppingByCategory;     //contiene las compras agrupadas por categorias
@property (nonatomic, strong) NSArray *shoppingList;                //contiene las compras en modo listado sin agrupamientos
@property (nonatomic) BOOL showCategories;                          //indica cuando se deben mostrar las compras por categorias o en modo listado
@property (nonatomic) BOOL orderByDate;                             //indica cuando se deben ordenar las compras por fechas o por orden alfabetico. Si es por fecha el orden es decreciente si es por orden alfabético el oden es ascendente

@end

@implementation ListShoppingViewController

@synthesize database = _database;
@synthesize searchShopping = _searchShopping;
@synthesize shopppingTable = _shopppingTable;
@synthesize buttonSortShopping = _buttonSortShopping;
@synthesize buttonShowCategories = _buttonShowCategories;
@synthesize gastoTotal = _gastoTotal;
@synthesize shoppingList = _shoppingList;
@synthesize shoppingByCategory = _shoppingByCategory;
@synthesize showCategories = _showCategories;
@synthesize orderByDate = _orderByDate;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//Carga las compras de la base de datos y recarga el tableView 
-(void)loadShopping
{
    //Si hemos venido desde la pantalla principal es porqu quiere ver las compras del mes
    if (!self.searchShopping){
        self.shoppingList = [Shopping getShoppingListInManagedObjectContext:self.database.managedObjectContext orderByDate:(BOOL)self.orderByDate];
    }else{ //sino hemos venido desde el controlador SearchShopping
        self.shoppingList = [Shopping getShoppingListWithFilter:self.searchShopping
                                         InManagedObjectContext:self.database.managedObjectContext
                                                    orderByDate:(BOOL)self.orderByDate];
    }
    
    //mostraremos categorías?
    if (self.showCategories){
        NSMutableDictionary *categories = [NSMutableDictionary dictionary];
        for (Shopping *s in self.shoppingList){
            NSMutableArray *shoppingList = [categories objectForKey:s.article.category.name];
            if (!shoppingList){
                shoppingList = [NSMutableArray array];
                [categories setObject:shoppingList forKey:s.article.category.name];
            }
            [shoppingList addObject:s];
        }
        self.shoppingByCategory = categories;
    }
    [self.shopppingTable reloadData];
}

//cuando nos especifiquen la base de datos cargamos las compras siempre por defecto sin agrupar por categorias y ordenado por fecha
-(void)setDatabase:(UIManagedDocument *)database
{
    self.showCategories = NO;
    self.orderByDate = YES;
    if (_database != database){
        _database = database;
    }
    [self loadShopping];
}

//después de mostrar la vista recalculamos el coste total de todas las compras que hay en pantalla y lo mostramos en la parte superior de la pantalla
-(void)viewDidAppear:(BOOL)animated
{
    float gasto = [self calculateTotalCost:self.shoppingList];
    self.gastoTotal.text = [NSString stringWithFormat:@"%.2f", gasto];
    [self setTitleButtonCategories];
    [self setTitleButtonDate];
}

//Esta función calcula el coste total de la lista de compras especificada por parametro
-(float)calculateTotalCost:(NSArray *)shoppingList
{
    float gasto = 0.0f;
    for (Shopping *s in shoppingList){
        if (s.cost && ![s.cost isEqualToNumber:[NSDecimalNumber notANumber]])
            gasto = gasto + [s.cost floatValue];
    }
    return gasto;
}

//permite cambiar el titulo al boton de mostrar categorias o mostrar listado
-(void)setTitleButtonCategories
{
    if (self.showCategories){
        [self.buttonShowCategories setTitle:SHOW_SIMPLE forState:UIControlStateNormal];
    }else{
        [self.buttonShowCategories setTitle:SHOW_CATEGORIES forState:UIControlStateNormal];
    }
}

//permite cambiar el titulo al boton de odenar por fecha o por orden alfabetico
-(void)setTitleButtonDate
{
    if (self.orderByDate){
        [self.buttonSortShopping setTitle:SORT_ALPHABETIC forState:UIControlStateNormal];
    }else{
        [self.buttonSortShopping setTitle:SORT_DATE forState:UIControlStateNormal];
    }
}

//cuando se pulse el boton de mostrar categorias
- (IBAction)showCategories:(UIButton *)sender {
    self.showCategories = !self.showCategories;
    [self setTitleButtonCategories];
    [self loadShopping];
}

//cuando se pulse el boton de ordenar por fecha
- (IBAction)sortShoppingList:(UIButton *)sender {
    self.orderByDate = !self.orderByDate;
    [self setTitleButtonDate];
    [self loadShopping];
}

#pragma mark - ShoppingDeleteDelegate
//Este metodo se invoca cuando desde la ficha de una compra pulsen el boton de eliminarla
-(void)deleteShopping:(NSNumber *)idShopping fromSender:(ViewShoppingViewController *)sender
{
    [self.database.managedObjectContext performBlock:^{
        [Shopping deleteShopping:idShopping inManagedObjectContext:self.database.managedObjectContext];
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            [self loadShopping];
        }];
    }];
}

//retorna un array de objetos ShoppingAnnotation para mostrarlos en un mapa.
- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.shoppingList count]];
    for (Shopping *shopping in self.shoppingList) {
        [annotations addObject:[ShoppingAnnotation annotationForShopping:shopping]];
    }
    return annotations;
}

#pragma mark - MapViewControllerDelegate
//Este metodo implementa el protocolo definido en MapViewController para poder descargar la miniatura de la foto
- (UIImage *)mapViewController:(MapViewShoppingViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    ShoppingAnnotation *sa = (ShoppingAnnotation *)annotation;
    NSString *photoName = [TYPE_PHOTO stringByAppendingString:[sa.shopping.unique stringValue]];
    return [QueComproUtils loadPhoto:photoName];
}

//retorna el objeto Shopping que esté en la posición indexPath. Puede ser que se recupere de la lista de compras agrupadas por categorías o desde la lista de compras sin agrupaciones
-(Shopping *)getShopping:(NSIndexPath *)indexPath
{
    Shopping *shopping;
    if (self.showCategories){
        NSString *category = [self categoryForSection:indexPath.section];
        NSArray *shoppingList = [self.shoppingByCategory objectForKey:category];
        shopping = [shoppingList objectAtIndex:indexPath.row];
    }else{
        shopping = [self.shoppingList objectAtIndex:indexPath.row];
    }
    return shopping;
}

//retorna el nombre de la categoría de la seccion determinada
- (NSString *)categoryForSection:(NSInteger)section
{
    return [[self.shoppingByCategory allKeys] objectAtIndex:section];
}

//número de secciones en la tabla sera 0 si estamos en el modo ver listado simple.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showCategories){
        return [self.shoppingByCategory count];
    }
    return 1;
}

//Da valor al título de la seccion que será el título de la categoría
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.showCategories){
        NSString *sectionName = [self categoryForSection:section];
        float gasto = [self calculateTotalCost:[self.shoppingByCategory objectForKey:sectionName]];
        sectionName = [[sectionName stringByAppendingString:@": "] stringByAppendingString:[NSString stringWithFormat:@"%.2f", gasto]];
        return sectionName;
        //return [self categoryForSection:section];
    }else{
        return nil;
    }
}

//número de compras por sección
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showCategories){
        NSString *category = [self categoryForSection:section];
        NSArray *shoppingList = [self.shoppingByCategory objectForKey:category];
        return [shoppingList count];
    }
    return [self.shoppingList count];
}

//Da valor a las celdas de la tabla
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Shopping ID";
    ShoppingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Shopping *shopping = [self getShopping:indexPath];
    cell.articleName.text = shopping.article.name;
    cell.costShopping.text = [QueComproUtils stringValue:shopping.cost withDecimals:2];
    cell.dateShopping.text = [QueComproUtils getStringDate:shopping.date];
    return cell;
}

//Tenemos dos posibles segues. Si selecciona un lugar del table o si pulsa el botón de Map para ver los lugares en el mapa
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"View shopping"]){
        //enviamos al siguiente controller el objeto place seleccionado
        NSIndexPath *indexPath = [self.shopppingTable indexPathForCell:sender];
        Shopping *shopping = [self getShopping:indexPath];
        NSLog(@"nos vamos a ver la compra de %@",shopping.article.name);
        //indicamos que nosotros somos delegados de setShopping para que cuando el usuario pulse eliminar se nos invoque a nosotros
        [segue.destinationViewController setShoppingDelegate:self];
        [segue.destinationViewController setShopping:shopping];
    }else if ([segue.identifier isEqualToString:@"View map"]){
        //vamos a ver el mapa con los lugares de esta lista
        NSLog(@"nos vamos a ver en el mapa todas las compras");
        //Somos el delegado del mapa
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}

- (void)viewDidUnload
{
    [self setShopppingTable:nil];
    [self setButtonSortShopping:nil];
    [self setButtonShowCategories:nil];
    [self setGastoTotal:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
