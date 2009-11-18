require File.dirname(__FILE__) + '/../test_helper'

class Mailer::FileCacheTest < Test::Unit::TestCase

  context "The Mailer::FileCache" do
    setup do
      @fc_dir = "~/.mailer_file_test/file_cache_test"
      @fc_dir_expanded = File.expand_path(@fc_dir)
      FileUtils.rm_rf(@fc_dir_expanded)
      @fc = Mailer::FileCache.new(@fc_dir, {})
    end
    subject { @fc }

    should_have_readers *[:home, :name, :mailbox]
    
    should "create the cache directory" do 
      assert File.exists?(@fc_dir_expanded)
    end
    
    should "set the cache name from the file path" do
      assert_equal File.basename(@fc_dir_expanded), @fc.name
    end
    
    should_have_instance_methods 'read', 'write', '<<', 'delete'
    should_have_instance_methods 'get_new_mail!', 'clear!', 'entries', 'keys'
    should_have_instance_methods 'length', 'size', 'empty?', 'each', 'collect'
    
    context "with an entry" do
      setup do
        File.open(File.join(@fc_dir_expanded, 'a_file'), 'w+') do |file|
          file.write "a test file"
        end
      end

      should "clear its entries and know it is empty" do
        assert_nothing_raised do
          @fc.clear!
        end
        assert @fc.empty?
        assert_equal 0, @fc.length
        assert_equal [], @fc.entries
        assert_equal [], @fc.keys
      end
    end

    context "with no entries" do
      setup do
        @fc.clear!
      end
      
      should "error if read from" do
        assert_raise ArgumentError do
          @fc.read('some_mail_msg_that_does_not_exist') do |file|
            contents = file.read
          end
        end
      end
    end
    
    should "error writing with no args" do
      assert_raise ArgumentError do
        @fc.write()
      end
    end
    
    should "error writing with too many args" do
      assert_raise ArgumentError do
        @fc.write('some_key', 'something-not-a-popmail-obj', 'some-addtl-args')
      end
    end

    should "error writing with no popmail arg" do
      assert_raise ArgumentError do
        @fc.write('some_key', 'something-not-a-popmail-obj')
      end
      assert_raise ArgumentError do
        @fc.write('something-not-a-popmail-obj')
      end
    end
  end

end