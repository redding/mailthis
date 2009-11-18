require 'useful/ruby_extensions/object'
require 'mailer/exceptions'
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
    
    def read(path_or_key)
      returning self.path(File.basename(path_or_key)) do |path|
        if File.exists?(path)
          File.open(path, 'r') do |file|
            yield(file) if block_given?
          end
        else
          raise ArgumentError, "the file '#{path}' does not exists"
        end
      end
    end
     
    # => write(mail_obj)
    # => write(custom_key, mail_obj)
    def write(*args)
      key, mail = get_key_and_mail(args)
      returning self.path(key) do |path|
        File.open(path, 'w+') do |file|
          file.write mail.pop
        end
        @entries = nil
      end
    end
    alias_method '<<', 'write'
    
    def delete(path_or_key)
      FileUtils.rm_f(self.path(File.basename(path_or_key)))
    end
    
    # empties the cache of all entries
    def clear!
      FileUtils.rm_f(cache_entries_path)
    end
    
    def entries
      @entries ||= Dir[cache_entries_path]
    end
    
    def keys
      self.entries.collect{|file| File.basename(file)}
    end
    
    def length
      self.entries.length
    end
    alias_method 'size', 'length'
    
    def empty?
      self.entries.empty?
    end
    
    def each
      self.keys.each do |key|
        self.read(key) do |file|
          yield(file) if block_given?
        end
      end
    end
    
    protected
    
    def path(key)
      File.join([@path, key.to_s])
    end
    
    private

    def cache_entries_path
      File.join(@path, '*')
    end
    
    def get_key_and_mail(args)
      returning [] do |key_and_mail|
        case args.length
        when 1
          mail = args.first
        when 2
          key = args.first
          mail = args.last
        else
          raise ArgumentError, "invalid write arguements '#{args.inspect}'"
        end
        unless mail.kind_of?(::Net::POPMail)
          raise ArgumentError, "trying to write '#{mail.class.to_s}' object to the cache.  You can only write 'Net::POPMail' objects"
        end
        if key.blank?
          unless mail.respond_to?(:unique_id) && !mail.unique_id.blank?
            raise ArgumentError, "this mail has an invalid unique_id"
          end
          key = mail.unique_id
        end
        key_and_mail << key
        key_and_mail << mail
      end
    end
   
  end
end