import Vapor
import HTTP

// /categoryfilters
final class CategoryFilterController {
    
    // Routes
    func makeRoutes(routes: RouteBuilder) {
        let group = routes.grouped("categoryfilters")
        
        group.get(handler: getAllFilters)
        group.get(CategoryFilter.parameter, handler: getFilterWithId)
        group.post(handler: createFilter)
        group.delete(CategoryFilter.parameter, handler: deleteFilter)
        group.patch(CategoryFilter.parameter, handler: updateFilter)
        group.get("category", Category.parameter, handler: getAllFiltersForCategory)
    }
    
    // METHODS
    
    // GET /
    // Get all category filters
    func getAllFilters(req: Request) throws -> ResponseRepresentable {
        return try CategoryFilter.all().makeJSON()
    }
    
    // GET /:id
    // Get category filter with id
    func getFilterWithId(req: Request) throws -> ResponseRepresentable {
        let categoryFilter = try req.parameters.next(CategoryFilter.self).makeJSON()
        return categoryFilter
    }
    
    // POST /
    // Create category filter
    func createFilter(req: Request) throws -> ResponseRepresentable {
        let categoryFilter = try req.categoryFilter()
        try categoryFilter.save()
        return categoryFilter
    }
    
    // DELETE /:id
    // Delete category filter with id
    func deleteFilter(req: Request) throws -> ResponseRepresentable {
        let categoryFilter = try req.parameters.next(CategoryFilter.self)
        try categoryFilter.delete()
        return Response(status: .ok)
    }
    
    // PATCH /:id
    // Update category filter
    func updateFilter(req: Request) throws -> ResponseRepresentable {
        let categoryFilter = try req.parameters.next(CategoryFilter.self)
        try categoryFilter.update(for: req)
        try categoryFilter.save()
        return categoryFilter
    }
    
    // GET /category/:id
    // Get all category filters for category
    func getAllFiltersForCategory(req: Request) throws -> ResponseRepresentable {
        let category = try req.parameters.next(Category.self)
        
        return try CategoryFilter.makeQuery().filter(CategoryFilter.categoryIdKey, .equals, category.id).all().makeJSON()
    }
}

// Deserialize JSON
extension Request {
    func categoryFilter() throws -> CategoryFilter {
        guard let json = json else { throw Abort.badRequest }
        return try CategoryFilter(json: json)
    }
}

extension CategoryFilterController: EmptyInitializable { }
