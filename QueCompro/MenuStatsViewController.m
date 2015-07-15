//
//  MenuStatsViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "MenuStatsViewController.h"
#import "SearchStatsCategoryViewController.h"
#import "StatsTimeViewController.h"
#import "StatsData.h"
#import "Shopping+CRUD.h"
#import "QueComproUtils.h"

@interface MenuStatsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) StatsData *statsData;                //contiene toda la informacion estadística ya mapeada desde la base de datos
@property (strong, nonatomic) NSMutableDictionary *dictSearch;     //Diccionario para realizar búsquedas de compras
@property (strong, nonatomic) UIAlertView *alertData;              //Alert que se mostrará al usuario si hay algo anómalo
@property (strong, nonatomic) NSDate *firstDate;                   //Contiene el primer dia que cubre la estadística a mostrar
@property (strong, nonatomic) NSDate *lastDate;                    //Cintiene el último día que cubre la estadística a mostrar
@end

@implementation MenuStatsViewController
@synthesize tableView = _tableView;
@synthesize database = _database;
@synthesize statsData = _statsData;
@synthesize dictSearch = _dictSearch;
@synthesize alertData = _alertData;
@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dictSearch = [[NSMutableDictionary alloc] initWithCapacity:2];
    self.statsData = [[StatsData alloc] init];
    self.alertData = [[UIAlertView alloc] initWithTitle:@"Validación de datos"
                                                message:@"No existen compras en este periodo"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
}

