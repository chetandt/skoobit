class ProductsController < Spree::BaseController
  HTTP_REFERER_REGEXP = /^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper :taxons

  respond_to :html

  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products

    respond_with(@products)
  end

  def show
      
    @product = Product.find_by_permalink!(params[:id])
    return unless @product

    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
    @selected_variant = @variants.detect { |v| v.available? }
    @afiliated_vendors = afiliated_vendors
    puts "@@@@@@@@@@@@@@@@@@@@@"
    puts @afiliated_vendors.class
    referer = request.env['HTTP_REFERER']

    if referer && referer.match(HTTP_REFERER_REGEXP)
      @taxon = Taxon.find_by_permalink($1)
    end

    respond_with(@product)
  end

  private

  def afiliated_vendors
    products = []
    products << {"title"=>"Business Ethics 8th Edition", "price" => "$60.49","url"=> "http://www.chegg.com/textbooks/business-ethics-8th-edition-9781439042236-1439042233?omre_ir=1&omre_sp=c&omre_rn=1"}
    products << {"title"=>"Naked Economics 2nd Edition","price" => "$8.99", "url"=> "http://www.chegg.com/textbooks/naked-economics-2nd-edition-9780393337648-0393337642"}
    return products
  end

  def accurate_title
    @product ? @product.name : super
  end
end
