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
  "Home & Kitchen" => "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Modern_kitchen_and_dining_area_with_stylish_furnishings_and_natural_light_in_a_contemporary_home_setting.jpg/960px-Modern_kitchen_and_dining_area_with_stylish_furnishings_and_natural_light_in_a_contemporary_home_setting.jpg",
  "Sports & Fitness" => "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Attractive_man_lifting_dumbbell_weight_for_exercise_in_fitness_gym.jpg/960px-Attractive_man_lifting_dumbbell_weight_for_exercise_in_fitness_gym.jpg",
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
  "Home & Kitchen" => ["Kitchen Appliances", "Home Decor"],
  "Sports & Fitness" => ["Fitness Equipment", "Sportswear"],
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

# Builds an array of product-attrs hashes (matching the `{ name:, description:,
# price:, stock:, discount:, image_url: }` shape the seeding loop below expects)
# from a list of [name, description] pairs. Price is spread linearly between
# price_min/price_max across the list; stock and discount cycle through fixed,
# varied sequences (including some zero-stock entries) so re-running db:seed
# stays deterministic instead of relying on `rand`. image_url cycles through
# the given pool of pre-verified image URLs.
def build_products(items, price_min:, price_max:, images:)
  stock_cycle = [0, 12, 25, 40, 55, 70, 8, 0, 33, 18, 47, 5, 60, 90, 15]
  discount_cycle = [0.0, 5.0, 10.0, 12.5, 15.0, 18.0, 20.0, 22.5, 25.0, 28.0, 30.0, 33.0, 35.0, 38.0, 40.0]
  step = items.size > 1 ? (price_max - price_min).to_f / (items.size - 1) : 0

  items.each_with_index.map do |(name, description), i|
    {
      name: name,
      description: description,
      price: (price_min + step * i).round,
      stock: stock_cycle[i % stock_cycle.size],
      discount: discount_cycle[i % discount_cycle.size],
      image_url: images[i % images.size],
    }
  end
end

mobiles_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Blackview_A60_Smartphone_Android_mobile_phone_and_folio_case.jpg/960px-Blackview_A60_Smartphone_Android_mobile_phone_and_folio_case.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Blackview_A60_Smartphone_Android_mobile_phone_back_face.jpg/960px-Blackview_A60_Smartphone_Android_mobile_phone_back_face.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Blackview_A60_Smartphone_Android_mobile_phone_front_face_lock_screen.jpg/960px-Blackview_A60_Smartphone_Android_mobile_phone_front_face_lock_screen.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/EMOBILE_LTE_phone_in_Japan.jpg/960px-EMOBILE_LTE_phone_in_Japan.jpg",
]

laptops_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/HP_Pavilion_Computer_laptop_keyboard_closeup.jpg/960px-HP_Pavilion_Computer_laptop_keyboard_closeup.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/IBM_Thinkpad_R51.jpg/960px-IBM_Thinkpad_R51.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Laptop%2C_Small_notebook%2C_Netbook%2C_Rostov-on-Don%2C_Russia.jpg/960px-Laptop%2C_Small_notebook%2C_Netbook%2C_Rostov-on-Don%2C_Russia.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/6/63/Laptop-2411303_960_720.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/3/39/Laptop-coaster.jpg",
]

mens_wear_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/African-American_man_wearing_fedora.jpg/960px-African-American_man_wearing_fedora.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/0/00/Arrow_shirt_1920s.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/e/e9/Man_wearing_green_shirt-jacket%2C_blue_jeans_and_desert_boots_01.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Fashion_for_occasions_from_1976_%28JOKAOM14AiD_MUO16-1%29.tif/lossy-page1-960px-Fashion_for_occasions_from_1976_%28JOKAOM14AiD_MUO16-1%29.tif.jpg",
]

