require 'aws-sdk'
require 'fileutils'
require 'java'
require 'jbundler'
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

  def self.setup
    import_data_file_to_s3
    define_athena_schema
  end

  def self.configs
    @configs ||= {}
  end

  def self.aws_credential_configs
    {
      access_key_id:     configs[:aws_access_key_id]     || ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: configs[:aws_secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY'],
      region:            configs[:aws_region]            || ENV['AWS_REGION'],
    }
  end

  def self.s3_resource
    @s3_resource ||= Aws::S3::Resource.new(aws_credential_configs)
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

  def self.s3_location
    "s3://#{s3_bucket.name}/#{s3_path}"
  end

  def self.athena_db_name
    configs[:athena_db_name] || 'postalsearchjp'
  end

  def self.athena_table_name
    configs[:athena_table_name] || 'jp_postal_codes'
  end

  def self.new_athena_connection
    com.amazonaws.athena.jdbc.AthenaDriver # Load driver class
    aws_configs = aws_credential_configs

    athena_jdbc_url = "jdbc:awsathena://athena.#{aws_configs[:region]}.amazonaws.com:443"
    props = java.util.Properties.new
    props.set_property('user', aws_configs[:access_key_id])
    props.set_property('password', aws_configs[:secret_access_key])
    props.set_property('s3_staging_dir', "#{s3_location}/query_results")

    java.sql.DriverManager.get_connection(athena_jdbc_url, props)
  end

  def self.import_data_file_to_s3
    destination_object = s3_bucket.object("#{s3_path}/data/ken_all_rome_utf8.csv")
    if destination_object.exists?
      puts 'Data file already exists.'
      return
    end

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
    result = destination_object.upload_file(converted_file, {
      acl: 'public-read',
    })
    puts 'Data file has been imported.'
  ensure
    FileUtils.rm_rf(TMP_DIRECTORY) if File.exists?(TMP_DIRECTORY)
  end

  def self.define_athena_schema
    connection = new_athena_connection
    statement = connection.create_statement

    query1 = <<-QUERY
      CREATE DATABASE IF NOT EXISTS #{athena_db_name}
    QUERY
    statement.execute_query(query1)

    query2 = <<-QUERY
      CREATE EXTERNAL TABLE IF NOT EXISTS #{athena_db_name}.#{athena_table_name} (
        `postal_code`     string,
        `prefecture`      string,
        `city`            string,
        `street`          string,
        `prefecture_kana` string,
        `city_kana`       string,
        `street_kana`     string
      )
      ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
      WITH SERDEPROPERTIES (
        'separatorChar' = ',',
        'quoteChar' = '"'
      ) LOCATION '#{s3_location}/data/'
    QUERY
    statement.execute_query(query2)

    puts 'Athena schema defined.'
  ensure
    statement.close if statement
    connection.close if connection
  end

end
