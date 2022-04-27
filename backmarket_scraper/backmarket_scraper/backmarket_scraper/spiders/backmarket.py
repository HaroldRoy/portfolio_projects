import scrapy
from ..items import BackmarketScraperItem

# Scraping the refurbished laptop section from www.backmarket.com looking for a list of prices. 

# item = //div[@class="flex flex-col md:flex-1 md:justify-end"]
# name = //div[@class="flex flex-col md:flex-1 md:justify-end"]/h2/text()
# warranty = //span[@class="text-black font-body text-2 leading-2 font-light"]/text()
# specs = //span[@class="duration-200 line-clamp-1 normal-case overflow-ellipsis overflow-hidden text-black transition-all font-body text-2 leading-2 font-light"]/text()
# price = //span[@class="text-black font-body text-2 leading-2 font-bold"]/text()
# price_new = //span[@class="text-grey-400 font-body text-2 leading-2 font-light"]/del/text()

class BackmarketSpider(scrapy.Spider):
    name = 'backmarket'
    page_number = 2
    start_urls = [
        'https://www.backmarket.com/refurbished-computers.html?page=1#'
    ]
    
    custom_settings = {
        'FEEDS': {
            'backmarket.csv': {
                'format': 'csv',
                'encoding': 'utf8',
                'overwrite': True,
            }
        }
    }
    
    def parse(self, response):

        items = BackmarketScraperItem()

        all_item = response.xpath('//div[@class="flex flex-col md:flex-1 md:justify-end"]')

        for i in all_item:
            name = i.xpath('h2/text()').get(),
            warranty = i.xpath('span/text()').get(),
            specs = i.xpath('div/span[@class="duration-200 line-clamp-1 normal-case overflow-ellipsis overflow-hidden text-black transition-all font-body text-2 leading-2 font-light"]/text()').get(),
            price = i.xpath('div/span[@class="text-black font-body text-2 leading-2 font-bold"]/text()').get(),
            price_new = i.xpath('div/div/span/del/text()').get()

            items['name'] = name
            items['warranty'] = warranty
            items['specs'] = specs
            items['price'] = price
            items['price_new'] = price_new

            yield items 

        next_page = 'https://www.backmarket.com/refurbished-computers.html?page='+ str(BackmarketSpider.page_number) +'#'
        if BackmarketSpider.page_number <= 11:
            BackmarketSpider.page_number += 1
            yield response.follow(next_page, callback=self.parse)