womens_wear_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Blond_woman_in_coloured_dress_on_the_beach.jpg/960px-Blond_woman_in_coloured_dress_on_the_beach.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/2/2d/Blond_woman_on_a_coloured_dress_on_the_beach.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Model_at_the_Spring_Fling_Fashion_Show_%28IMG_4749a%29_%285647669348%29.jpg/960px-Model_at_the_Spring_Fling_Fashion_Show_%28IMG_4749a%29_%285647669348%29.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Model_at_the_Spring_Fling_Fashion_Show_%28IMG_4750a%29_%285647672028%29.jpg/960px-Model_at_the_Spring_Fling_Fashion_Show_%28IMG_4750a%29_%285647672028%29.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Model_at_the_Spring_Fling_Fashion_Show_%28IMG_4753a%29_%285647791562%29.jpg/960px-Model_at_the_Spring_Fling_Fashion_Show_%28IMG_4753a%29_%285647791562%29.jpg",
]

fruits_veg_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Coop_-_fruits_and_vegetables.jpg/960px-Coop_-_fruits_and_vegetables.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/DSCF1116_Fresh_root_vegetables_piled_at_a_bustling_market_stall_with_fruits_and_produce_blurred_in_the_colorful_background.jpg/960px-DSCF1116_Fresh_root_vegetables_piled_at_a_bustling_market_stall_with_fruits_and_produce_blurred_in_the_colorful_background.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Draeger%27s_Market_San_Mateo_fruits.jpg/960px-Draeger%27s_Market_San_Mateo_fruits.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Draeger%27s_Market_San_Mateo_vegetables.jpg/960px-Draeger%27s_Market_San_Mateo_vegetables.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Fresh_Vegetables_And_Fruits_Market_Booth_%28224148317%29.jpeg/960px-Fresh_Vegetables_And_Fruits_Market_Booth_%28224148317%29.jpeg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Fresh_fruits_and_vegetables_at_a_local_market_in_Kilimanjaro_Region%2C_Tanzania.jpg/960px-Fresh_fruits_and_vegetables_at_a_local_market_in_Kilimanjaro_Region%2C_Tanzania.jpg",
]

beverages_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Soft_drinks_800x600.jpg/960px-Soft_drinks_800x600.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Classic_glass_bottle_of_T%C5%99eb%C3%AD%C4%8D_ZON_apple_lemonade_in_T%C5%99eb%C3%AD%C4%8D%2C_T%C5%99eb%C3%AD%C4%8D_District.jpg/960px-Classic_glass_bottle_of_T%C5%99eb%C3%AD%C4%8D_ZON_apple_lemonade_in_T%C5%99eb%C3%AD%C4%8D%2C_T%C5%99eb%C3%AD%C4%8D_District.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Coca_Cola_Beverages_Northeast.jpg/960px-Coca_Cola_Beverages_Northeast.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Frugo_drinks_3.jpg/960px-Frugo_drinks_3.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/4/4e/HK_Soft_drink_pre-packed_plastic_bottles_Lemon-Lime_Gatorade_July_2017_IX1.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/c/c1/HK_Soft_drink_pre-packed_plastic_bottles_Orange_Chill_Gatorade_July_2017_IX1_%281%29.jpg",
]

breads_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Fresh_made_bread_05.jpg/960px-Fresh_made_bread_05.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Fresh_made_bread_06.jpg/960px-Fresh_made_bread_06.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/9472Cuisine_of_Bulacan_04.jpg/960px-9472Cuisine_of_Bulacan_04.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/HK_CWB_Yee_Wo_Street_%E5%A4%A7%E7%8F%AD%E9%BA%B5%E5%8C%85%E8%A5%BF%E9%A4%85_TaiPan_bakery_breads_Sandwich_plastic_bag_pre-packed_food_Nutrition_Information_Sept-2013_San_Po_Kong_LHIB.JPG/960px-HK_CWB_Yee_Wo_Street_%E5%A4%A7%E7%8F%AD%E9%BA%B5%E5%8C%85%E8%A5%BF%E9%A4%85_TaiPan_bakery_breads_Sandwich_plastic_bag_pre-packed_food_Nutrition_Information_Sept-2013_San_Po_Kong_LHIB.JPG",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/HK_YL_%E5%85%83%E6%9C%97_Yuen_Long_%E5%8F%88%E6%96%B0%E8%A1%97_Yau_San_Street_shop_Garden_Bread_white_sandwich_June_2018_IX2.jpg/960px-HK_YL_%E5%85%83%E6%9C%97_Yuen_Long_%E5%8F%88%E6%96%B0%E8%A1%97_Yau_San_Street_shop_Garden_Bread_white_sandwich_June_2018_IX2.jpg",
]

