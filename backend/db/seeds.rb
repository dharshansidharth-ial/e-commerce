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
    { name: "Galaxy A54 5G", description: "6.4\" AMOLED display, 5000mAh battery, 128GB storage.", price: 28_999, stock: 25, discount: 12.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Back_of_the_Samsung_Galaxy_A54_5G.jpg/960px-Back_of_the_Samsung_Galaxy_A54_5G.jpg" },
    { name: "Pixel 8", description: "Google Tensor G3, 6.2\" OLED, AI-powered camera.", price: 54_999, stock: 12, discount: 8.5, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Google_Pixel_8_Rose_rear_bottom-left.jpg/960px-Google_Pixel_8_Rose_rear_bottom-left.jpg" },
    { name: "iPhone 13", description: "A15 Bionic chip, dual-camera system, 128GB.", price: 52_999, stock: 0, discount: 15.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/IPhone_13.jpg/960px-IPhone_13.jpg" },
  ],
  "Laptops" => [
    { name: "ThinkPad E14", description: "Intel i5, 16GB RAM, 512GB SSD, 14\" FHD display.", price: 56_999, stock: 10, discount: 10.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Lenovo_ThinkPad_T14_%2850379777211%29.jpg/960px-Lenovo_ThinkPad_T14_%2850379777211%29.jpg" },
    { name: "MacBook Air M2", description: "Apple M2 chip, 8GB RAM, 256GB SSD, all-day battery.", price: 99_999, stock: 6, discount: 5.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/M2_Macbook_Air_Starlight_model.jpg/960px-M2_Macbook_Air_Starlight_model.jpg" },
  ],
  "Men's Wear" => [
    { name: "Classic Fit Shirt", description: "100% cotton, breathable and easy to iron.", price: 1_299, stock: 40, discount: 20.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/6/68/White_collar_blue_striped_shirt.jpg" },
    { name: "Slim Fit Jeans", description: "Stretch denim, mid-rise, machine washable.", price: 1_799, stock: 35, discount: 25.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/7/76/Skinny_jeans_05.jpg" },
  ],
  "Women's Wear" => [
    { name: "Floral Summer Dress", description: "Lightweight rayon, knee-length, floral print.", price: 1_499, stock: 30, discount: 30.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Smiling_woman_wearing_floral_dress.jpg/960px-Smiling_woman_wearing_floral_dress.jpg" },
    { name: "Cotton Kurti", description: "Soft cotton, three-quarter sleeves, everyday wear.", price: 899, stock: 50, discount: 18.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Ladies_kurta_green.jpg/960px-Ladies_kurta_green.jpg" },
  ],
  "Fruits & Vegetables" => [
    { name: "Fresh Bananas (1kg)", description: "Farm-fresh, naturally ripened bananas.", price: 49, stock: 100, discount: 0.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/7/71/A_bunch_of_bananas.jpg" },
    { name: "Organic Tomatoes (1kg)", description: "Pesticide-free, vine-ripened tomatoes.", price: 39, stock: 80, discount: 5.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Tomatoes.jpg/960px-Tomatoes.jpg" },
  ],
  "Beverages" => [
    { name: "Green Tea (100 bags)", description: "Antioxidant-rich green tea, resealable pack.", price: 249, stock: 60, discount: 10.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Canister_with_bags_of_green_tea.jpg/960px-Canister_with_bags_of_green_tea.jpg" },
    { name: "Cold Brew Coffee (500ml)", description: "Slow-steeped, smooth and low-acid.", price: 199, stock: 45, discount: 15.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Iced_cold_brew_coffee.jpg/960px-Iced_cold_brew_coffee.jpg" },
  ],
  "Breads" => [
    { name: "Whole Wheat Bread", description: "Freshly baked, no preservatives, 400g loaf.", price: 59, stock: 70, discount: 0.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Whole_grain_bread.jpg/960px-Whole_grain_bread.jpg" },
    { name: "Multigrain Bread", description: "Blend of seven grains, high in fiber.", price: 69, stock: 55, discount: 8.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Multigrain_bread.JPG/960px-Multigrain_bread.JPG" },
  ],
  "Cakes" => [
    { name: "Chocolate Truffle Cake (500g)", description: "Rich Belgian chocolate, layered truffle filling.", price: 499, stock: 20, discount: 22.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Schubert%27s_Bakery_Chocolate_Truffle_Torte_Cake_%2822702744093%29.jpg/960px-Schubert%27s_Bakery_Chocolate_Truffle_Torte_Cake_%2822702744093%29.jpg" },
    { name: "Red Velvet Cupcakes (Pack of 6)", description: "Classic red velvet with cream cheese frosting.", price: 349, stock: 25, discount: 35.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Red_Velvet_Cupcakes.jpg/960px-Red_Velvet_Cupcakes.jpg" },
  ],
}

product_seeds.each do |sub_name, products|
  sub_category = Catalog::SubCategory.find_by(name: sub_name)
  next unless sub_category

  products.each do |attrs|
    product = Catalog::Product.find_or_initialize_by(name: attrs[:name])

    if product.new_record?
      product.description = attrs[:description]
      product.price = attrs[:price]
      product.stock = attrs[:stock]
      product.active = true
      product.catalog_sub_categories_id = sub_category.id
      product.seller_id = seller&.id
    end

    # Backfill discount/image_url even on already-seeded products.
    product.discount = attrs[:discount]
    product.image_url = attrs[:image_url]

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
