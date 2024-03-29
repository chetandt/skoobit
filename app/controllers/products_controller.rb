require 'open-uri'
class ProductsController < Spree::BaseController
  HTTP_REFERER_REGEXP = /^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper :taxons

  respond_to :html

  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = Product.all#@searcher.retrieve_products

    respond_with(@products)
  end

  def show

    @product = Product.find_by_permalink!(params[:id])
    return unless @product

    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
    @selected_variant = @variants.detect { |v| v.available? }
    @afiliated_vendors = afiliated_vendors
    referer = request.env['HTTP_REFERER']

    if referer && referer.match(HTTP_REFERER_REGEXP)
      @taxon = Taxon.find_by_permalink($1)
    end

    respond_with(@product)
  end

  def get_affiliate
    isbn = params[:isbn] || "9780060765576"
    @bookrenter = open("http://www.bookrenter.com/api/fetch_book_info?developer_key=MAWRL7Is418fEqaWpOlY5NMHZjhejXbF&version=2008-07-29&isbn=#{isbn}")
    @chegg_data = open("http://api.chegg.com/rent.svc?KEY=9383d49949fd7e3efb1891249ce7370c&PW=1076222&R=XML&V=2.0&isbn=#{isbn}&with_pids=1")
  end

  def search
    @prducts = search_text(params)
    redirect_to :back
  end

  protected
  def search_text(options)
    puts "!!!!!!!!!!!!!#{options}"
    Sunspot.search(Product) do
      keywords options[:search]
      paginate :page => options[:page]
    end
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