cakes_extra_images = [
  "https://upload.wikimedia.org/wikipedia/commons/5/59/Birthday_Cake_by_Grushetski.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Birthday_Cake_with_Red_Strawberry.jpg/960px-Birthday_Cake_with_Red_Strawberry.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Birthday_cake-95.JPG/960px-Birthday_cake-95.JPG",
]

kitchen_appliances_images = [
  "https://upload.wikimedia.org/wikipedia/commons/8/81/Banquet_range_%28kitchen_appliance%2C_1903%29.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Breville.jpg/960px-Breville.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Caso_SMG20_-_Guangdong_Midea_Kitchen_Appliances_Manufacturing_MDT-10CEF-0177.jpg/960px-Caso_SMG20_-_Guangdong_Midea_Kitchen_Appliances_Manufacturing_MDT-10CEF-0177.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Home_appliance_in_iran.jpg/960px-Home_appliance_in_iran.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/7/7b/Kitchen_Appliances_Illustration.png",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Kitchen_Layout_2.jpg/960px-Kitchen_Layout_2.jpg",
]

home_decor_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Luxury_Living_Room_Interior_Design_in_Kolkata_by_Estate_Lookup_Interiors.png/960px-Luxury_Living_Room_Interior_Design_in_Kolkata_by_Estate_Lookup_Interiors.png",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Modern_kitchen_and_dining_area_with_stylish_furnishings_and_natural_light_in_a_contemporary_home_setting.jpg/960px-Modern_kitchen_and_dining_area_with_stylish_furnishings_and_natural_light_in_a_contemporary_home_setting.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Ohio_History_Center_75.jpg/960px-Ohio_History_Center_75.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Everything_for_the_garden_%2816205267207%29.jpg/960px-Everything_for_the_garden_%2816205267207%29.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/StateLibQld_2_15910_Breakfast_room_in_a_home_featured_in_a_magazine_in_1906.jpg/960px-StateLibQld_2_15910_Breakfast_room_in_a_home_featured_in_a_magazine_in_1906.jpg",
]

fitness_equipment_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Attractive_man_lifting_dumbbell_weight_for_exercise_in_fitness_gym.jpg/960px-Attractive_man_lifting_dumbbell_weight_for_exercise_in_fitness_gym.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/6/6c/Dumbbell_weighted_jumps_1.png",
  "https://upload.wikimedia.org/wikipedia/commons/d/d9/Dumbbell_weighted_jumps_2.png",
  "https://upload.wikimedia.org/wikipedia/commons/4/4f/Dumbbell_weighted_jumps_A1.png",
  "https://upload.wikimedia.org/wikipedia/commons/4/44/Dumbbell_weighted_jumps_A2.png",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/USMC-18271.jpg/960px-USMC-18271.jpg",
]

sportswear_images = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/CrystaRunning.jpg/960px-CrystaRunning.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/ECCO_BIOM_running_shoe.jpg/960px-ECCO_BIOM_running_shoe.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/ECCO_BIOM_running_shoe_-_Trail.jpg/960px-ECCO_BIOM_running_shoe_-_Trail.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/FORUS_Red_Line_EVOGHOST_1.1.jpg/960px-FORUS_Red_Line_EVOGHOST_1.1.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Harajuku_lovers_hi-top_2008.jpg/960px-Harajuku_lovers_hi-top_2008.jpg",
  "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Newton_Gravity_Running_Shoes.jpg/960px-Newton_Gravity_Running_Shoes.jpg",
]

extra_mobiles = build_products(
  [
    ["Galaxy S23 Ultra", "6.8\" QHD+ Dynamic AMOLED, S Pen, 200MP camera."],
    ["iPhone 15", "A16 Bionic chip, USB-C, Dynamic Island, 128GB."],
    ["OnePlus 12R", "Snapdragon 8 Gen 2, 100W SUPERVOOC fast charging."],
    ["Redmi Note 13 Pro", "200MP OIS camera, curved AMOLED, 67W turbo charging."],
    ["Moto G84 5G", "pOLED display, Gorilla Glass, 5000mAh battery."],
    ["Realme Narzo 60", "Sunlight-visible display, 33W fast charge, 128GB storage."],
    ["Nothing Phone (2)", "Glyph interface, Snapdragon 8+ Gen 1, transparent design."],
    ["Vivo V29", "Aura light portrait, curved AMOLED, 50MP selfie camera."],
    ["Oppo Reno 10", "Portrait Expert camera, 67W SuperVOOC charging."],
    ["iPhone SE (2022)", "A15 Bionic chip, compact 4.7\" design, Touch ID."],
    ["Samsung Galaxy Z Flip5", "Foldable design, Flex Window cover display."],
    ["Poco X6 Pro", "Dimensity chipset, 6.67\" AMOLED, 64MP camera."],
  ],
  price_min: 13_999, price_max: 89_999, images: mobiles_extra_images,
)

