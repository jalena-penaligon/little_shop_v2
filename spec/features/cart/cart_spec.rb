require 'rails_helper'

RSpec.describe 'cart page', type: :feature do
  context 'as a visitor or registered user' do
    describe 'when I visit my cart /cart and there are no items' do
      it 'shows a message that my cart is empty' do
        visit cart_path

        expect(page).to have_content("Your cart is empty.")
        expect(page).to_not have_link("Clear Cart")
      end
    end

    describe "As a visitor or registered user" do
      it "can add items to cart" do
        item_1 = create(:item)

        visit item_path(item_1)

        click_link "Add to Cart"

        expect(current_path).to eq(items_path)
        expect(page).to have_content("#{item_1.name} has been added to your cart!")
        expect(page).to have_content("Cart: 1")

        item_2 = create(:item)

        visit item_path(item_2)

        click_link "Add to Cart"

        expect(current_path).to eq(items_path)
        expect(page).to have_content("#{item_2.name} has been added to your cart!")
        expect(page).to have_content("Cart: 2")
      end
    end
    describe 'as a visitor or user' do
      describe 'when I have items in my cart' do
        it 'displays info about cart contents' do

          item_1 = create(:item, id: 1, current_price: 3.0)
          visit item_path(item_1)
          click_link "Add to Cart"

          visit item_path(item_1)
          click_link "Add to Cart"

          item_2 = create(:item, id: 2, current_price: 4.5)
          visit item_path(item_2)
          click_link "Add to Cart"

          visit cart_path

          within "#item-#{item_1.id}" do
            expect(page).to have_content(item_1.name)
            expect(page).to have_content(item_1.user.name)
            expect(page).to have_content(item_1.current_price)
            expect(page).to have_content("Quantity: 2")
            expect(page).to have_content("Subtotal: $6.00")
            expect(page).to have_css("img[src*='#{item_1.image}']")
          end

          within "#item-#{item_2.id}" do
            expect(page).to have_content(item_2.name)
            expect(page).to have_content(item_2.user.name)
            expect(page).to have_content(item_2.current_price)
            expect(page).to have_content("Quantity: 1")
            expect(page).to have_content("Subtotal: $4.50")
            expect(page).to have_css("img[src*='#{item_2.image}']")
          end

          expect(page).to have_content("Total: $10.50")
          expect(page).to have_link("Clear Cart")
        end
      end

      describe 'when I click Clear Cart' do
        it "clears my cart" do

          item_1 = create(:item, id: 1, current_price: 3.0)
          visit item_path(item_1)
          click_link "Add to Cart"

          visit item_path(item_1)
          click_link "Add to Cart"

          item_2 = create(:item, id: 2, current_price: 4.5)
          visit item_path(item_2)
          click_link "Add to Cart"

          visit cart_path

          click_link "Clear Cart"

          expect(current_path).to eq(cart_path)
          expect(page).to have_content("Cart: 0")
        end
      end

      describe "I see a link next to the item to delete it" do
        it "deletes only that item" do
          item_1 = create(:item, id: 1, current_price: 3.0)
          visit item_path(item_1)
          click_link "Add to Cart"

          visit item_path(item_1)
          click_link "Add to Cart"

          item_2 = create(:item, id: 2, current_price: 4.5)
          visit item_path(item_2)
          click_link "Add to Cart"

          visit cart_path

          within "#item-#{item_2.id}" do
            click_link "Delete Item"
          end

          expect(page).to_not have_content(item_2.name)
          expect(page).to have_content(item_1.name)
        end
      end

      describe "I see a link next to item to increment by one" do
        it "increments that item by one, but not above the merchant's inventory size" do
          # merchant_1 = create(:merchant)
          item_1 = create(:item, id: 1, current_price: 3.0, inventory: 2)

          visit item_path(item_1)

          click_link "Add to Cart"

          visit cart_path

          click_link "Add One"

          expect(page).to have_content("Quantity: 2")

          visit cart_path

          click_link "Add One"

          expect(page).to have_content("Quantity: 2")
        end
      end

      describe "I see a link next to item to decrement by one" do
        it "decrements that item by one and removes item if decremented to zero" do
          item_1 = create(:item, id: 1, current_price: 3.0)
          visit item_path(item_1)
          click_link "Add to Cart"
          visit cart_path
          click_link "Add One"
          expect(page).to have_content("Quantity: 2")

          click_link "Delete One"

          expect(page).to have_content("Quantity: 1")

          click_link "Delete One"

          expect(page).to_not have_content(item_1.name)
        end
      end
    end

    describe 'as a visitor' do
      describe 'if I have items in my cart' do
        it 'displays a message, with links, that you need to login or register' do
          item_1 = create(:item, id: 1, current_price: 3.0)

          visit item_path(item_1)
          click_link "Add to Cart"

          visit cart_path

          within "#login-message" do
            expect(page).to have_content("You must login or register to checkout.")

            click_link "login"
            expect(current_path).to eq(login_path)

            visit cart_path

            click_link "register"
            expect(current_path).to eq(register_path)
          end
        end
      end
    end

    describe 'as a registered user' do
      describe 'if I have items in my cart' do
        it 'allows the user to checkout and create an order' do
          user = create(:user)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

          item_1 = create(:item, id: 1, current_price: 3.0)

          visit item_path(item_1)
          click_link "Add to Cart"

          visit cart_path

          click_button("Checkout")

          order = Order.last

          expect(current_path).to eq(profile_orders_path(user))

          expect(page).to have_content("Your order has been created!")
          expect(page).to have_content(order.id)
          expect(page).to have_content(order.status)
          expect(page).to have_content("Total Quantity: 1")
          expect(page).to have_content(order.grand_total)
          expect(page).to have_content("Total Price: $3.00")
        end
      end
    end
  end
end
