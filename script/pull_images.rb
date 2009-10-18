require File.dirname(__FILE__) + '/../../../config/environment'
require 'net/http'
require 'digest/md5'
require 'fileutils'

LOCAL_IMAGE_PATH_PREFIX = File.join(File.dirname(__FILE__), "..", "public", "images")
CONCURRENCY_LEVEL = 8

threads = []
emails  = [User, Ticket, TicketChange].map do |klass| 
  klass.all(:select => 'email') 
end.flatten.map(&:email).compact.uniq + ['']

emails.each_slice((emails.size / CONCURRENCY_LEVEL.to_f).ceil) do |slice|
  
  thread = Thread.new do
    
    http = Net::HTTP.new('www.gravatar.com', 80)
    slice.each do |email|
      puts "Downloading Gravatar(s) for #{email}"
      [30, 40].each do |size|
        digest = Digest::MD5.hexdigest(email.to_s.downcase)
        path   = File.join(LOCAL_IMAGE_PATH_PREFIX, size.to_s, "#{digest}.png")
        next if File.exist?(path) and ARGV[0] != 'force'
        
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'wb') do |f|
          f << http.get("/avatar/#{digest}.png?s=#{size}").body
        end
      end
    end
  
  end
  threads << thread
  
end

threads.each(&:join)