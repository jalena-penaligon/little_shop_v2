class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  # def one_day
  #   3600*24
  # end
  #
  # def fulfillment_time
  #   ((updated_at - created_at)/one_day).round(2)
  # end
  #
  #
  # def order_items_by_user(current_user, item_id)
  #   OrderItem.where(item_id: item_id)
  # end


  def self.find_item(item)
    orderitems = OrderItem.where(item_id: item.id).order(:id)
  end


  def self.map_it(orderitemsarray)
    the_sum = orderitemsarray.map do |orderitem|
      (orderitem.updated_at - orderitem.created_at)
    end.sum
  end

  # def fulfillment_time
  #   ((updated_at - created_at)/one_day).round(2)
  # end

  def self.fulfillment_time(item)
    orderitems = self.find_item(item)
    the_count = orderitems.count
    the_sum = self.map_it(orderitems)
    if the_sum < 1
      0
    else
      avg_time = (the_sum)/the_count
      (avg_time/(3600*24)).round(2)
    end
  end


end
