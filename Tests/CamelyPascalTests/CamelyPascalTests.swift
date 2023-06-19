import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CamelyPascalMacros

let testMacros: [String: Macro.Type] = [
    "CamelyPascal": CamelyPascalMacro.self,
]

final class CamelyPascalTests: XCTestCase {
    func test_CamelyPascal_inClass() {
        assertMacroExpansion(
            """
            @CamelyPascal
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
    
    func test_CamelyPascal_inStruct() {
        assertMacroExpansion(
            """
            @CamelyPascal
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
