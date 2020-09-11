# frozen_string_literal: true

# FIXME: スクレイピング機能はモジュールに移す
require 'nokogiri'
require 'open-uri'

class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]
  # スクレイピング結果一覧を表示
  def index
    @data
  end

  def show; end

  def destroy; end

  def update; end

  private

  def scraping
    @urls ||= []
    url = 'https://www.pilot.co.jp/products/pen/fountain/'
    html = open(url, &:read)

    doc = Nokogiri::HTML.parse(html)
    doc.xpath('//div[@class="productList_item"]/a').each do |node|
      @urls << node.get_attribute(:href)
    end
    getData
  end

  # 各種URL内の文字列を取得する
  def getData
    # url配列群
    @data ||= []
    @urls.each do |url|
      html = open(url, &:read)
      doc = Nokogiri::HTML.parse(html)
      doc.xpath('//table[@class="dataTableA01"]').each do |node|
        @data << node.css('p').inner_text
      end
    end
  end
end
