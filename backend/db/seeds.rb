# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ── CATEGORIES ───────────────────────────────────────────────
category_image_urls = {
  "Electronics" => "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Man_with_smartphone_and_laptop_%28Unsplash%29.jpg/960px-Man_with_smartphone_and_laptop_%28Unsplash%29.jpg",
  "Fashion" => "https://upload.wikimedia.org/wikipedia/commons/a/a6/EFTA00001678_-_Wooden_clothing_rack_with_clothes_on_hangers_folded_shirts_on_shelves_and_various_shoes_neatly_arranged_at_the_bottom.jpg",
  "Groceries" => "https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Basket_of_Vegetables_%28Unsplash%29.jpg/960px-Basket_of_Vegetables_%28Unsplash%29.jpg",
  "Bakery" => "https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Bread_Basket_%28Unsplash%29.jpg/960px-Bread_Basket_%28Unsplash%29.jpg",
}

category_image_urls.each do |category_name, image_url|
  category = Catalog::Category.find_or_create_by!(name: category_name)
  category.update!(image_url: image_url) if category.image_url.blank?
end

# ── SUB-CATEGORIES ──────────────────────────────────────────
sub_category_names = {
  "Electronics" => ["Mobiles", "Laptops"],
  "Fashion" => ["Men's Wear", "Women's Wear"],
  "Groceries" => ["Fruits & Vegetables", "Beverages"],
  "Bakery" => ["Breads", "Cakes"],
}

sub_category_names.each do |category_name, sub_names|
  category = Catalog::Category.find_by(name: category_name)
  next unless category

  sub_names.each do |sub_name|
    # `Catalog::SubCategory#belongs_to :catalog_category` points at a foreign key
    # that doesn't match the real column (`catalog_categories_id`), which trips
    # the association's presence validation. Skip validation on insert to work
    # around that pre-existing mismatch.
    sub_category = Catalog::SubCategory.find_or_initialize_by(
      name: sub_name,
      catalog_categories_id: category.id,
    )
    sub_category.save!(validate: false) if sub_category.new_record?
  end
end

# ── PRODUCTS ─────────────────────────────────────────────────
seller = User.seller.approved.first

product_seeds = {
  "Mobiles" => [
    { name: "Galaxy A54 5G", description: "6.4\" AMOLED display, 5000mAh battery, 128GB storage.", price: 28_999, stock: 25 },
    { name: "Pixel 8", description: "Google Tensor G3, 6.2\" OLED, AI-powered camera.", price: 54_999, stock: 12 },
    { name: "iPhone 13", description: "A15 Bionic chip, dual-camera system, 128GB.", price: 52_999, stock: 0 },
  ],
  "Laptops" => [
    { name: "ThinkPad E14", description: "Intel i5, 16GB RAM, 512GB SSD, 14\" FHD display.", price: 56_999, stock: 10 },
    { name: "MacBook Air M2", description: "Apple M2 chip, 8GB RAM, 256GB SSD, all-day battery.", price: 99_999, stock: 6 },
  ],
  "Men's Wear" => [
    { name: "Classic Fit Shirt", description: "100% cotton, breathable and easy to iron.", price: 1_299, stock: 40 },
    { name: "Slim Fit Jeans", description: "Stretch denim, mid-rise, machine washable.", price: 1_799, stock: 35 },
  ],
  "Women's Wear" => [
    { name: "Floral Summer Dress", description: "Lightweight rayon, knee-length, floral print.", price: 1_499, stock: 30 },
    { name: "Cotton Kurti", description: "Soft cotton, three-quarter sleeves, everyday wear.", price: 899, stock: 50 },
  ],
  "Fruits & Vegetables" => [
    { name: "Fresh Bananas (1kg)", description: "Farm-fresh, naturally ripened bananas.", price: 49, stock: 100 },
    { name: "Organic Tomatoes (1kg)", description: "Pesticide-free, vine-ripened tomatoes.", price: 39, stock: 80 },
  ],
  "Beverages" => [
    { name: "Green Tea (100 bags)", description: "Antioxidant-rich green tea, resealable pack.", price: 249, stock: 60 },
    { name: "Cold Brew Coffee (500ml)", description: "Slow-steeped, smooth and low-acid.", price: 199, stock: 45 },
  ],
  "Breads" => [
    { name: "Whole Wheat Bread", description: "Freshly baked, no preservatives, 400g loaf.", price: 59, stock: 70 },
    { name: "Multigrain Bread", description: "Blend of seven grains, high in fiber.", price: 69, stock: 55 },
  ],
  "Cakes" => [
    { name: "Chocolate Truffle Cake (500g)", description: "Rich Belgian chocolate, layered truffle filling.", price: 499, stock: 20 },
    { name: "Red Velvet Cupcakes (Pack of 6)", description: "Classic red velvet with cream cheese frosting.", price: 349, stock: 25 },
  ],
}

