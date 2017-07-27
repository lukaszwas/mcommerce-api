import Vapor
import HTTP

// /products
final class ProductController: ResourceRepresentable {
    // GET /
    // Get all products
    func getAllProducts(req: Request) throws -> ResponseRepresentable {
        if !req.auth.isAuthenticated(User.self) {
            throw Abort.unauthorized
        }
        
        return try Product.all().makeJSON()
    }
    
    // GET /:id
    // Get product with id
    func getProductWithId(req: Request, product: Product) throws -> ResponseRepresentable {
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
    func deleteProduct(req: Request, product: Product) throws -> ResponseRepresentable {
        try product.delete()
        return Response(status: .ok)
    }

    // DELETE /
    // Delete all products
    func deleteAllProducts(req: Request) throws -> ResponseRepresentable {
        try Product.makeQuery().delete()
        return Response(status: .ok)
    }

    // PATCH /:id
    // Update product
    func update(req: Request, product: Product) throws -> ResponseRepresentable {
        try product.update(for: req)

        try product.save()
        return product
    }

    // Resource
    func makeResource() -> Resource<Product> {
        return Resource(
            index: getAllProducts,
            store: createProduct,
            show: getProductWithId,
            update: update,
            destroy: deleteProduct,
            clear: deleteAllProducts
        )
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
