require 'aws-sdk'
require 'fileutils'
require 'open-uri'
require 'securerandom'
require 'zip'

require 'postal_search_jp/version'

TMP_DIRECTORY = '/tmp/postal_search_jp'
FILE_URL_ROMAN_ZIP = 'http://www.post.japanpost.jp/zipcode/dl/roman/ken_all_rome.zip'

module PostalSearchJp

  def self.configure(options)
    @configs = {}
    @configs.merge!(options)
  end

  def self.configs
    @configs ||= {}
  end

  def self.s3_resource
    @s3_resource ||= begin
      options = {}
      options[:access_key_id]     = configs[:access_key_id]     if configs[:access_key_id]
      options[:secret_access_key] = configs[:secret_access_key] if configs[:secret_access_key]
      options[:region]            = configs[:region]            if configs[:region]
      Aws::S3::Resource.new(options)
    end
  end

  def self.s3_bucket
    @s3_bucket ||= begin
      bucket = s3_resource.bucket(configs[:s3_bucket] || SecureRandom.hex(8))
      bucket.create unless bucket.exists?
      bucket
    end
  end

  def self.s3_path
    configs[:s3_path] || 'postal_search_jp'
  end

  def self.import_raw_data_file
    # Create tmp dir.
    Dir.mkdir(TMP_DIRECTORY)

    # Download raw data file.
    downloaded_file = "#{TMP_DIRECTORY}/ken_all_rome.zip"
    open(downloaded_file, 'wb') do |file|
      file << open(FILE_URL_ROMAN_ZIP).read
    end

    # Extract zip file.
    extracted_file = nil
    Zip::File.open(downloaded_file) do |zip_file|
      if entry = zip_file.glob('*.CSV').first
        extracted_file = "#{TMP_DIRECTORY}/#{entry.name}"
        zip_file.extract(entry, extracted_file)
      end
    end
    if extracted_file.nil?
      puts 'No entry with extension csv found in zip file.'
      return
    end

    # Convert encoding & new line code.
    converted_file = "#{TMP_DIRECTORY}/ken_all_rome_utf8.csv"
    open(converted_file, 'wb') do |file|
      file << open(extracted_file, 'rb:Shift_JIS:UTF-8', undef: :replace).read.gsub(/\r\n/, "\n")
    end

    # Upload to S3.
    object = s3_bucket.object("#{s3_path}/ken_all_rome_utf8.csv")
    result = object.upload_file(converted_file, {
      acl: 'public-read',
    })
  ensure
    FileUtils.rm_rf(TMP_DIRECTORY) if File.exists?(TMP_DIRECTORY)
  end

end
