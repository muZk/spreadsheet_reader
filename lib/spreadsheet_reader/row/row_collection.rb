require 'roo'
require 'active_model'

module SpreadsheetReader

  class RowCollection

    attr_accessor :invalid_row, :rows

    def initialize
      self.rows = []
    end

    def push(reader_row)
      self.invalid_row = reader_row unless reader_row.valid?
      self.rows << reader_row
    end

    def valid?
      self.invalid_row.nil?
    end

    def errors
      self.invalid_row.errors
    end

  end

end