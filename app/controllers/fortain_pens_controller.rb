# frozen_string_literal: true

# FIXME: スクレイピング機能はモジュールに移す
require 'nokogiri'
require 'open-uri'

FORTAIN_PEN_URL = 'https://www.pilot.co.jp/products/pen/fountain/'

# FIXME: カスタム742だけテーブルに製品名がないため別対応を施しているが、xpath内で対応できるなら修正したい
CUSTOM_742_URL = 'https://www.pilot.co.jp/products/pen/fountain/fountain/custom742/'
CUSTOM_HERITAGE_912_URL = 'https://www.pilot.co.jp/products/pen/fountain/fountain/custom_heritage912/'

# たまに万年筆以外のものが混じっている可能性がある（ボトルインキなど）
TARGET_TABLE_PATH = "//table[@class='dataTableA01' and .//th[text()='サイズ']]"

# サイトの'ペン'の表記ゆれがあるので、複数パターンを書いている
# カスタム742は製品名がないので、//span[@class='titleLabel'][1]
TARGET_DATA_PATH = "//th[text()='製品名' or text()='価格' or text()='ペン種' or text()='ぺン種']//following-sibling::td"


class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]

  def index
    @fortain_pen_datasdatas
  end

  # 追加されたものがあれば新規作成、更新されたものについては更新
  def import
    if @fortain_pen_datas
      importer = @fortain_pen_datas.map do |data|
        h={}
        h[:name] = data[0]
        h[:price] = data[1]
        h[:niv_type] = data[2]
        h
      end
    end
    FortainPen.import importer
  end

  def show; end

  def destroy; end

  def update; end

  private

  def scraping
    @fortain_pen_datas ||= []
    urls, data = [], []
    html = open(FORTAIN_PEN_URL, &:read)

    # 各種万年筆へのリンク先取得
    doc = Nokogiri::HTML.parse(html)
    # productList_itemsで最初にヒットしたもの
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]/a').each do |node|
      urls << node.get_attribute(:href)
    end

    # 各万年筆のデータ取得
    urls.each do |url|
      html = open(url, &:read)
      doc = Nokogiri::HTML.parse(html)

      # カスタム742、カスタムヘリテイジ912に製品名がない
      if [CUSTOM_742_URL, CUSTOM_HERITAGE_912_URL].include? url
        data << doc.xpath("//span[@class='titleLabel']")[0]&.inner_text
      end
      
      doc.xpath(TARGET_TABLE_PATH + TARGET_DATA_PATH).each do |node|
        data << node.css('p').inner_text
      end
    end

    @fortain_pen_datas = data.each_slice(3).to_a
    modify_price!
    # modify_kind!
    import
  end

  # 金額を整形した状態の配列を返す
  def modify_price!
    @fortain_pen_datas.map do |d|
      d[1] = d[1].match('円').pre_match.delete(',').to_i
    end
  end
end
