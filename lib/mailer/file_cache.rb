require 'useful/ruby_extensions/object'
require 'mailer/mailbox'

module Mailer
  
  class FileCache
    
    attr_reader :path, :name, :mailbox
    
    def initialize(path, mailbox_configs={})
      @path = returning File.expand_path(path) do |path|
        FileUtils.mkdir_p(path)
        @name = File.basename(path)
        @mailbox = Mailer::Mailbox.new(mailbox_configs)
      end
    end
    
    def get_new_mail!
      returning([]) do |file_paths|
        @mailbox.check do |email|
          email.each do |mail|
            file_paths << self.write(mail)
            mail.delete
          end
        end
      end
    end
    
    def [](mail)
      key = mail.kind_of?(::Net::POPMail) ? mail.unique_id : mail.to_s
      returning self.path(mail.unique_id) do |path|
        File.open(path, 'r') do |file|
          yield(file) if block_given?
        end
      end
    end
    alias_method '[]', 'read'
    
    def <<(mail)
      validate_mail(mail)
      returning self.path(mail.unique_id) do |path|
        File.open(path, 'w+') do |file|
          file.write mail.pop
        end
        @entries = nil
      end
    end
    alias_method '<<', 'write'
    
    def remove(path_or_key)
      FileUtils.rm_f(self.path(File.basename(path_or_key)))
    end
    
    # empties the cache of all entries
    def clear!
      FileUtils.rm_f(cache_entries_path)
    end
    
    def entries
      @entries ||= Dir[self.cache_entries_path]
    end
    
    def keys
      self.entries.collect{|file| File.basename(file)}
    end
    
    def length
      self.entries.length
    end
    alias_method :length, :size
    
    def empty?
      self.entries.empty?
    end
    
    def each
      self.keys.each do |key|
        self[key] do |file|
          yield(file) if block_given?
        end
      end
    end
    
    protected
    
    def path(key)
      File.join([@home, key.to_s])
    end
    
    private

    def cache_entries_path
      File.join(@home, '*')
    end
    
    def validate_mail(mail)
      unless mail.kind_of?(::Net::POPMail)
        raise ArgumentError, "trying to write '#{mail.class.to_s}' object to the cache.  You can only write 'Net::POPMail' objects"
      end
      unless mail.respond_to?(:unique_id) && !mail.unique_id.blank?
        raise ArgumentError, "this mail has an invalid unique_id"
      end
    end
      
    end
    
  end
end