extra_laptops = build_products(
  [
    ["Dell XPS 13", "13.4\" InfinityEdge display, Intel Evo platform, 16GB RAM."],
    ["HP Pavilion 15", "AMD Ryzen 5, 8GB RAM, 512GB SSD, full-HD display."],
    ["Acer Aspire 7", "Intel i5 12th gen, dedicated graphics, 16GB RAM."],
    ["ASUS ROG Strix G15", "144Hz display, RTX graphics, RGB backlit keyboard."],
    ["Lenovo IdeaPad Slim 5", "Ryzen 7, 16GB RAM, 512GB SSD, lightweight chassis."],
    ["MacBook Pro 14 M3", "Apple M3 chip, Liquid Retina XDR display, 18GB RAM."],
    ["Dell Inspiron 15", "Intel i3, 8GB RAM, 512GB SSD, everyday computing."],
    ["HP Spectre x360", "2-in-1 convertible, OLED touch display, 16GB RAM."],
    ["Acer Swift 3", "Ultra-slim design, Intel i5, all-day battery life."],
    ["ASUS Vivobook 15", "Intel i5, 8GB RAM, 512GB SSD, NumberPad."],
    ["Lenovo Legion 5", "Ryzen 7, RTX graphics, 165Hz gaming display."],
    ["MSI Modern 14", "Intel i5, thin bezel display, backlit keyboard."],
    ["Microsoft Surface Laptop 5", "Intel i5, touchscreen, aluminium chassis."],
  ],
  price_min: 32_999, price_max: 134_999, images: laptops_extra_images,
)

extra_mens_wear = build_products(
  [
    ["Formal Blazer", "Tailored fit, poly-viscose blend, office wear."],
    ["Casual Polo T-Shirt", "Pique cotton, ribbed collar, regular fit."],
    ["Denim Jacket", "Washed denim, button-front, unlined casual jacket."],
    ["Cotton Cargo Pants", "Multi-pocket utility fit, breathable cotton twill."],
    ["Checked Flannel Shirt", "Brushed cotton flannel, full sleeves, warm fit."],
    ["Leather Belt", "Genuine leather, pin buckle, formal & casual use."],
    ["Track Pants", "Elasticated waistband, moisture-wicking fabric."],
    ["Sports T-Shirt", "Quick-dry polyester, breathable mesh panels."],
    ["Linen Shirt", "Pure linen, breathable weave, summer wear."],
    ["Chino Trousers", "Slim tapered fit, stretch cotton twill."],
    ["Hooded Sweatshirt", "Fleece-lined hoodie, kangaroo pocket."],
    ["Nehru Jacket", "Ethnic wear, mandarin collar, festive occasions."],
    ["Formal Trousers", "Wrinkle-resistant, flat-front, office wear."],
  ],
  price_min: 599, price_max: 2_499, images: mens_wear_extra_images,
)

extra_womens_wear = build_products(
  [
    ["Palazzo Pants", "Wide-leg, flowy rayon, elastic waistband."],
    ["Anarkali Suit", "Embroidered yoke, flared silhouette, festive wear."],
    ["Denim Jacket for Women", "Cropped fit, washed denim, button-front."],
    ["Printed Maxi Dress", "Floor-length, floral print, flutter sleeves."],
    ["Silk Saree", "Handwoven silk, zari border, traditional drape."],
    ["Formal Blazer for Women", "Tailored fit, office wear, poly-blend."],
    ["Casual Jumpsuit", "Sleeveless, belted waist, everyday comfort."],
    ["Georgette Saree", "Lightweight georgette, sequin work, party wear."],
    ["Straight Fit Trousers", "High-rise, stretch fabric, office wear."],
    ["Woolen Cardigan", "Ribbed knit, button-front, winter layering."],
    ["Off-Shoulder Top", "Elasticated neckline, ruffle sleeves, casual wear."],
    ["Palazzo Suit Set", "Kurta with palazzo pants, printed cotton set."],
    ["Chiffon Dupatta Set", "Embroidered chiffon, matching suit set."],
  ],
  price_min: 699, price_max: 2_999, images: womens_wear_extra_images,
)

