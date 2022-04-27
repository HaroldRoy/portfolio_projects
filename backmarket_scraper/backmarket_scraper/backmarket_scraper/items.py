# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class BackmarketScraperItem(scrapy.Item):
    # define the fields for your item here like:
    name = scrapy.Field()
    warranty = scrapy.Field()
    specs = scrapy.Field()
    price = scrapy.Field()
    price_new = scrapy.Field()
