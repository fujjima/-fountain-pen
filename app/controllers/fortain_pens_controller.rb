require 'nokogiri'
require 'open-uri'

class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]

  def index
    @fortain_pens = FortainPen.all
  end

  def import
    if @fortain_pen_datas
      importer = @fortain_pen_datas.map do |data|
        # FIXME：配列のインデックス指定は解読不能なので止める
        # 万年筆の属性をどこかに配列として持っておいて、mapで順に格納していくようにするとか？（順番考慮しないといけない問題は残る）
        h={}
        h[:name] = data[0]
        h[:product_number] = prettier_string(data[1])
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
    data = []

    # 万年筆一覧ページ内の要素取得ができるようにparseする
    # open:open-uri#open
    fortain_pens_list_doc = Nokogiri::HTML.parse(open(Settings.pilot.url.fortain_pen_url, &:read))

    fortain_pen_urls(fortain_pens_list_doc).each_with_index do |url, idx|
      # 各種万年筆ページ内の要素取得のためのhtml
      fortain_pen_doc = Nokogiri::HTML.parse(open(url, &:read))

      # 取得する万年筆情報のxpath群を列挙しておく
      # xpathで取得したデータを順にハッシュに格納しておく（キーの指定）

      # 対象テーブル以外を弾くためだけに使用している
      fortain_pen_doc.xpath(Settings.pilot.xpath.target_table_path).to_a.each do |node|
        table_node = node.xpath(Settings.pilot.xpath.target_data_path)

        # 各種データ+画像データを格納
        # TODO:何かの間違いでinage_namesとtable_nodeの対応がずれたら一巻の終わり
        putin = table_node.text.split(/\R/).reject(&:blank?) << fortain_pen_image_names(fortain_pens_list_doc)[idx]

        # カスタム742、カスタムヘリテイジ912には製品名がないため別対応
        if [Settings.pilot.url.custom_742_url, Settings.pilot.url.custom_heritage_912_url].include? url
          putin.unshift fortain_pen_doc.xpath("//span[@class='titleLabel']")[0]&.inner_text
        end

        data << putin
      end
    end

    # FIXME: この時点でFortainPenのインスタンスとして必要な情報は揃っているためインスタンスを作ってしまいたい
    @fortain_pen_datas = modify_price(data)
    import
  end

  # 万年筆一覧ページから各万年筆のページへのリンク要素を探し、配列にして返す
  def fortain_pen_urls(doc)
    urls = []
    # productList_itemsで最初にヒットしたもの
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]/a').each do |url_node|
      urls << url_node.get_attribute(:href)
    end
    urls
  end

  # 万年筆一覧ページから各万年筆の画像のパスを探し、画像ファイル名の一覧を配列にして返す
  def fortain_pen_image_names(doc)
    image_names = []
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]//img').each do |image_node|
      # xpathで指定されたsrc要素の文字列を/で分割し、その最後の文字列をファイル名とする
      image_names << image_node.get_attribute(:src).split('/').last
    end
    image_names
  end
end
