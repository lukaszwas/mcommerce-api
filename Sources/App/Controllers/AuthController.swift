import Vapor
import HTTP
import Foundation

// /auth
final class AuthController {
    // POST /login
    // Login
    func login(req: Request) throws -> ResponseRepresentable {
        let credentials = try req.credentials()
        
        guard let user = try User.makeQuery()
            .filter(User.emailKey, .equals, credentials.email)
            .filter(User.passwordKey, .equals, credentials.password)
            .first()
            else { throw Abort.badRequest }
        
        let token = Token(token: NSUUID().uuidString, userId: user.id!)
        try token.save()
        
        return token
    }
    
    // POST /logout
    // Logout
    func logout(req: Request) throws -> ResponseRepresentable {
        let token = req.auth.header?.bearer?.string
        
        let tokenRow = try Token.makeQuery()
        .filter(Token.tokenKey, .equals, token)
        .first()
        
        try tokenRow?.delete()
        
        return ""
    }
}

// Deserialize JSON
extension Request {
    func credentials() throws -> Credentials {
        guard let json = json else { throw Abort.badRequest }
        return try Credentials(json: json)
    }
}

extension AuthController: EmptyInitializable { }
