import HTTP
import Authentication

public final class AuthMiddleware<U: TokenAuthenticatable>: Middleware {
    public init(_ userType: U.Type = U.self) {}
    
    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        // if the user has already been authenticated
        // by a previous middleware, continue
        if req.auth.isAuthenticated(U.self) {
            return try next.respond(to: req)
        }
        
        guard let token = req.auth.header?.bearer else {
            throw AuthenticationError.invalidCredentials
        }
        
        let u = try U.authenticate(token)
        
        req.auth.authenticate(u)
        
        return try next.respond(to: req)
    }
}
