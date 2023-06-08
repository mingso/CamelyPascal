import SwiftCompilerPlugin
import OSLog
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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
        return [DeclSyntax(codingKeys)]
    }
}


@main
struct CamelyPascalPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CamelyPascalMacro.self,
    ]
}
