if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Amazon S3 的配置
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['AKIAIFQI56ZG4HIR4XLQ'],
      :aws_secret_access_key => ENV['BG5QQYHJGuCV/cu1L67PqHoAvehlGgB3PhYYFBw']
    }
    config.fog_directory     =  ENV['smaple-app']
  end
end