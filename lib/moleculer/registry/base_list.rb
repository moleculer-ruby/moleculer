class Moleculer::Registry::BaseList
  def initialize
    @list = {}
  end

  def register(item)
    raise NotImplementedError
  end

end
