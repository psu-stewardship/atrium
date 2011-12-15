class Atrium::Liquid::Placeholder < Liquid::Tag
  def initialize(tag_name, collection, tokens)
    super
    @collection = collection
    @renderer = Atrium::RenderingController.new
  end

  def render(context)
    @renderer.placeholder(@collection)
  end
end
