import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
     
        // Auth
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        let authed = grouped(tokenMiddleware)
        
        authed.get("me") { req in
            return try req.authUser().email
        }
        
        let test1 = grouped("test1")
        test1.get() { req in
            return "aaaa"
        }
        
        // AUTH
        
        // /auth
        let authGroup = grouped("auth")
        let authGroupAuthed = authed.grouped("auth")
        
        let authController = AuthController()
        
        authGroup.post("login", handler: authController.login)
        authGroupAuthed.post("logout", handler: authController.logout)
        
        // /users
        try authed.resource("users", UserController.self)

        
        // CONTENT
        
        // /products
        ProductController().makeRoutes(routes: authed)
        
        // /categories
        CategoryController().makeRoutes(routes: authed)
        
        // /categoryfilters
        CategoryFilterController().makeRoutes(routes: authed)
    }
}

extension Request {
    func authUser() throws -> User {
        return try auth.assertAuthenticated()
    }
}
