//
//  BBCodeParserTests.m
//  BBCodeParserTests
//
//  Created by Miha Rataj on 2/2/12.
//  Copyright (c) 2012 Marg, d.o.o. All rights reserved.
//

#import "BBCodeParserTests.h"
#import "BBCodeParser.h"

@implementation BBCodeParserTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

+ (NSArray *)getTags
{
    static NSArray *tags;
    if (tags == nil)
    {
        tags = [[NSArray alloc] initWithObjects:@"bold", @"quote", @"user", nil];
    }
    return tags;
}

- (void)testSimpleTag
{
    NSString *code = @"This is [bold]test[/bold] message. See you soon.";
    
    NSArray *tags = [BBCodeParserTests getTags];
    BBCodeParser *parser = [[BBCodeParser alloc] initWithTags:tags];
    [parser setCode:code];
    [parser parse];
    
    STAssertNotNil(parser.element, @"Root element cant be nil");
    STAssertTrue([parser.element.elements count] == 1, @"There must be 1 element");
}

- (void)testAttributes
{
    NSString *code = @"[quote user=\"23\" name=\"David Cole\"]Person [user]Johnny Newille[/user] created this.[/quote]";
    
    NSArray *tags = [BBCodeParserTests getTags];
    BBCodeParser *parser = [[BBCodeParser alloc] initWithTags:tags];
    [parser setCode:code];
    [parser parse];
    
    BBElement *quoteElement = [parser.element.elements objectAtIndex:0];
    STAssertTrue([quoteElement.attributes count] == 2, @"There must be two attributes.");
    
    BBAttribute *attribute = [quoteElement.attributes objectAtIndex:0];
    STAssertTrue([attribute.name isEqualToString:@"user"], @"Invalid attribute name");
    STAssertTrue([attribute.value isEqualToString:@"23"], @"Invalid attribute value");
}

- (void)testInvalidTag
{
    NSString *code = @"This{{13}} [invalid tag] is [bold]test[/bold] message.";
    
    NSArray *tags = [BBCodeParserTests getTags];
    BBCodeParser *parser = [[BBCodeParser alloc] initWithTags:tags];
    [parser setCode:code];
    [parser parse];
    
    STAssertTrue([parser.element.elements count] == 1, @"There must be 1 element");
}

- (void)testBrokenTag
{
    NSString *code = @"This [boldtest[/bold] message.";
    
    NSArray *tags = [BBCodeParserTests getTags];
    BBCodeParser *parser = [[BBCodeParser alloc] initWithTags:tags];
    [parser setCode:code];
    [parser parse];
    
    STAssertTrue([parser.element.elements count] == 0, @"There must be zero elements");
}

- (void)testNotSupportedTag
{
    NSString *code = @"This [italic]is italic[/italic] message.";
    
    NSArray *tags = [BBCodeParserTests getTags];
    BBCodeParser *parser = [[BBCodeParser alloc] initWithTags:tags];
    [parser setCode:code];
    [parser parse];
    
    STAssertTrue([parser.element.elements count] == 0, @"There must be zero elements");
}

- (void)testStartIndex
{
    NSString *code = @"[quote user=\"23\" name=\"David Cole\"]Person [user]Johnny Newille[/user] created [bold]this.[/bold][/quote]";
    
    NSArray *tags = [BBCodeParserTests getTags];
    BBCodeParser *parser = [[BBCodeParser alloc] initWithTags:tags];
    [parser setCode:code];
    [parser parse];
    
    BBElement *quoteElement = [parser.element.elements objectAtIndex:0];
    STAssertTrue(quoteElement.startIndex == 0, @"Invalid start index");
    
    BBElement *userElement = [quoteElement.elements objectAtIndex:0];
    STAssertTrue(userElement.startIndex == 7, @"Invalid start index");
    
    BBElement *boldElement = [quoteElement.elements objectAtIndex:1];
    STAssertTrue(boldElement.startIndex == 30, @"Invalid start index");
}

@end
