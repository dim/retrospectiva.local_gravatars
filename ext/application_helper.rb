require 'digest/md5'

module ApplicationHelper
  protected
    
    def gravatar_with_local_cache(email, options = {})
      email  = "" if email.ends_with?("@#{request.host}")      
      size   = options.delete(:size) || 40
      prefix = [30, 40].include?(size) ? size : 40
      source = "#{prefix}/#{Digest::MD5.hexdigest(email.to_s.downcase)}.png"
      path   = compute_public_path(source, "extensions/local_gravatars/images")

      options.merge!(:width => size, :height => size, :src => path)
      options.reverse_merge!(:class => 'frame', :alt => '')
      
      tag :img, options
    end
    alias_method_chain :gravatar, :local_cache

end

