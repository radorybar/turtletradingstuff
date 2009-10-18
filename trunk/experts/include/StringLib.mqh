//+------------------------------------------------------------------+
//|                                                    StringLib.mqh |
//|                                                                  |
//| Copyright © 2008 Witold Wozniak. All rights reserved.            |
//|                                                                  |
//| This software is free for personal use.                          |
//|                                                                  |
//| This software is provided "as is", without any guarantee made as |
//| to its suitability or fitness for any particular use. It may     |
//| contain bugs, so use of this tool is at your own risk. Author    |
//| takes no responsibility for any damage that may unintentionally  |
//| be caused through its use.                                       |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
#property copyright "Witold Wozniak"
#property link      "www.mqlsoft.com"

#import "StringLib.ex4"

string stringReplaceAll(string str, string toFind, string toReplace);
string stringReplaceFirst(string str, string toFind, string toReplace);
void stringSplit(string& output[], string input, string token);
string stringTrim(string str);
bool stringStartsWith(string str, string prefix);
bool stringEndsWith(string str, string suffix);
string stringToLowerCase(string str);
string stringToUpperCase(string str);
bool stringEqualsIgnoreCase(string str1, string str2);
bool stringContainsIgnoreCase(string str1, string str2);
int stringFindIgnoreCase(string str, string substr);