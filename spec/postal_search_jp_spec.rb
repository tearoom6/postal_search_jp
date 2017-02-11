require 'spec_helper'

RSpec.describe PostalSearchJp do
  before(:each) do
    PostalSearchJp.configure(
      s3_bucket: 'my-postal-search-jp',
      s3_path:   'my_postal_search_jp',
    )
  end

  it 'has a version number' do
    expect(PostalSearchJp::VERSION).not_to be nil
  end

  it 'checks specified configure options' do
    expect(PostalSearchJp.configs[:s3_bucket]).to eq('my-postal-search-jp')
    expect(PostalSearchJp.configs[:s3_path]).to eq('my_postal_search_jp')
  end

  it 'searches by address' do
    records = PostalSearchJp.search_by_address('井の頭')
    expect(records.size).to eq(1)
    expect(records.first.postal_code).to eq('1810001')
    records = PostalSearchJp.search_by_address('東京')
    expect(records.size).to eq(3813)
    records = PostalSearchJp.search_by_address('1810001')
    expect(records).to be_empty
  end

  it 'finds by postal code' do
    expect(PostalSearchJp.find_by_postal_code('1810001').prefecture).to eq('東京都')
    expect(PostalSearchJp.find_by_postal_code('1810001').city).to eq('三鷹市')
    expect(PostalSearchJp.find_by_postal_code('181-0001')).to be_nil
  end

end
