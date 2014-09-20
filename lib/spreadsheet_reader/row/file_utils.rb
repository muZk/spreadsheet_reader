
module SpreadsheetReader

  module FileUtils

    def original_filename(file)
      if file.instance_of? File
        if file.respond_to? :original_filename
          return file.original_filename
        else
          return File.basename file
        end
      end
      file
    end

    module_function :original_filename

  end

end