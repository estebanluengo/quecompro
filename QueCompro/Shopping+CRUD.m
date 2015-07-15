//
//  Shopping+CRUD.m
//  QueCompro
//
//  Created by Esteban Luengo on 14/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Shopping+CRUD.h"
#import "QueComproUtils.h"

@implementation Shopping (CRUD)

+(Shopping *)createShopping:(NSDictionary *)shopping
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSNumber *unique = [NSNumber numberWithInt:[Shopping getLastIdShoppingInManagedObjectContext:context]];
    Shopping *s = [NSEntityDescription insertNewObjectForEntityForName:@"Shopping" inManagedObjectContext:context];
    s.unique = unique;
    s.cost = [NSDecimalNumber decimalNumberWithString:[shopping objectForKey:SHOPPING_COST] locale:[NSLocale currentLocale]];
    s.latitude = [shopping objectForKey:SHOPPING_LATITUDE];
    s.longitude = [shopping objectForKey:SHOPPING_LONGITUDE];
    s.favourite = [shopping objectForKey:SHOPPING_FAVOURITE];
    s.date = [shopping objectForKey:SHOPPING_DATE];
    s.photo = [shopping objectForKey:SHOPPING_PHOTO];
    s.ticket = [shopping objectForKey:SHOPPING_TICKET];
    s.comments = [shopping objectForKey:SHOPPING_COMMENTS];
    
    Category *category = [Category createCategory:[shopping objectForKey:SHOPPING_CATEGORY_NAME] inManagedObjectContext:context];
    Article *article = [Article createArticle:[shopping objectForKey:SHOPPING_ARTICLE_NAME] onCategory:category inManagedObjectContext:context];
    s.article = article;
    //añadimos a la categoria el articulo solo si no lo contiene
    if (![category.articles containsObject:article]){
        NSMutableSet *articles = [[NSMutableSet alloc] initWithSet:category.articles];
        [articles addObject:article];
        category.articles = [articles copy];
    }
    //añadimos al articulo la nueva compra
    NSMutableSet *shoppingList = [[NSMutableSet alloc] initWithSet:article.shoppingList];
    [shoppingList addObject:s];
    article.shoppingList = [shoppingList copy];
    NSLog(@"Se inserta la compra en la base de datos");
    return s;
}

+(Shopping *)updateShopping:(NSDictionary *)shopping
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    Shopping *s = [Shopping getShoppingWithId:[shopping objectForKey:SHOPPING_UNIQUE] inManagedObjectContext:context];
    s.photo = [shopping objectForKey:SHOPPING_PHOTO];
    s.ticket = [shopping objectForKey:SHOPPING_TICKET];
    s.comments = [shopping objectForKey:SHOPPING_COMMENTS];
    
    NSLog(@"Se modifica con id %@ la compra en la base de datos",s.unique);
    return s;
}

+(void)deleteShopping:(NSNumber *)idShopping inManagedObjectContext:(NSManagedObjectContext *)context
{
    Shopping *shopping = [Shopping getShoppingWithId:idShopping inManagedObjectContext:context];
    NSLog(@"Compra con id %@ sera borrado",shopping.unique);
    [context deleteObject:shopping];
    NSLog(@"Se elimina la compra");
}

+(Shopping *)getShoppingWithId:(NSNumber *)unique
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Shopping *shopping;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shopping"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    NSLog(@"Se busca una compra con ID:%@",unique);
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Se produce un error al recuperar la compra de la base de datos o existe mas de una compra con el mismo id");
    }else if ([matches count] == 0){
        NSLog(@"La compra no existe en la base de datos");
    } else {
        NSLog(@"La compra existe en la base de datos");
        shopping = [matches lastObject];
    }
    return shopping;
}

+(int)getLastIdShoppingInManagedObjectContext:(NSManagedObjectContext *)context
{
    Shopping *shopping = nil;
    //buscamos el lugar con el nombre name
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shopping"];
    request.fetchLimit = 1;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSLog(@"Se busca la ultima compra");
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    //si no se recupero lo insertamos
    if (!matches || [matches count] == 0) {
        NSLog(@"No existe por lo que el id sera 1");
        return 1;
    }else {
        //en caso contrario retornamos la primera compra
        shopping = [matches lastObject];
        int idShopping = [shopping.unique intValue] + 1;
        NSLog(@"La ultima compra existe en la base de datos y se retorna %d",idShopping);
        return idShopping;
    }
}

+(NSArray *)getShoppingListInManagedObjectContext:(NSManagedObjectContext *)context
                                      orderByDate:(BOOL)orderByDate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shopping"];
    NSMutableArray *arrayPredic = [[NSMutableArray alloc] initWithCapacity:2];
    NSDate *dateFrom = [QueComproUtils getFirstDateOfMonth:[NSDate date]];
    NSDate *dateUntil = [QueComproUtils getLastDateOfMonth:dateFrom];
    [arrayPredic addObject:[NSPredicate predicateWithFormat:@"date >= %@", dateFrom]];
    [arrayPredic addObject:[NSPredicate predicateWithFormat:@"date <= %@", dateUntil]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayPredic];
    NSSortDescriptor *sortDescriptor;
    if (orderByDate)
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
    else
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"Se produce un error al recuperar la compra de la base de datos o existe mas de una compra con el mismo id");
    }
    return matches;
}

+(NSArray *)getShoppingListWithFilter:(NSDictionary *)searchShopping
               InManagedObjectContext:(NSManagedObjectContext *)context
                          orderByDate:(BOOL)orderByDate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shopping"];
    if ([searchShopping count] > 0){
        NSString *article = [searchShopping objectForKey:SHOPPING_ARTICLE_NAME];
        NSString *category = [searchShopping objectForKey:SHOPPING_CATEGORY_NAME];
        NSDate *dateFrom = [searchShopping objectForKey:SHOPPING_DATE_FROM];
        NSDate *dateUntil = [searchShopping objectForKey:SHOPPING_DATE_UNTIL];
        NSMutableArray *arrayPredic = [[NSMutableArray alloc] initWithCapacity:[searchShopping count]];
        if (article){
            [arrayPredic addObject:[NSPredicate predicateWithFormat:@"article.name = %@", article]];
        }
        if (category){
            [arrayPredic addObject:[NSPredicate predicateWithFormat:@"article.category.name = %@", category]];
        }
        if (dateFrom){
            [arrayPredic addObject:[NSPredicate predicateWithFormat:@"date >= %@", dateFrom]];
        }
        if (dateUntil){
            [arrayPredic addObject:[NSPredicate predicateWithFormat:@"date <= %@", dateUntil]];
        }
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayPredic];
    }
    
    NSSortDescriptor *sortDescriptor;
    if (orderByDate)
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
    else
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        NSLog(@"Se produce un error al recuperar la compra de la base de datos o existe mas de una compra con el mismo id");
    }
    return matches;
}

@end