//Se invoca este método cuando pulse en alguna celda que presenta una estadística a mostrar. Antes de invocar al controlador oportuno, preparamos la clase StatsData con la información estadística
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.row == 0){
        //Si pulsa en la primera celda está solicitando la estadística por categorías. En este caso se pasa la base de datos en vez del objeto StatsData. La razon es que antes de mostrar la grafica se muestra una pantalla para indicar de forma dinamica la fecha de inicio y fin que se desea
        [segue.destinationViewController setDatabase:self.database];
    }else{
        //El resto de estadísticas pasan por aquí.
        //Primero preparamos el filtro de fechas que cubre la estadística
        [self makeFilterSearch:indexPath.row];
        //Luego se construyen los datos estadísticas para enviar a las gráficas
        if ([self makeStatData:indexPath.row])
            //Si pudo construirse se invoca al controlador que mostrará la gráfica con los datos estadísticos
            [segue.destinationViewController setStatsData:self.statsData];
        else{
            //Si ocurrió un error.
            [self.alertData show];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//construye la fecha de inicio y fin en funcion del tipo de estadistica
-(void)makeFilterSearch:(NSInteger)typeStat
{
    switch (typeStat) {
        case 1:{ //estadistica del mes actual
            self.firstDate = [QueComproUtils getFirstDateOfMonth:[NSDate date]];
            self.lastDate = [QueComproUtils getLastDateOfMonth:self.firstDate];
            [self.dictSearch setObject:self.firstDate forKey:SHOPPING_DATE_FROM];
            [self.dictSearch setObject:self.lastDate forKey:SHOPPING_DATE_UNTIL];
            break;
        }
        case 2:{ //estadística de los tres meses anteriores
            self.firstDate = [QueComproUtils getMonthBefore:3 fromDate:[NSDate date]];
            //Ultimo dia del mes anterior al actual
            self.lastDate = [QueComproUtils getLastDateOfMonth:[QueComproUtils getMonthBefore:1 fromDate:[NSDate date]]];
            [self.dictSearch setObject:self.firstDate forKey:SHOPPING_DATE_FROM];
            [self.dictSearch setObject:self.lastDate forKey:SHOPPING_DATE_UNTIL];
            break;
        }
        case 3:{ //estadistica de los seis meses anteriores
            self.firstDate = [QueComproUtils getMonthBefore:6 fromDate:[NSDate date]];
            self.lastDate = [QueComproUtils getLastDateOfMonth:[QueComproUtils getMonthBefore:1 fromDate:[NSDate date]]];
            //Ultimo dia del mes anterior al actual
            [self.dictSearch setObject:self.firstDate forKey:SHOPPING_DATE_FROM];
            [self.dictSearch setObject:self.lastDate forKey:SHOPPING_DATE_UNTIL];
            break;
        }
        case 4:{ //estadistica de los doce meses anteriores
            self.firstDate = [QueComproUtils getMonthBefore:12 fromDate:[NSDate date]];
            self.lastDate = [QueComproUtils getLastDateOfMonth:[QueComproUtils getMonthBefore:1 fromDate:[NSDate date]]];
            //Ultimo dia del mes anterior al actual
            [self.dictSearch setObject:self.firstDate forKey:SHOPPING_DATE_FROM];
            [self.dictSearch setObject:self.lastDate forKey:SHOPPING_DATE_UNTIL];
            break;
        }
        default:
            break;
    }
}

//construye el objeto statData en función de la estadística
-(BOOL)makeStatData:(NSInteger)typeStat
{
    //recuperamos las compras entre las fechas establecidas en el metodo makeFilterSearch
    NSArray *listShopping = [Shopping getShoppingListWithFilter:self.dictSearch InManagedObjectContext:self.database.managedObjectContext orderByDate:NO];
    if (!listShopping || [listShopping count] == 0)
        return NO;
    
    switch (typeStat) {
        case 1:{ //estadistica del mes actual
            [self.statsData makeCategoryStatsData:listShopping dayPeriod:YES];
            [self.statsData setTitleGraph:@"Gastos del mes actual"];
            [self.statsData setTitleXAxis:@"Días del mes"];
            [self.statsData setTitleYAxis:@"Gastos"];
            NSInteger i;
            NSInteger f = [QueComproUtils getDaysOfMonth:[NSDate date]];
            NSMutableArray *records = [NSMutableArray array];
            //construimos un array que contendra todos los dias del mes actual. Este array representa los valores para el eje x
            for (i = 1;i <= f; i++){
                [records addObject:[NSNumber numberWithInt:i]];
            }
            [self.statsData setRecords:records];
            break;
        }
        case 2:{//estadística de los tres meses anteriores
            [self.statsData makeCategoryStatsData:listShopping dayPeriod:NO];
            [self.statsData setTitleGraph:@"Gastos últimos tres meses"];
            [self.statsData setTitleXAxis:@"Meses"];
            [self.statsData setTitleYAxis:@"Gastos"];
            NSInteger i;
            NSDate *curDate = self.firstDate;
            NSMutableArray *records = [NSMutableArray array];
            //construimos un array que contendra los numeros de mes de los tres meses anteriores al mes actual. Este array representa los valores para el eje x
            for (i = 1;i <= 3; i++){
                [records addObject:[QueComproUtils getMonth:curDate]]; 
                curDate = [QueComproUtils getNextMonth:curDate];
            }
            [self.statsData setRecords:records];
            break;
        }
        case 3:{//estadística de los seis meses anteriores
            [self.statsData makeCategoryStatsData:listShopping dayPeriod:NO];
            [self.statsData setTitleGraph:@"Gastos últimos sesis meses"];
            [self.statsData setTitleXAxis:@"Meses"];
            [self.statsData setTitleYAxis:@"Gastos"];
            NSInteger i;
            NSDate *curDate = self.firstDate;
            NSMutableArray *records = [NSMutableArray array];
            //construimos un array que contendra los numeros de mes de los seis meses anteriores al mes actual. Este array representa los valores para el eje x
            for (i = 1;i <= 6; i++){
                [records addObject:[QueComproUtils getMonth:curDate]]; 
                curDate = [QueComproUtils getNextMonth:curDate];
            }
            [self.statsData setRecords:records];
            break;
        }
        case 4:{//estadística de los doce meses anteriores
            [self.statsData makeCategoryStatsData:listShopping dayPeriod:NO];
            [self.statsData setTitleGraph:@"Gastos último año"];
            [self.statsData setTitleXAxis:@"Meses"];
            [self.statsData setTitleYAxis:@"Gastos"];
            NSInteger i;
            NSDate *curDate = self.firstDate;
            NSMutableArray *records = [NSMutableArray array];
            //construimos un array que contendra los numeros de mes de los doce meses anteriores al mes actual. Este array representa los valores para el eje x
            for (i = 1;i <= 12; i++){
                [records addObject:[QueComproUtils getMonth:curDate]]; //[QueComproUtils getStringFormatDate:curDate withFormat:@"mm/yyyy"]
                curDate = [QueComproUtils getNextMonth:curDate];
            }
            [self.statsData setRecords:records];
            break;
        }
        default:
            break;
    }
    return YES;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
