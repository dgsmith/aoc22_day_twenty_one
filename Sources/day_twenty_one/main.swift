import Darwin
import Foundation

typealias MonkeyFunction = (_ lhs: Monkey, _ rhs: Monkey) -> Double

func functionFromString(_ string: String) -> MonkeyFunction {
    if string == "+" {
        return { $0.result + $1.result }
        
    } else if string == "-" {
        return { $0.result - $1.result }
                
    } else if string == "*" {
        return { $0.result * $1.result }
        
    } else if string == "/" {
        return { $0.result / $1.result }
        
    } else {
        fatalError()
    }
}

let equalFunction: MonkeyFunction = { $0.result - $1.result }

class Monkey: Hashable {
    static func == (lhs: Monkey, rhs: Monkey) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    let name: String
    
    var referenceMonkeys: [Monkey]?
    var function: MonkeyFunction?
    
    var value: Double?
    
    init(name: String) {
        self.name = name
    }
    
    var result: Double {
        if let value {
            return value
        }
        
        guard let function, let referenceMonkeys else {
            fatalError()
        }
        
        return function(referenceMonkeys[0], referenceMonkeys[1])
    }
}

var monkeys = Set<Monkey>()
var monkeysToMatch = [Monkey: [String]]()
var root: Monkey?
var human: Monkey?

let filePath = "/Users/grayson/code/advent_of_code/2022/day_twenty_one/input.txt"
guard let filePointer = fopen(filePath, "r") else {
    preconditionFailure("Could not open file at \(filePath)")
}
var lineByteArrayPointer: UnsafeMutablePointer<CChar>?
defer {
    fclose(filePointer)
    lineByteArrayPointer?.deallocate()
}
var lineCap: Int = 0
while getline(&lineByteArrayPointer, &lineCap, filePointer) > 0 {
    let line = String(cString:lineByteArrayPointer!)
    
    let name = String(line.firstMatch(of: #/(\w+):/#)!.output.1)
    var monkey = Monkey(name: name)
    if name == "root" {
        root = monkey
    }
    if name == "humn" {
        human = monkey
    }
    
    if line.components(separatedBy: .whitespacesAndNewlines)[1][line.startIndex].isNumber {
        let value = Double(line.firstMatch(of: #/\d+/#)!.output)!
        monkey.value = value
        
    } else {
        let match = line.firstMatch(of: #/: (\w+) (.) (\w+)/#)!.output
        
        let firstMonkey = String(match.1)
        let secondMonkay = String(match.3)
        let function = functionFromString(String(match.2))
        if name == "root" {
            monkey.function = equalFunction
        } else {
            monkey.function = function
        }
        monkeysToMatch[monkey] = [firstMonkey, secondMonkay]
    }
    
    monkeys.insert(monkey)
}

for monkey in monkeysToMatch {
    let firstMonkey = monkeys.first(where: { $0.name == monkey.value[0] })!
    let secondMonkey = monkeys.first(where: { $0.name == monkey.value[1] })!
    
    monkey.key.referenceMonkeys = [firstMonkey, secondMonkey]
}

var i = 0
while true {
    // 2.8717e13
    // next
    // 3.9161e12
    // 3.9166e12
    // next
    // 3916482553752
    // 3916495112071
    let range = 3916482553752...3916495112071
    if i > range.count {
        print("Fail")
        break
    }
    
    let random = Int.random(in: range)
    human!.value = Double(random)
    
    let result = root!.result
    if result == 0 {
        print(random)
        break
    }
//    print("\(random), \(result)")
    
    i += 1
}
//print(root!.result)
