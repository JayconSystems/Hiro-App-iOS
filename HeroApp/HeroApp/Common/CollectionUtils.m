#import "CollectionUtils.h"

#define MAX_DICT_SIZE 10000

NSDictionary * _dictof(const struct _dictpair* pairs, size_t count) {
    ZAssert(count < MAX_DICT_SIZE, @"can't create dictionary of more than %i pairs", MAX_DICT_SIZE);
    id objects[count], keys[count];
    size_t n = 0;
    for( size_t i=0; i<count; i++,pairs++ ) {
        if( pairs->value ) {
            objects[n] = pairs->value;
            keys[n] = pairs->key;
            n++;
        }
    }
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys count:n];
}


NSMutableDictionary * _mdictof(const struct _dictpair* pairs, size_t count) {
    ZAssert(count < MAX_DICT_SIZE, @"can't create dictionary of more than %i pairs", MAX_DICT_SIZE);
    id objects[count], keys[count];
    size_t n = 0;
    for( size_t i=0; i<count; i++,pairs++ ) {
        if( pairs->value ) {
            objects[n] = pairs->value;
            keys[n] = pairs->key;
            n++;
        }
    }
    return [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys count:n];
}

NSValue* _box(const void *value, const char *encoding) {
    // file:///Developer/Documentation/DocSets/com.apple.ADC_Reference_Library.DeveloperTools.docset/Contents/Resources/Documents/documentation/DeveloperTools/gcc-4.0.1/gcc/Type-encoding.html
    char e = encoding[0];
    if (e == 'r') { // ignore 'const' modifier
        e = encoding[1];
    }               
        
    switch(e) {
        case 'c':   return [NSNumber numberWithChar: *(char*)value];
        case 'C':   return [NSNumber numberWithUnsignedChar: *(char*)value];
        case 's':   return [NSNumber numberWithShort: *(short*)value];
        case 'S':   return [NSNumber numberWithUnsignedShort: *(unsigned short*)value];
        case 'i':   return [NSNumber numberWithInt: *(int*)value];
        case 'I':   return [NSNumber numberWithUnsignedInt: *(unsigned int*)value];
        case 'l':   return [NSNumber numberWithLong: *(long*)value];
        case 'L':   return [NSNumber numberWithUnsignedLong: *(unsigned long*)value];
        case 'q':   return [NSNumber numberWithLongLong: *(long long*)value];
        case 'Q':   return [NSNumber numberWithUnsignedLongLong: *(unsigned long long*)value];
        case 'f':   return [NSNumber numberWithFloat: *(float*)value];
        case 'd':   return [NSNumber numberWithDouble: *(double*)value];
        case '*':   return [NSString stringWithUTF8String: *(char**)value];
        case '@':   return *(id*)value;
        default:    return [NSValue value: value withObjCType: encoding];
    }
}

@implementation NSArray (HigherOrderFunctions)

- (id)findWithPredicateBlock:(BOOL(^)(id element))predicateBlock {
    __block id foundElement = nil;
    [self enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL *shouldStop) {
        if (predicateBlock(element)) {
            foundElement = element;
            *shouldStop = YES;
        }
    }];
    return foundElement;
}

- (id)grepWithPredicateBlock:(BOOL(^)(id element))predicateBlock {
    NSMutableArray *filtered = [@[]mutableCopy];
    [self enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL *shouldStop) {
        if (predicateBlock(element)) {
            [filtered addObject:element];
        }
    }];
    return filtered;
}

- (NSArray *)mapWithBlock:(id(^)(id element))block {
    NSMutableArray *mappedElements = [@[]mutableCopy];
    [self enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL *shouldStop) {
        [mappedElements addObject:block(element)];
    }];
    return mappedElements;
}

- (void)foreachWithBlock:(void(^)(id element))block {
    [self enumerateObjectsUsingBlock:^(id el, NSUInteger idx, BOOL *shouldStop) {
        block(el);
    }];
}

@end


@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end


@implementation NSMutableArray (Reverse)

- (void)reverse {
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end

@implementation NSMutableArray (Queue)

- (id)shift {
    if ([self count] > 0) {
        id obj = [[self objectAtIndex:0] retain];
        [self removeObjectAtIndex:0];
        return [obj autorelease];
    }
    return nil;
}

- (id)pop {
    if ([self count] > 0) {
        id obj = [[self lastObject] retain];
        [self removeLastObject];
        return [obj autorelease];
    }
    return nil;
}

- (void)push:(id)obj {
    [self addObject:obj];
}

-(NSMutableArray *)getValueFromDicUsingKey:(NSString *)key
{
    if (self.count > 0 && key.length > 0 ) {
        NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
        for (int i = 0 ; i< self.count; i++) {
            [arrTemp addObject:[[self objectAtIndex:i] valueForKey:key]];
        }
        return arrTemp;
    }
    return nil;
}

@end

@implementation NSMutableDictionary (Misc)

- (id)removeAndReturnObjectForKey:(id)key {
    id value = [self valueForKey:key];
    [value retain];
    [self setValue:nil forKey:key];
    return [value autorelease];
}

@end


@implementation NSDictionary (TransientProperties)

- (id)transientValueForKey:(NSString *)key {
    return [self valueForKeyPath:[NSString stringWithFormat:@"transientValues.%@", key]];
}


@end


@implementation NSMutableDictionary (TransientProperties)

- (void)setTransientValue:(id)value forKey:(NSString *)key {
    [self setValue:value forKeyPath:[NSString stringWithFormat:@"transientValues.%@", key]];
}

- (void)resetTransientValues {
    [self setValue:[@[]mutableCopy] forKey:@"transientValues"];
}

@end
