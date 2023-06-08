import Foundation
import CamelyPascal

@CamelyPascal
@objc
class Model: NSObject, Codable {
    var variableA: String?
    var variableB: Int?
}

/* struct나 class가 아닌곳에서 사용했을 때 에러 
 @CamelyPascal
 enum enumaration {
 case aa, bb
 }
 */
