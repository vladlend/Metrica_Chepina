// Q: Convert a given Integer into textual representation.
// Example input: 788,327,202
// Expected output: Seven Hundred Eighty Eight Million Three Hundred Twenty Seven Thousand Two Hundred And Two
// Other inputs: 0, 1008, 1000008, -7, -0

print(Int.max)

// max allowed input
let maxAllowedAbsoluteInput = Int.max

// dictionary of number with the string representation
let numToText: [Int : String] = [ 0 : "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine",
    10: "Ten", 11: "Eleven", 12: "Twelve", 13: "Thirteen", 14: "Fourteen", 15: "Fifteen", 16: "Sixteen", 17: "Seventeen", 18: "Eighteen", 19: "Nineteen",
    20: "Twenty",
    30: "Thirty",
    40: "Fourty",
    50: "Fifty",
    60: "Sixty",
    70: "Seventy",
    80: "Eighty",
    90: "Ninty",
    100: "Hundred",
    1000: "Thousand",
    1000000: "Million",
    1000000000: "Billion",
    1000000000000: "Trillion",
    1000000000000000: "Quadrillion",
    1000000000000000000: "Quintillion",
    //1000000000000000000000: "Sextillion",
]

// list of metric places in increment of 1000.
let powersOf1000 = ["Thousand", "Million", "Billion", "Trillion", "Quadrillion", "Quintillion"]

// Convert a input number to text representation.
// example inputs: 0, -2703, 2000033
// corresponding outputs: Zero, Negative Two Thousand Seven Hundred And Three, Two Million And Thirty Three
func ConvertToText(number: Int) -> String {

    var output = [String]()
    // find the sign
    let isPositive = (number >= 0)
    // work with absolute number as input
    var r = abs(number)
    if r > maxAllowedAbsoluteInput {
        return "Invalid input; max supported abs(input): \(maxAllowedAbsoluteInput)"
    }
    
    var appendAnd = true
    var powersOf1000Index = -1

    // return early if input is zero
    if r == 0 {
        return numToText[0]!
    }
    
    // extract and work with 3 lowest significant digits at a time
    while r > 0 {
        
        let r3LowestDigits = r % 1000
        r = r / 1000

        if r3LowestDigits == 0 {
            powersOf1000Index++
        }
        else if r3LowestDigits > 0 {
            if powersOf1000Index >= 0 {
                output.insert(powersOf1000[powersOf1000Index], atIndex: 0)
            }
            appendAnd = appendAnd && r > 0
            output.insert((ConvertUnder1000ToText(r3LowestDigits, appendAnd: appendAnd)), atIndex: 0)

            appendAnd = false
            powersOf1000Index++
        }
    }
    
    // append sign
    if !isPositive {
        output.insert("Negative", atIndex: 0)
    }
    
    return output.joinWithSeparator(" ")
}

// a helper function to convert numbers between [1,999] (range inclusive) to readable text
// optionally, allows adding "And" to the output string.
func ConvertUnder1000ToText(let positiveNumberUnder1000: Int, var appendAnd: Bool = false) -> String {
    
    var output = [String]()
    var n = abs(positiveNumberUnder1000)
    
    // extract hundredth place
    if n > 99 {
        let h = n / 100
        output.append(numToText[h]!)
        output.append(numToText[100]!)
        
        n = n % 100
        // append And if needed
        if appendAnd {
            // append "And" at end if n has remaining non-zero value
            if n > 0 {
                output.append("And")
                appendAnd = false
            }
            // insert "And" at begining if n has remaining zero value
            else {
                output.insert("And", atIndex: 0)
                appendAnd = false
            }
        }
    }

    // return early if remainder (n) is zero
    if n == 0 {
        return output.joinWithSeparator(" ")
    }
    
    // insert "And" in case of 070 as input
    if appendAnd {
        output.insert("And", atIndex: 0)
    }
    
    // extract tenth place
    if numToText[n] == nil {
        let tens = n - n % 10
        output.append(numToText[tens]!)
        n = n / 10
    }
    
    // extract ones place
    if n > 0 {
        output.append(numToText[n]!)
    }

    return output.joinWithSeparator(" ")
}

// In production code, these test methods would be replaced by unit tests
// Test ConvertUnder1000ToText
var testNumber = 608
print("Test representation for \(testNumber) is \(ConvertUnder1000ToText(testNumber, appendAnd: true))")

testNumber = 080
print("Test representation for \(testNumber) is \(ConvertUnder1000ToText(testNumber, appendAnd: false))")

testNumber = 0
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")

testNumber = 70000000
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")

testNumber = 70000008
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")

testNumber = 70080000
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")

testNumber = 70800000
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")

testNumber = -Int.max
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")

testNumber = Int.max
print("Test representation for \(testNumber) is \(ConvertToText(testNumber))")