extra_fruits_veg = build_products(
  [
    ["Fresh Apples (1kg)", "Crisp and juicy, hand-picked, farm-fresh apples."],
    ["Green Grapes (500g)", "Seedless, sweet green grapes, washed and ready."],
    ["Fresh Oranges (1kg)", "Juicy citrus oranges, rich in vitamin C."],
    ["Pomegranate (1kg)", "Ruby-red arils, antioxidant-rich, farm-fresh."],
    ["Fresh Spinach (250g)", "Tender leafy greens, pesticide-free."],
    ["Carrots (1kg)", "Crunchy, farm-fresh orange carrots."],
    ["Potatoes (1kg)", "Farm-fresh potatoes, ideal for everyday cooking."],
    ["Onions (1kg)", "Fresh red onions, essential kitchen staple."],
    ["Cucumber (500g)", "Crisp and hydrating, farm-fresh cucumbers."],
    ["Bell Peppers (500g)", "Mixed colour capsicum, crunchy and fresh."],
    ["Broccoli (500g)", "Fresh green broccoli florets, nutrient-rich."],
    ["Sweet Corn (500g)", "Tender sweet corn kernels, farm-fresh."],
    ["Fresh Mangoes (1kg)", "Ripe and juicy seasonal mangoes."],
  ],
  price_min: 29, price_max: 249, images: fruits_veg_extra_images,
)

extra_beverages = build_products(
  [
    ["Orange Juice (1L)", "100% pure, no added sugar, chilled orange juice."],
    ["Mixed Fruit Juice (1L)", "Blend of seasonal fruits, no preservatives."],
    ["Masala Chai (250g)", "Aromatic blend of tea leaves and spices."],
    ["Instant Coffee (200g)", "Rich roasted instant coffee granules."],
    ["Buttermilk (500ml)", "Spiced and churned, cooling probiotic drink."],
    ["Coconut Water (1L)", "Natural electrolytes, tender coconut water."],
    ["Lemonade (500ml)", "Refreshing sweet and tangy citrus drink."],
    ["Sparkling Water (750ml)", "Naturally carbonated, zero sugar."],
    ["Energy Drink (250ml)", "Caffeine-boosted, refreshing energy drink."],
    ["Hot Chocolate Mix (400g)", "Rich cocoa blend, instant hot chocolate."],
    ["Herbal Tea (100 bags)", "Caffeine-free herbal infusion, resealable pack."],
    ["Mango Shake (500ml)", "Creamy blended mango and milk shake."],
    ["Rose Milk (500ml)", "Chilled rose-flavoured sweetened milk."],
  ],
  price_min: 39, price_max: 349, images: beverages_extra_images,
)

extra_breads = build_products(
  [
    ["Garlic Bread", "Buttery garlic and herb topped bread loaf."],
    ["Sourdough Loaf", "Naturally leavened, tangy artisan sourdough."],
    ["Brown Bread", "Whole wheat brown bread, soft and fibrous."],
    ["Bread Rolls (Pack of 6)", "Soft dinner rolls, freshly baked."],
    ["Focaccia Bread", "Olive oil and rosemary Italian flatbread."],
    ["Rye Bread", "Dense and hearty, traditional rye loaf."],
    ["Burger Buns (Pack of 4)", "Soft sesame-topped buns, freshly baked."],
    ["Sandwich Bread (White)", "Soft white bread, ideal for sandwiches."],
    ["Ciabatta Bread", "Crusty Italian loaf with an airy crumb."],
    ["Oats Bread", "High-fibre bread with rolled oats topping."],
    ["Milk Bread Loaf", "Soft and fluffy, enriched with milk."],
    ["French Baguette", "Crisp crust, classic long French loaf."],
    ["Pav Buns (Pack of 6)", "Soft, pillowy buns, ideal for pav bhaji."],
  ],
  price_min: 39, price_max: 229, images: breads_extra_images,
)

