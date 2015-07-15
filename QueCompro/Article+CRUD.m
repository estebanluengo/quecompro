//
//  Article+CRUD.m
//  QueCompro
//
//  Created by Esteban Luengo on 14/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Article+CRUD.h"

@implementation Article (CRUD)

+(Article *)getArticleWithName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Article *article = nil;
    //buscamos el lugar con el nombre name
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSLog(@"Se busca una articulo con nombre:%@",name);
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    //si no se recupero lo insertamos
    if (!matches || [matches count] > 1) {
        NSLog(@"Se produce algun error al recuperar la categoria de la base de datos o existe mas de una categoria con el mismo nombre");
    }else if ([matches count] > 0){
        //en caso contrario lo retornamos
        NSLog(@"La categoria existe en la base de datos y se retorna");
        article = [matches lastObject];
    }
    return article;
}

+(NSArray *)getArticlesContaining:(NSString *)name
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    //buscamos el lugar con el nombre name
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"name", nil]];
    request.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", name];
    [request setResultType:NSDictionaryResultType];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSLog(@"Se buscan articulos que contengan:%@",name);
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}

+(Article *)createArticle:(NSString *)articleName onCategory:(Category *)category inManagedObjectContext:(NSManagedObjectContext *)context
{
    Article *article = [Article getArticleWithName:articleName inManagedObjectContext:context];
    if (article == nil){
        article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:context];
        article.name = articleName;
        article.category = category;
        NSLog(@"Se crea un articulo nuevo en la base de datos");
    }
    return article;
}



@end
