
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'active_record'
require '/home/developer/chetan/chetan/skoobit/app/models/book.rb'
ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :username => "root",
  :host     => "localhost",
  :password => "root",
  :database => "skoobit_development"
)

$category_links = []
$sub_category_links = ["http://www.chegg.com/textbooks/body-mind-and-spirit-4"]
doc = Hpricot(open("http://www.chegg.com/textbooks/"))
links = (doc/"div.category-list"/:a)


def get_category_list(links)
  links.each do |link|
    $category_links << link.attributes["href"]
    puts link.attributes["href"]
    puts "!!cat!!!!!!!!!!!!!!!!!!!!!"
  end
end

def get_subcategory_list(category_links)
	category_links.each do  |category_link|
	  doc1 = Hpricot(open("#{category_link}"))
	  links = (doc1/"div.category-list"/:a)
	  links.each do |link|
      $sub_category_links << link.attributes["href"]
      puts link.attributes["href"]
      puts "!!!sub!!!!!!!!!!!!!!!!!!!!"
    end
	end
end

def save_book_info(book_link)
  doc3 = Hpricot(open("#{book_link}"))
  book = Book.new()
  book.title = (doc3/"h1.pdp-hvr-title").inner_text rescue ""
  book.isbn =  (doc3/"h2.chg-pricebox-isbn")[0].inner_text rescue ""
  book.isbn_13 =  (doc3/"h2.chg-pricebox-isbn")[1].inner_text rescue ""
  book.price = (doc3/"span.chg-pricebox-left")[2].inner_text rescue ""
  book.list_price = (doc3/"span#book-list-price").inner_text rescue ""
  book.image_url = (doc3/"div.image-div"/:img)[0].attributes["src"].to_s rescue ""
  book.description = (doc3/"div.chg-col-5/"/:p/".more-summary-content").inner_text rescue ""
  book.publisher = (doc3/"div.chg-col-5/"/:p/:span/".txt-body")[1].inner_text rescue ""
  book.author = (doc3/"div.chg-col-5/"/:p/:span/".txt-body")[2].inner_text rescue ""
#  book.categoty =  (doc3/"div.global-breadcrumb"/:a)[2].inner_text rescue ""
  book.save
puts "@@@@@@@@@@@@@@@@@@@@2"
puts book_link
puts (doc3/"span.chg-pricebox-left")[1].inner_text
puts (doc3/"span.chg-pricebox-left")[2].inner_text
puts (doc3/"span.chg-pricebox-left")[3].inner_text
puts (doc3/"span.chg-pricebox-left")[4].inner_text
puts (doc3/"span.chg-pricebox-left")[5].inner_text
end

def get_book_links(sub_category_links)
	sub_category_links.each do |sub_category_link|
    doc2 = Hpricot(open("#{sub_category_link}"))
    #number_of_pages = doc2/"div.hh-pagination"/"span.displaying".inner_html
    book_links = doc2/"div.chg-col-12"/:table/:tbody/:tr/:td/:a
    book_links.each do |book_link|
      save_book_info(book_link.attributes["href"])
		end
	end
end

#get_category_list(links)
#get_subcategory_list($category_links)
get_book_links($sub_category_links)





