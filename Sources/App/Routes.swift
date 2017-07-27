import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
     
        // Auth
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        let authed = grouped(tokenMiddleware)
        
        authed.get("me") { req in
            return try req.user().email
        }
        
        // /products
        try authed.resource("products", ProductController.self)
        
    }
}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
