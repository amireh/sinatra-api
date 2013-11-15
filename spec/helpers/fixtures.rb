class ModelAdapter
end

class CollectionAdapter
  def initialize(model)
    @model = model
  end

  def self.get(key)
    return @model.new
  end
end

class Item
  def self.get(id)
    return {} if id == 1
  end

  def sub_items
    CollectionAdapter.new(SubItem)
  end
end

class SubItem < ModelAdapter
  def item
    Item.new
  end
end