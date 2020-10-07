# frozen_string_literal: true

# FIXME: スクレイピング機能はモジュールに移す
require 'nokogiri'
require 'open-uri'

FORTAIN_PEN_URL = 'https://www.pilot.co.jp/products/pen/fountain/'

# FIXME: カスタム742だけテーブルに製品名がないため別対応を施しているが、xpath内で対応できるなら修正したい
CUSTOM_742_URL = 'https://www.pilot.co.jp/products/pen/fountain/fountain/custom742/'
CUSTOM_HERITAGE_912_URL = 'https://www.pilot.co.jp/products/pen/fountain/fountain/custom_heritage912/'

# 万年筆以外のテーブルは弾く（ボトルインキなど）
TARGET_TABLE_PATH = "//table[@class='dataTableA01' and .//th[text()='サイズ']]"

# サイトの'ペン'の表記ゆれがあるので、複数パターンを書いている
# カスタム742などは製品名がないため、代わりにspan[@class='titleLabel'][1]で取得している
TARGET_DATA_PATH = "tbody/tr/th[text()='製品名' or text()='品番' or text()='価格' or text()='ペン種' or text()='ぺン種']//following-sibling::td"


class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]

  def index
    @fortain_pen_datas
  end

  # ここらへんも、普段は使わないのでrakeタスクに移動させておく
  def import
    if @fortain_pen_datas
      importer = @fortain_pen_datas.map do |data|
        h={}
        h[:name] = data[0]
        # 全角は全て半角にして、不要なスペースは削除する
        h[:product_number] = data[1].tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').gsub(/[[:blank]]/, '')
        h[:price] = data[2]
        h[:niv_type] = data[3]
        h[:image] = data[4]
        h
      end
    end
    # 主キー(product_number)で検索した結果、ヒットしたものに対してはon_duplicate_key_updateで指定されたカラムのみ変更する（こうすることで主キーが変更されることを防ぐ）
    FortainPen.import importer, on_duplicate_key_update: [:name, :price, :niv_type, :image]
  end

  private

  def scraping
    @fortain_pen_datas ||= []
    urls, data = [], []
    image_names = []

    html = open(FORTAIN_PEN_URL, &:read)

    doc = Nokogiri::HTML.parse(html)
    # productList_itemsで最初にヒットしたもの
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]/a').each do |url_node|
      urls << url_node.get_attribute(:href)
    end

    # 画像ファイル名の一覧取得
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]//img').each do |image_node|
      image_names << image_node.get_attribute(:src).split('/').last
    end

    # 各万年筆のデータ取得
    urls.each_with_index do |url, idx|
      html = open(url, &:read)
      doc = Nokogiri::HTML.parse(html)

      # 対象テーブル以外を弾くためだけに使用している
      doc.xpath(TARGET_TABLE_PATH).to_a.each do |node|
        table_node = node.xpath(TARGET_DATA_PATH)

        # 各種データ+画像データを格納
        putin = table_node.text.split(/\R/).reject(&:blank?) << image_names[idx]

        # カスタム742、カスタムヘリテイジ912には製品名がないため別対応
        if [CUSTOM_742_URL, CUSTOM_HERITAGE_912_URL].include? url
          putin.unshift doc.xpath("//span[@class='titleLabel']")[0]&.inner_text
        end

        data << putin
      end
    end

    # FIXME: この時点でDBに入れる構造にしたい
    @fortain_pen_datas = modify_price(data)
    import
  end

  # 金額を整形した状態の配列を返す
  # FIXME: ハッシュ内のpriceというキーについて動くようにしたい
  def modify_price(ary)
    ary.map do |d|
      d[2] = d[2].match('円').pre_match.delete(',').to_i
    end
    ary
  end
end
