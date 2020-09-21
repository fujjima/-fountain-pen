# frozen_string_literal: true

# FIXME: スクレイピング機能はモジュールに移す
require 'nokogiri'
require 'open-uri'

FORTAIN_PEN_URL = 'https://www.pilot.co.jp/products/pen/fountain/'

# たまに万年筆以外のものが混じっている可能性がある（ボトルインキなど）
TARGET_TABLE_PATH = "//table[@class='dataTableA01' and .//th[text()='サイズ']]"

# サイトの'ペン'の表記が一部おかしいので、複数パターン書いている
TARGET_DATA_PATH = "//th[text()='製品名' or text()='価格' or text()='ペン種' or text()='ぺン種']//following-sibling::td"

class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]
  # スクレイピング結果一覧を表示
  def index
    @fortain_pen_datasdatas
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
      # doc.xpath("//th[text()='製品名' or text()='価格' or text()='ペン種' or text()='ぺン種']/following-sibling::td").each do |node| end
      doc.xpath(TARGET_TABLE_PATH + TARGET_DATA_PATH).each do |node|
        data << node.css('p').inner_text
      end
    end

    @fortain_pen_datas = data.each_slice(3).to_a
    modify_price!
    # modify_kind!
  end

  # 金額整形
  def modify_price!
    @fortain_pen_datas.map! do |d|
      d[1].match('円').pre_match.delete(',').to_i
    end
  end
end