extra_cakes = build_products(
  [
    ["Black Forest Cake (500g)", "Chocolate sponge, whipped cream, cherries."],
    ["Vanilla Sponge Cake (500g)", "Light and fluffy classic vanilla sponge."],
    ["Butterscotch Cake (500g)", "Caramelised butterscotch crunch and cream."],
    ["Pineapple Cake (500g)", "Fresh pineapple chunks, whipped cream frosting."],
    ["Blueberry Cheesecake (500g)", "Creamy cheesecake topped with blueberry compote."],
    ["Fruit Cake (500g)", "Mixed dried fruits and nuts, rich sponge."],
    ["Rainbow Cake (500g)", "Layered colourful sponge, vanilla frosting."],
    ["Coffee Walnut Cake (500g)", "Coffee-infused sponge with walnut crunch."],
    ["Chocolate Chip Muffins (Pack of 6)", "Soft muffins loaded with chocolate chips."],
    ["Vanilla Cupcakes (Pack of 6)", "Classic vanilla cupcakes, buttercream swirl."],
    ["Cookies and Cream Cake (500g)", "Vanilla sponge with crushed cookie crumble."],
    ["Mango Mousse Cake (500g)", "Light mango mousse over sponge base."],
    ["Dry Fruit Cake (500g)", "Rich sponge loaded with assorted dry fruits."],
  ],
  price_min: 329, price_max: 899, images: cakes_extra_images,
)

kitchen_appliances_seeds = build_products(
  [
    ["Electric Kettle 1.5L", "Auto shut-off, stainless steel, rapid boiling."],
    ["Stand Mixer 500W", "Multi-speed mixing, stainless steel bowl."],
    ["Air Fryer 4L", "Oil-free frying, digital touch panel, 4L basket."],
    ["Induction Cooktop", "Touch control, auto-pan detection, energy efficient."],
    ["Microwave Oven 20L", "Solo microwave, 5 power levels, defrost function."],
    ["Toaster 2-Slice", "Browning control, removable crumb tray."],
    ["Mixer Grinder 750W", "3 stainless steel jars, powerful copper motor."],
    ["Electric Rice Cooker 1.8L", "Keep-warm function, non-stick inner pot."],
    ["Hand Blender 300W", "Detachable stem, multiple speed settings."],
    ["Sandwich Maker", "Non-stick plates, indicator lights, compact design."],
    ["Juicer Mixer Grinder", "550W motor, 3 jars, centrifugal juicing."],
    ["Slow Cooker 3.5L", "Ceramic pot, 3 heat settings, glass lid."],
    ["OTG Oven 30L", "Convection baking, rotisserie, 6 heating modes."],
    ["Water Purifier RO+UV", "7-stage purification, mineral cartridge."],
    ["Coffee Maker Drip Machine", "Programmable timer, 12-cup glass carafe."],
  ],
  price_min: 799, price_max: 15_999, images: kitchen_appliances_images,
)

home_decor_seeds = build_products(
  [
    ["Wall Clock Round", "Silent sweep movement, minimalist wooden frame."],
    ["Ceramic Flower Vase", "Handcrafted ceramic, glossy glazed finish."],
    ["Table Lamp", "Fabric shade, warm ambient lighting, bedside decor."],
    ["Wall Art Canvas Print", "Gallery-wrapped canvas, ready to hang."],
    ["Scented Candle Set", "Set of 3 aromatherapy soy wax candles."],
    ["Decorative Cushion Covers (Set of 5)", "Printed cotton blend, zipper closure."],
    ["Wooden Photo Frame", "Solid wood frame, tabletop or wall mount."],
    ["Artificial Plant with Pot", "Realistic faux foliage, ceramic pot included."],
    ["Wall Mirror Decorative", "Sunburst design, metal frame, entryway decor."],
    ["Rangoli Diya Set", "Hand-painted terracotta diyas, festive decor."],
    ["Fairy Lights (10m)", "Warm white LED string lights, USB powered."],
    ["Area Rug 5x7", "Machine-woven, soft pile, living room rug."],
    ["Wall Hanging Tapestry", "Bohemian print, lightweight cotton fabric."],
    ["Windchime", "Metal tubes, soothing tones, garden or balcony decor."],
    ["Table Runner", "Jacquard weave, dining table centrepiece."],
  ],
  price_min: 199, price_max: 4_999, images: home_decor_images,
)

