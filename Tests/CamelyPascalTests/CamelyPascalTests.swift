import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CamelyPascalMacros

let testMacros: [String: Macro.Type] = [
    "camelyPascal": CamelyPascalMacro.self,
]

final class CamelyPascalTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @camelyPascal
            class Example: Codable {
                var string: String?
                var int: Int?
            }
            """,
            expandedSource: """
            
            class Example: Codable {
                var string: String?
                var int: Int?
                enum CodingKeys: String, CodingKey {
                    case string = "String"
                    case int = "Int"
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacroWithStruct() {
        assertMacroExpansion(
            """
            @camelyPascal
            struct Example {
                var stringA: String?
                var intB: Int?
            }
            """,
            expandedSource: """
            
            struct Example {
                var stringA: String?
                var intB: Int?
                enum CodingKeys: String, CodingKey {
                    case stringA = "StringA"
                    case intB = "IntB"
                }
            }
            """,
            macros: testMacros
        )
    }
}
