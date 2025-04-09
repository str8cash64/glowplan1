import SwiftUI

struct RecommendedView: View {
    let products = [
        Product(name: "Hydrating Cleanser", brand: "CeraVe", category: "Cleanser", price: "$15.99"),
        Product(name: "Vitamin C Serum", brand: "The Ordinary", category: "Serum", price: "$7.90"),
        Product(name: "SPF 30 Moisturizer", brand: "La Roche-Posay", category: "Moisturizer", price: "$19.99"),
        Product(name: "Retinol Night Cream", brand: "Neutrogena", category: "Night Cream", price: "$24.99")
    ]
    
    var body: some View {
        ZStack {
            Color.glowPink
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Recommended Products")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top)
                    
                    ForEach(products) { product in
                        productCard(product: product)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recommended")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func productCard(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(product.brand)
                .font(.headline)
                .foregroundColor(.glowCoral)
            
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(product.category)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text(product.price)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    // Add to routine
                }) {
                    Text("Add to Routine")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.glowCoral)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let category: String
    let price: String
} 