//+------------------------------------------------------------------+
//|                                                    StringLib.mq4 |
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
#property library

/**
 *  Returns a new string resulting from replacing all occurrences of 
 *  toFind in this string with toReplace.
 */
string stringReplaceAll(string str, string toFind, string toReplace) {
    int len = StringLen(toFind);
    int pos;
    string leftPart, rightPart, result = str;
    while (true) {
        pos = StringFind(result, toFind);
        if (pos == -1) {
            break;
        }
        if (pos == 0) {
            leftPart = "";
        } else {
            leftPart = StringSubstr(result, 0, pos);
        }
        rightPart = StringSubstr(result, pos + len); 
        result = leftPart + toReplace + rightPart;
    }    
    return (result);
}

/**
 *  Replaces the first substring of this string that matches toFind 
 *  with toReplace.
 */
string stringReplaceFirst(string str, string toFind, string toReplace) {
    int len = StringLen(toFind);
    int pos = StringFind(str, toFind);
    if (pos == -1) {
        return (str);
    } else if (pos == 0) {
        return (toReplace + StringSubstr(str, pos + len));
    }
    return (StringSubstr(str, 0, pos) + toReplace + StringSubstr(str, pos + len));
}

/**
 *  Splits input string into output array around given token.
 */
void stringSplit(string& output[], string input, string token) {
    int pos, size;
    ArrayResize(output, 0);
    while (true) {
        pos = StringFind(input, token);
        size = ArraySize(output);
        ArrayResize(output, size + 1);
        if (pos != -1) {
            if (pos > 0) {
                output[size] = StringSubstr(input, 0, pos);
            } else {
                output[size] = "";
            }
            input = StringSubstr(input, pos + 1);
        } else {
            output[size] = input;
            break;
        }        
    }
}

/**
 *  Returns a copy of the string, with leading and trailing whitespace omitted.
 */
string stringTrim(string str) {
    return (StringTrimRight(StringTrimLeft(str)));
}

/**
 *  Tests if given string starts with the specified prefix.
 */
bool stringStartsWith(string str, string prefix) {
    return (StringFind(str, prefix) == 0);
}

/**
 *  Tests if given string ends with the specified suffix.
 */
bool stringEndsWith(string str, string suffix) {
    int start = StringLen(str) - StringLen(suffix);
    return (StringFind(str, suffix, start) == start);
}

/**
 *  
 */
bool stringStartsWithIgnoreCase(string str, string prefix) {
    return (StringFind(stringToLowerCase(str), stringToLowerCase(prefix)) == 0);
}

/**
 *  
 */
bool stringEndsWithIgnoreCase(string str, string suffix) {
    int start = StringLen(str) - StringLen(suffix);
    return (StringFind(stringToLowerCase(str), stringToLowerCase(suffix), start) == start);
}

/**
 *  
 */
bool stringContainsIgnoreCase(string str, string substr) {
    return (StringFind(stringToLowerCase(str), stringToLowerCase(substr)) > -1);
}

/**
 *  
 */
int stringFindIgnoreCase(string str, string substr) {
    return (StringFind(stringToLowerCase(str), stringToLowerCase(substr)));
}

/**
 *   Converts all of the characters in the given string to lower case.
 */
string stringToLowerCase(string str) {
    for (int i = 0; i < StringLen(str); i++) {
        int code = StringGetChar(str, i);
        if (code >= 65 && code <= 90) {
            code += 32;
            str = StringSetChar(str, i, code);
        }
    }
    return (str);
}

/**
 *  Converts all of the characters in the given string to upper case.
 */
string stringToUpperCase(string str) {
    for (int i = 0; i < StringLen(str); i++) {
        int code = StringGetChar(str, i);
        if (code >= 97 && code <= 122) {
            code -= 32;
            str = StringSetChar(str, i, code);
        }
    }
    return (str);
}

/**
 *  Compares one string to another string, ignoring case considerations.
 */
bool stringEqualsIgnoreCase(string str1, string str2) {
    return (stringToLowerCase(str1) == stringToLowerCase(str2));
}