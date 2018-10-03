class Jerakia
  class Dataset
    class Namespace

      attr_reader :name
      attr_reader :keys
      attr_reader :request

      def initialize(name,request)
        @name = Array(name)
        @keys = {}
        @request = request
      end

      def submit(data)
        if request.key
          if data.has_key?(request.key)
            key(request.key).ammend(data[request.key])
          end
        else
          data.each do |keyname, value|
            key(keyname).ammend(value)
          end
        end
      end

      def empty?
        @keys.empty?
      end

      def has_key?(key)
        @keys.has_key?(key)
      end

      def key(keyname)
        @keys[keyname] ||= Jerakia::Dataset::Key.new(self,keyname)
        @keys[keyname]
      end

      def keys
        @keys
      end

      # dump: return a consolidated hash of all key value pairs
      def dump
        returndata = {}
        keys.each do |name, k|
          returndata[name] = k.value
        end
        return returndata
      end
      
    end
  end
end
     