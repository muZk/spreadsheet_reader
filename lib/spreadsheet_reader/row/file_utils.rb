
module SpreadsheetReader

  module FileUtils

    def original_filename(file)
      return file.original_filename if file.respond_to? :original_filename
      return File.basename file if file.instance_of? File
      file
    end

    module_function :original_filename

  end

end