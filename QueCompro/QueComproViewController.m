//
//  QueComproViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 27/08/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "QueComproViewController.h"
#import "DatabaseHelper.h"
#import "ListShoppingViewController.h"
#import "MenuStatsViewController.h"
#import "Shopping+CRUD.h"
#import "QueComproUtils.h"

@interface QueComproViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnNewShopping;
@property (weak, nonatomic) IBOutlet UIButton *btnShoppingMonth;
@property (weak, nonatomic) IBOutlet UIButton *btnSearchShopping;
@property (weak, nonatomic) IBOutlet UIButton *btnStats;
@property (weak, nonatomic) IBOutlet UIButton *btnFavouriteShopping;
@property (strong, nonatomic) UIManagedDocument *database;

@end

@implementation QueComproViewController
@synthesize btnNewShopping = _btnNewShopping;
@synthesize btnShoppingMonth = _btnShoppingMonth;
@synthesize btnSearchShopping = _btnSearchShopping;
@synthesize btnStats = _btnStats;
@synthesize btnFavouriteShopping = _btnFavouriteShopping;


@synthesize database = _database;

-(void)databaseOpened:(UIManagedDocument *)database
{
    self.database = database;
    NSLog(@"Base de datos abierta");
}

//A la carga de la pantalla se abre la base de datos. Esta referencia a la base de datos se transmite al resto de controladores
- (void)viewDidLoad
{
    [super viewDidLoad];
	[DatabaseHelper openDatabaseUsingBlock:^(UIManagedDocument *database){
        [self databaseOpened:database];
    }];
    [self.btnNewShopping setImage:[UIImage imageNamed:@"shopping"] forState:UIControlStateNormal];
    [self.btnShoppingMonth setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
    [self.btnSearchShopping setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.btnStats setImage:[UIImage imageNamed:@"stats"] forState:UIControlStateNormal];
    [self.btnFavouriteShopping setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    
}

//A todos los controladores se les transmite la referencia a la base de datos
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue to %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"New shopping"] ||
        [segue.identifier isEqualToString:@"Favourite shopping"] ||
        [segue.identifier isEqualToString:@"Search shopping"] ||
        [segue.identifier isEqualToString:@"View stats"] ||
        [segue.identifier isEqualToString:@"Shopping list"]){
            [segue.destinationViewController setDatabase:self.database];
    }
}

- (void)viewDidUnload
{
    [self setBtnNewShopping:nil];
    [self setBtnShoppingMonth:nil];
    [self setBtnSearchShopping:nil];
    [self setBtnStats:nil];
    [self setBtnFavouriteShopping:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
