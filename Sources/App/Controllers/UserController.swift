import Vapor
import HTTP

// /users
final class UserController: ResourceRepresentable {
    // GET /
    // Get all users
    func getAllUsers(req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    // GET /:id
    // Get user with id
    func getUserWithId(req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    // POST /
    // Create user
    func createUser(req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try user.save()
        return user
    }
    
    // DELETE /:id
    // Delete user with id
    func deleteUser(req: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    // DELETE /
    // Delete all users
    func deleteAllUsers(req: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    // PATCH /:id
    // Update user
    func updateUser(req: Request, user: User) throws -> ResponseRepresentable {
        try user.update(for: req)
        try user.save()
        return user
    }
    
    // Resource
    func makeResource() -> Resource<User> {
        return Resource(
            index: getAllUsers,
            store: createUser,
            show: getUserWithId,
            update: updateUser,
            destroy: deleteUser,
            clear: deleteAllUsers
        )
    }
}

// Deserialize JSON
extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

extension UserController: EmptyInitializable { }
