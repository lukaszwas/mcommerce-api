import Vapor
import HTTP

// /products
final class ProductController {
    
    // Routes
    func makeRoutes(routes: RouteBuilder) {
        let group = routes.grouped("products")
        
        group.get(handler: getAllProducts)
        group.get(Product.parameter, handler: getProductWithId)
        group.post(handler: createProduct)
        group.delete(Product.parameter, handler: deleteProduct)
        group.patch(Product.parameter, handler: updateProduct)
        group.get("category", Category.parameter, handler: getProductsWithCategory)
        group.get("recommended", handler: getRecommendedProducts)
    }
    
    // METHODS
    
    // GET /
    // Get all products
    func getAllProducts(req: Request) throws -> ResponseRepresentable {
        return try Product.all().makeJSON()
    }
    
    // GET /:id
    // Get product with id
    func getProductWithId(req: Request) throws -> ResponseRepresentable {
        let product = try req.parameters.next(Product.self).makeJSONWithDetails()
        return product
    }

    // POST /
    // Create product
    func createProduct(req: Request) throws -> ResponseRepresentable {
        let product = try req.product()
        try product.save()
        return product
    }
    
    // DELETE /:id
    // Delete product with id
    func deleteProduct(req: Request) throws -> ResponseRepresentable {
        let product = try req.parameters.next(Product.self)
        try product.delete()
        return Response(status: .ok)
    }

    // PATCH /:id
    // Update product
    func updateProduct(req: Request) throws -> ResponseRepresentable {
        let product = try req.parameters.next(Product.self)
        try product.update(for: req)
        try product.save()
        return product
    }
    
    // GET /category/:id
    // Get products with category id
    func getProductsWithCategory(req: Request) throws -> ResponseRepresentable {
        let category = try req.parameters.next(Category.self)
        
        let childCategories = try Category.makeQuery().filter(Category.parentIdKey, .equals, category.id).all()
        
        var childCategoriesIds: [Int] = [(category.id?.int)!]
        
        for category in childCategories {
            childCategoriesIds.append((category.id?.int)!)
        }
        
        return try Product.makeQuery().or({ orGroup in
            for id in childCategoriesIds {
                try orGroup.filter(Product.categoryIdKey, id)
            }
        }).all().makeJSON()
    }
    
    // GET /recommended
    // Get recommended products
    func getRecommendedProducts(req: Request) throws -> ResponseRepresentable {
        let categories = try Category.makeQuery().join(kind: .inner, Product.self, baseKey: Category.idKey, joinedKey: Product.categoryIdKey).filter(Product.self, Product.recommendedKey, true).all()
        
        var categoriesJson: [JSON] = []
        
        for category in categories {
            categoriesJson.append(try category.makeJSONWithProducts())
        }
        
        var json = JSON()
        try json.set("recommended", categoriesJson)
        
        return json
    }
}

// Deserialize JSON
extension Request {
    func product() throws -> Product {
        guard let json = json else { throw Abort.badRequest }
        return try Product(json: json)
    }
}

extension ProductController: EmptyInitializable { }