fitness_equipment_seeds = build_products(
  [
    ["Adjustable Dumbbell Set", "Quick-lock plates, 2.5kg to 24kg range."],
    ["Yoga Mat 6mm", "Non-slip texture, extra cushioning, carry strap."],
    ["Resistance Bands Set", "5 resistance levels, latex bands with handles."],
    ["Skipping Rope", "Adjustable length, ball-bearing handles."],
    ["Foam Roller", "High-density EVA foam, muscle recovery."],
    ["Kettlebell 8kg", "Cast iron, vinyl-coated, wide handle grip."],
    ["Treadmill Foldable", "Motorised, foldable deck, speed up to 12km/h."],
    ["Exercise Bike Stationary", "Adjustable resistance, LCD tracking display."],
    ["Pull-Up Bar Doorway", "No-drill installation, adjustable width."],
    ["Gym Gloves Pair", "Padded palm, breathable mesh back, wrist support."],
    ["Ab Roller Wheel", "Dual wheels, foam grip handles, core workout."],
    ["Push-Up Bars", "Non-slip rubber base, ergonomic foam grips."],
    ["Barbell Rod 5ft", "Chrome-plated steel, standard 1-inch spinlock."],
    ["Weight Plates Set 10kg", "Rubber-coated cast iron, spinlock compatible."],
    ["Yoga Block Set", "High-density foam, set of 2 with strap."],
  ],
  price_min: 349, price_max: 24_999, images: fitness_equipment_images,
)

sportswear_seeds = build_products(
  [
    ["Men's Running Shoes", "Breathable mesh upper, cushioned midsole."],
    ["Women's Training Shoes", "Lightweight support, non-marking outsole."],
    ["Dry-Fit Sports T-Shirt", "Moisture-wicking fabric, tagless comfort."],
    ["Track Suit Set", "Jacket and joggers, ribbed cuffs, zip pockets."],
    ["Compression Leggings", "4-way stretch, high-waist, squat-proof fabric."],
    ["Sports Bra", "Medium support, racerback design, breathable mesh."],
    ["Cycling Shorts", "Padded chamois, aerodynamic compression fit."],
    ["Gym Tank Top", "Sleeveless, quick-dry, breathable racerback."],
    ["Football Jersey", "Lightweight polyester, breathable mesh panels."],
    ["Cricket Jersey", "Moisture-wicking, collared sports jersey."],
    ["Badminton T-Shirt", "Quick-dry polyester, lightweight athletic fit."],
    ["Sports Socks (Pack of 3)", "Cushioned sole, arch support, breathable."],
    ["Windcheater Jacket", "Water-resistant shell, packable running jacket."],
    ["Swim Trunks", "Quick-dry fabric, elastic waistband, mesh lining."],
    ["Sports Cap", "Adjustable strap, moisture-wicking sweatband."],
  ],
  price_min: 399, price_max: 3_499, images: sportswear_images,
)

