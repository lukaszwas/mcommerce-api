import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
     
        // Auth
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        let authed = grouped(tokenMiddleware)
        
        // AUTH
        
        // /auth
        let authGroup = grouped("auth")
        let authGroupAuthed = authed.grouped("auth")
        
        let authController = AuthController()
        let userController = UserController()
        
        authGroup.post("login", handler: authController.login)
        authGroupAuthed.post("logout", handler: authController.logout)
        authGroup.post("register", handler: userController.createUser)
        
        // /users
        try authed.resource("users", UserController.self)
        
        // CONTENT
        
        // /products
        ProductController().makeRoutes(routes: self)
        
        // /categories
        CategoryController().makeRoutes(routes: self)
        
        // /categoryfilters
        CategoryFilterController().makeRoutes(routes: self)
        
        // /purchase
        PurchaseController().makeRoutes(routes: authed)
    }
}

extension Request {
    func authUser() throws -> User {
        return try auth.assertAuthenticated()
    }
}