product_seeds.each do |sub_name, products|
  sub_category = Catalog::SubCategory.find_by(name: sub_name)
  next unless sub_category

  products.each do |attrs|
    product = Catalog::Product.find_or_initialize_by(name: attrs[:name])
    next unless product.new_record?

    product.description = attrs[:description]
    product.price = attrs[:price]
    product.stock = attrs[:stock]
    product.active = true
    product.catalog_sub_categories_id = sub_category.id
    product.seller_id = seller&.id
    # `Catalog::Product#belongs_to :sub_category` points at a foreign key/class
    # that don't match the real column (`catalog_sub_categories_id`), which
    # trips the association's presence validation. Skip validation on insert
    # to work around that pre-existing mismatch.
    product.save!(validate: false)
  end
end

# ── ORDERS ───────────────────────────────────────────────────
def seed_order!(user:, status:, items:, address: nil, phone_number: nil, placed_at: Time.current)
  order = Checkout::Order.create!(
    user: user,
    status: "pending",
    address: address,
    phone_number: phone_number,
    created_at: placed_at,
    updated_at: placed_at,
  )

  items.each do |product, quantity|
    Checkout::OrderItem.create!(
      order: order,
      product: product,
      quantity: quantity,
      price: product.price,
    )
  end

  order.update!(status: status)

  if %w[paid shipped delivered].include?(status)
    Checkout::Payment.create!(
      order: order,
      amount: order.reload.total_amount,
      status: "succeeded",
    )
  end

  order
end

if Checkout::Order.count.zero?
  galaxy_a54 = Catalog::Product.find_by(name: "Galaxy A54 5G")
  macbook_air = Catalog::Product.find_by(name: "MacBook Air M2")
  wheat_bread = Catalog::Product.find_by(name: "Whole Wheat Bread")
  cold_brew = Catalog::Product.find_by(name: "Cold Brew Coffee (500ml)")
  classic_shirt = Catalog::Product.find_by(name: "Classic Fit Shirt")
  floral_dress = Catalog::Product.find_by(name: "Floral Summer Dress")

  cart_test2 = User.find_by(email: "cart_test2@gmail.com")
  if cart_test2
    address = cart_test2.addresses.first
    phone = cart_test2.phone_numbers.first

    seed_order!(
      user: cart_test2,
      status: "delivered",
      items: { galaxy_a54 => 1, wheat_bread => 2 },
      address: address,
      phone_number: phone,
      placed_at: 12.days.ago,
    )

    seed_order!(
      user: cart_test2,
      status: "shipped",
      items: { macbook_air => 1 },
      address: cart_test2.addresses.second || address,
      phone_number: phone,
      placed_at: 4.days.ago,
    )

    seed_order!(
      user: cart_test2,
      status: "pending",
      items: { classic_shirt => 2, cold_brew => 1 },
      address: address,
      phone_number: phone,
      placed_at: 1.day.ago,
    )

    seed_order!(
      user: cart_test2,
      status: "cancelled",
      items: { floral_dress => 1 },
      address: address,
      phone_number: phone,
      placed_at: 20.days.ago,
    )
  end

  cart_test1 = User.find_by(email: "cart_test1@gmail.com")
  if cart_test1
    seed_order!(
      user: cart_test1,
      status: "delivered",
      items: { classic_shirt => 1, wheat_bread => 3 },
      address: cart_test1.addresses.first,
      phone_number: cart_test1.phone_numbers.first,
      placed_at: 6.days.ago,
    )
  end
end