product_seeds = {
  "Mobiles" => [
    { name: "Galaxy A54 5G", description: "6.4\" AMOLED display, 5000mAh battery, 128GB storage.", price: 28_999, stock: 25, discount: 12.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Back_of_the_Samsung_Galaxy_A54_5G.jpg/960px-Back_of_the_Samsung_Galaxy_A54_5G.jpg" },
    { name: "Pixel 8", description: "Google Tensor G3, 6.2\" OLED, AI-powered camera.", price: 54_999, stock: 12, discount: 8.5, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Google_Pixel_8_Rose_rear_bottom-left.jpg/960px-Google_Pixel_8_Rose_rear_bottom-left.jpg" },
    { name: "iPhone 13", description: "A15 Bionic chip, dual-camera system, 128GB.", price: 52_999, stock: 0, discount: 15.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/IPhone_13.jpg/960px-IPhone_13.jpg" },
  ] + extra_mobiles,
  "Laptops" => [
    { name: "ThinkPad E14", description: "Intel i5, 16GB RAM, 512GB SSD, 14\" FHD display.", price: 56_999, stock: 10, discount: 10.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Lenovo_ThinkPad_T14_%2850379777211%29.jpg/960px-Lenovo_ThinkPad_T14_%2850379777211%29.jpg" },
    { name: "MacBook Air M2", description: "Apple M2 chip, 8GB RAM, 256GB SSD, all-day battery.", price: 99_999, stock: 6, discount: 5.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/M2_Macbook_Air_Starlight_model.jpg/960px-M2_Macbook_Air_Starlight_model.jpg" },
  ] + extra_laptops,
  "Men's Wear" => [
    { name: "Classic Fit Shirt", description: "100% cotton, breathable and easy to iron.", price: 1_299, stock: 40, discount: 20.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/6/68/White_collar_blue_striped_shirt.jpg" },
    { name: "Slim Fit Jeans", description: "Stretch denim, mid-rise, machine washable.", price: 1_799, stock: 35, discount: 25.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/7/76/Skinny_jeans_05.jpg" },
  ] + extra_mens_wear,
  "Women's Wear" => [
    { name: "Floral Summer Dress", description: "Lightweight rayon, knee-length, floral print.", price: 1_499, stock: 30, discount: 30.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Smiling_woman_wearing_floral_dress.jpg/960px-Smiling_woman_wearing_floral_dress.jpg" },
    { name: "Cotton Kurti", description: "Soft cotton, three-quarter sleeves, everyday wear.", price: 899, stock: 50, discount: 18.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Ladies_kurta_green.jpg/960px-Ladies_kurta_green.jpg" },
  ] + extra_womens_wear,
  "Fruits & Vegetables" => [
    { name: "Fresh Bananas (1kg)", description: "Farm-fresh, naturally ripened bananas.", price: 49, stock: 100, discount: 0.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/7/71/A_bunch_of_bananas.jpg" },
    { name: "Organic Tomatoes (1kg)", description: "Pesticide-free, vine-ripened tomatoes.", price: 39, stock: 80, discount: 5.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Tomatoes.jpg/960px-Tomatoes.jpg" },
  ] + extra_fruits_veg,
  "Beverages" => [
    { name: "Green Tea (100 bags)", description: "Antioxidant-rich green tea, resealable pack.", price: 249, stock: 60, discount: 10.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Canister_with_bags_of_green_tea.jpg/960px-Canister_with_bags_of_green_tea.jpg" },
    { name: "Cold Brew Coffee (500ml)", description: "Slow-steeped, smooth and low-acid.", price: 199, stock: 45, discount: 15.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Iced_cold_brew_coffee.jpg/960px-Iced_cold_brew_coffee.jpg" },
  ] + extra_beverages,
  "Breads" => [
    { name: "Whole Wheat Bread", description: "Freshly baked, no preservatives, 400g loaf.", price: 59, stock: 70, discount: 0.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Whole_grain_bread.jpg/960px-Whole_grain_bread.jpg" },
    { name: "Multigrain Bread", description: "Blend of seven grains, high in fiber.", price: 69, stock: 55, discount: 8.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Multigrain_bread.JPG/960px-Multigrain_bread.JPG" },
  ] + extra_breads,
  "Cakes" => [
    { name: "Chocolate Truffle Cake (500g)", description: "Rich Belgian chocolate, layered truffle filling.", price: 499, stock: 20, discount: 22.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Schubert%27s_Bakery_Chocolate_Truffle_Torte_Cake_%2822702744093%29.jpg/960px-Schubert%27s_Bakery_Chocolate_Truffle_Torte_Cake_%2822702744093%29.jpg" },
    { name: "Red Velvet Cupcakes (Pack of 6)", description: "Classic red velvet with cream cheese frosting.", price: 349, stock: 25, discount: 35.0, image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Red_Velvet_Cupcakes.jpg/960px-Red_Velvet_Cupcakes.jpg" },
  ] + extra_cakes,
  "Kitchen Appliances" => kitchen_appliances_seeds,
  "Home Decor" => home_decor_seeds,
  "Fitness Equipment" => fitness_equipment_seeds,
  "Sportswear" => sportswear_seeds,
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
