import SwiftCompilerPlugin
import OSLog
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `CamelyPascal` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     @CamelyPascal
///     class CamelModel: Codable {
///         var str: String?
///     }
///
///  will expand to
///
///     class CamelModel: Codable {
///         var str: String?
///         enum CodingKeys: String, CodingKey {
///             case str = "Str"
///         }
///
///     }
///

enum CamelyPascalError: CustomStringConvertible, Error {
    case onlyApplicableToClassOrStruct

    var description: String {
        switch self {
        case .onlyApplicableToClassOrStruct: return "@CamelyPascal scan only applied to struct or class"
        }
    }
}

public struct CamelyPascalMacro: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        let members: MemberDeclListSyntax

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            members = classDecl.memberBlock.members
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            members = structDecl.memberBlock.members
        } else {
            throw CamelyPascalError.onlyApplicableToClassOrStruct
        }

        let varDecls = members.compactMap{ $0.decl.as(VariableDeclSyntax.self) }
        let bindingList = varDecls.compactMap { $0.bindings.as(PatternBindingListSyntax.self) }
        let identifierPatterns = bindingList.compactMap { $0.first?.pattern.as(IdentifierPatternSyntax.self) }
        let identifiers: [TokenSyntax] = identifierPatterns.compactMap { $0.identifier } 

        let codingKeys = EnumDeclSyntax(enumKeyword: TokenSyntax.keyword(.enum),
                                        identifier: .identifier("CodingKeys"),
                                        inheritanceClause: TypeInheritanceClauseSyntax(colon: TokenSyntax.colonToken(),
                                                                                       inheritedTypeCollection: InheritedTypeListSyntax {
            let string = InheritedTypeSyntax(typeName: SimpleTypeIdentifierSyntax(name: "String"), trailingComma: .commaToken())
            let codingKey = InheritedTypeSyntax(typeName: SimpleTypeIdentifierSyntax(name: "CodingKey"))
            [string, codingKey]
        }),
                                        memberBlock: MemberDeclBlockSyntax { MemberDeclListSyntax {
            for identifier in identifiers {
                EnumCaseDeclSyntax {
                    let capitalizedIdentifier = (identifier.text.first?.uppercased() ?? "") + identifier.text.dropFirst()
                    EnumCaseElementSyntax(identifier: identifier,
                                          rawValue: InitializerClauseSyntax(value: StringLiteralExprSyntax(content: capitalizedIdentifier)))
                }
            }
        }})

        /// The following code performs the same operation.
        /*
        let codingKeys = try EnumDeclSyntax("enum CodingKeys: String, CodingKey") {
            MemberDeclListSyntax {
                for identifier in identifiers {
                    EnumCaseDeclSyntax {
                        let capitalizedIdentifier = (identifier.text.first?.uppercased() ?? "") + identifier.text.dropFirst()
                        EnumCaseElementSyntax(identifier: identifier,
                                              rawValue: InitializerClauseSyntax(value: StringLiteralExprSyntax(content: capitalizedIdentifier)))
                    }
                }
            }
        }
         */
        return [DeclSyntax(codingKeys)]
    }
}


@main
struct CamelyPascalPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CamelyPascalMacro.self,
    ]
}
