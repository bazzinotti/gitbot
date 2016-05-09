module Bazz
  module Utils
    module Class
      def self.class_name_to_file_name(class_name)
        class_name.gsub(/([^\^])([A-Z])/,'\1_\2').downcase
      end
    end
  end
end