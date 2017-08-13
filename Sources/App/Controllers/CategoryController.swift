import Vapor
import HTTP

// /categories
final class CategoryController {
    
    // Routes
    func makeRoutes(routes: RouteBuilder) {
        let group = routes.grouped("categories")
        
        group.get(handler: getAllCategories)
        group.get(Category.parameter, handler: getCategoryWithId)
        group.post(handler: createCategory)
        group.delete(Category.parameter, handler: deleteCategory)
        group.patch(Category.parameter, handler: updateCategory)
        group.get("root", handler: getRootCategories)
        group.get(Category.parameter, "subcategories", handler: getSubategories)
    }
    
    // METHODS
    
    // GET /
    // Get all categories
    func getAllCategories(req: Request) throws -> ResponseRepresentable {
        return try Category.all().makeJSON()
    }
    
    // GET /:id
    // Get category with id
    func getCategoryWithId(req: Request) throws -> ResponseRepresentable {
        let category = try req.parameters.next(Category.self)
        return category
    }
    
    // POST /
    // Create category
    func createCategory(req: Request) throws -> ResponseRepresentable {
        let category = try req.category()
        try category.save()
        return category
    }
    
    // DELETE /:id
    // Delete category with id
    func deleteCategory(req: Request) throws -> ResponseRepresentable {
        let category = try req.parameters.next(Category.self)
        try category.delete()
        return Response(status: .ok)
    }
    
    // PATCH /:id
    // Update category
    func updateCategory(req: Request) throws -> ResponseRepresentable {
        let category = try req.parameters.next(Category.self)
        try category.update(for: req)
        try category.save()
        return category
    }
    
    // GET /root
    // Get root categories
    func getRootCategories(req: Request) throws -> ResponseRepresentable {
        return try Category.makeQuery().filter(Category.parentIdKey, .equals, nil).all().makeJSON()
    }
    
    // GET /:id/subcategories
    // Get subcategories
    func getSubategories(req: Request) throws -> ResponseRepresentable {
        let category = try req.parameters.next(Category.self)
        return try Category.makeQuery().filter(Category.parentIdKey, .equals, category.id).all().makeJSON()
    }
}

// Deserialize JSON
extension Request {
    func category() throws -> Category {
        guard let json = json else { throw Abort.badRequest }
        return try Category(json: json)
    }
}

extension CategoryController: EmptyInitializable { }
