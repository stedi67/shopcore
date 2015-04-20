#!/usr/bin/env nimscript

type 
  BuisinessType = enum
    b2c, b2b

  Currency = enum
    EUR, USD

  Money = object
    amount: int
    currency: Currency

  Country = object
    country_code, region, tax_region: string
    allow_shipment: bool

  Tax = object
    id: int
    tax_region: string
    physical: bool
    buisiness_type: BuisinessType
    rate: float
