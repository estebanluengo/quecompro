//
//  StatsCategoryViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "StatsCategoryViewController.h"

@interface StatsCategoryViewController ()
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView; //La vista hereda de CPTGraphHostingView
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnViewLegend;   
@property (nonatomic) BOOL legend;   //nos indica si debemos o no mostrar la leyenda en la estadística

-(void)initPlot;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;
@end

@implementation StatsCategoryViewController
@synthesize statsData = _statsData;
@synthesize hostView = _hostView;
@synthesize btnViewLegend = _btnViewLegend;
@synthesize legend = _legend;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //inicialmente no mostramos la leyenda
    self.legend = NO;
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureGraph];
    [self configureChart];
}

//Se configura el gráfico general. Títulos, estilos, paddings.
-(void)configureGraph {
    //Init del gráfico
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    graph.paddingBottom = 1.0f;
    graph.paddingLeft  = 1.0f;
    graph.paddingTop    = 1.0f;
    graph.paddingRight  = 1.0f;
    graph.axisSet = nil;
    //Definimos style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;
    //Definimos Título
    NSString *title = @"Gastos por categorías";
    graph.title = title;
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
}

//Se configura la gráfica
-(void)configureChart {
    //Obtenemos referencia al view
    CPTGraph *graph = self.hostView.hostedGraph;
    //Se crea el chart. En este caso en forma de tarta
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    //Nosotros proveemos los datos
    pieChart.dataSource = self;
    //Nosotros gesionamos la gráfica
    pieChart.delegate = self;
    pieChart.pieRadius = (self.hostView.bounds.size.height * 0.4) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    //Creamos el gradiente
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    //Añadimos la gráfica a la vista
    [graph addPlot:pieChart];
}

//La leyenda se muestra a voluntad del usuario
-(void)configureLegend {
    //Obtenemos referencia al view
    CPTGraph *graph = self.hostView.hostedGraph;
    //Creamos leyenda
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    //Configuramos leyenda
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    //Añadimos la leyenda al gráfico
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

//Cuando se pulse para ver o ocultar la leyenda se ejecutará este metodo
- (IBAction)pressViewLegend:(UIBarButtonItem *)sender {
    self.legend = !self.legend;
    if (self.legend == YES){
        [self configureLegend];
    }else{
        CPTGraph *graph = self.hostView.hostedGraph;
        graph.legend = nil;
    }
}

#pragma mark - CPTPlotDataSource methods
//El numero de categorias nos determina el numero de registros de la tarta
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[self.statsData getCategoriesNames] count];
}

//Retorna el valor para el registro que ocupa la posicion index
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (CPTPieChartFieldSliceWidth == fieldEnum)
    {
        NSNumber *data = [[self.statsData getCategoriesCost] objectAtIndex:index];
        return data;
    }
    return [NSDecimalNumber zero];
}

//Retorna el label asociado a cada registro que ocupa la posicion index
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    //Define el label
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor grayColor];
    }
    //Calculamos el coste total de todas las categorias
    
    NSDecimalNumber *costSum = [NSDecimalNumber zero];
    for (NSDecimalNumber *cost in [self.statsData getCategoriesCost]) {
        costSum = [costSum decimalNumberByAdding:cost];
    }
    // Calculamos el porcentaje de cada gasto en funcion del total de gasto
    NSDecimalNumber *cost = [[self.statsData getCategoriesCost] objectAtIndex:index];
    NSDecimalNumber *percent = [cost decimalNumberByDividingBy:costSum];
    NSString *labelValue = [NSString stringWithFormat:@"%0.2f (%0.1f %%)", [cost floatValue], ([percent floatValue] * 100.0f)];
    return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];

}

//Mu
-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    if (index < [[self.statsData getCategoriesNames] count]){
        return [[self.statsData getCategoriesNames] objectAtIndex:index];
    }
    return @"N/A";
}

- (void)viewDidUnload
{
    [self setBtnViewLegend:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
