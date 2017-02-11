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

end
