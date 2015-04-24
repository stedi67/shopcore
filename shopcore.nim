#!/usr/bin/env nimscript

type 
  BuisinessType = enum
    b2c, b2b

  PriceType = enum
    net, gross

  Currency = enum
    EUR, USD

  Money = object
    amount: int
    currency: Currency

  Country = object
    country_code, region, tax_region: string
    allow_shipment: bool

  GoodsType = enum
    physical, software, book

  Tax = object
    id: int
    tax_region: string
    goods_type: GoodsType
    rate: float

  Price = object
    net_price: Money
    tax: Money
    tax_line: Tax
