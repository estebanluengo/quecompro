//
//  FavouriteShoppingTableViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 06/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "FavouriteShoppingTableViewController.h"
#import "FavouriteCell.h"
#import "QueComproUtils.h"
#import "NewShoppingViewController.h"
#import "ListShoppingViewController.h"
#import "Shopping.h"
#import "Category.h"
#import "Article.h"

@interface FavouriteShoppingTableViewController ()

@end

@implementation FavouriteShoppingTableViewController
@synthesize database = _database;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//Carga la lista de compras favoritas ordenadas por orden alfabetico ascendente
-(void)loadFavouriteShopping
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shopping"];
    request.predicate = [NSPredicate predicateWithFormat:@"favourite = %@", [NSNumber numberWithInt:1]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.database.managedObjectContext
                                                                          sectionNameKeyPath:nil  //para mirar por categorias: @"article.category.name"
                                                                                   cacheName:nil];
}

-(void)setDatabase:(UIManagedDocument *)database
{
    if (_database != database){
        _database = database;
    }
    [self loadFavouriteShopping];    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Favourite ID";
    FavouriteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Shopping *shopping = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.articleName.text = shopping.article.name;
    cell.costShopping.text = [QueComproUtils stringValue:shopping.cost withDecimals:2];
    
    UIActivityIndicatorView *spinner = [QueComproUtils startSpinner:cell.image];
    dispatch_queue_t downloadQueue = dispatch_queue_create("shopping load photo", NULL);
    dispatch_async(downloadQueue, ^{
        NSString *photoName = [TYPE_PHOTO stringByAppendingString:[shopping.unique stringValue]];
        NSLog(@"Se carga la foto:%@",photoName);
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner removeFromSuperview];
            cell.image.image = [QueComproUtils loadPhoto:photoName];
            NSLog(@"foto en la vista");            
        });
    });
    dispatch_release(downloadQueue);
    return cell;
}

//Cuando hagan click en algun elemento del listado nos vamos a crear una nueva compra con los datos de la compra favorita
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"New shopping"]){
        //enviamos al siguiente controller el objeto place seleccionado
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Shopping *shopping = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"nos vamos a ver la compra de %@",shopping.article.name);
        [segue.destinationViewController setDatabase:self.database];
        [segue.destinationViewController setShopping:shopping];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
