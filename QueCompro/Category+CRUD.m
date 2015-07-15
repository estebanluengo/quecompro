//
//  Category+CRUD.m
//  QueCompro
//
//  Created by Esteban Luengo on 14/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Category+CRUD.h"

@implementation Category (CRUD)

+(Category *)getCategoryWithName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    Category *category = nil;
    //buscamos el lugar con el nombre name
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSLog(@"Se busca una categoria con nombre:%@",name);
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    //si no se recupero lo insertamos
    if (!matches || [matches count] > 1) {
        NSLog(@"Se produce algun error al recuperar la categoria de la base de datos o existe mas de una categoria con el mismo nombre");
    }else if ([matches count] > 0){
        //en caso contrario lo retornamos
        NSLog(@"La categoria existe en la base de datos y se retorna");
        category = [matches lastObject];
    }
    return category;
}

+(NSArray *)getCategoriesContaining:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    //buscamos el lugar con el nombre name
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"name", nil]];
    request.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", name];
    [request setResultType:NSDictionaryResultType];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSLog(@"Se buscan categorias que contengan:%@",name);
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}

+(Category *)createCategory:(NSString *)categoryName inManagedObjectContext:(NSManagedObjectContext *)context
{
    Category *category = [Category getCategoryWithName:categoryName inManagedObjectContext:context];
    if (category == nil){
        category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        category.name = categoryName;
        NSLog(@"Se crea una categoria nueva en la base de datos");
    }
    return category;
}

@end
