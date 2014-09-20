require 'spreadsheet_reader/row/version'
require 'spreadsheet_reader/row/base'
require 'spreadsheet_reader/row/file_utils'
require 'spreadsheet_reader/row/row_collection'
require 'active_model'
require 'roo'

module SpreadsheetReader

  class Row #< SpreadsheetReader::Base

    include ActiveModel::Model
    include SpreadsheetReader::Base

    attr_accessor :row_number

    def copy_errors(model)
      model.errors.each do |key, value|
        self.errors[key] = value
      end
    end

    def self.starting_row
      2
    end

    def self.columns
      cloned = self.attributes.clone
      cloned.delete :row_number
      array_to_hash cloned
    end

    def self.format(format = nil)
      format = format || self.columns
      format = array_to_hash(format) if format.is_a?(Array)
      format
    end

    def self.formatted_hash(array, format = nil)
      format = self.format(format)

      if format.present? and format.keys.count > 0
        parsed_row = {}
        format.each_pair { |key, col| parsed_row[key] = array[col] }
        return parsed_row
      end

      return nil
    end

    def initialize(arr_or_hash = {})
      if arr_or_hash.is_a?(Array)
        super(self.class.formatted_hash(arr_or_hash))
      else
        super(arr_or_hash)
      end
    end

    def self.validate_multiple_rows(row_collection)

    end

    def self.after_multiple_rows_validation(row_collection)

    end

    def self.open_spreadsheet(file)
      name = FileUtils.original_filename(file)
      case File.extname name
        when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
        when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
        else false
      end
    end

    def self.read_spreadsheet(file)

      if columns.empty?
        raise NotImplementedError
      end

      spreadsheet = open_spreadsheet(file)
      row_collection = SpreadsheetReader::RowCollection.new

      begin
        validate_rows(spreadsheet, row_collection)
        validate_multiple_rows(row_collection)
        after_multiple_rows_validation(row_collection)
        row_collection
      rescue
        row_collection
      end

    end

    def self.array_to_hash(arr)
      # Transform an array [a0, a1, a2, ...] to a Hash { a0 => 0, a1 => 1, etc }
      # which is the format requires by the self.get_format method
      Hash[[*arr.map { |e| e.to_sym }.map.with_index]]
    end

    def self.rollback
      raise ActiveRecord::Rollback
    end

    private

    def self.validate_rows(spreadsheet, row_collection)
      (starting_row..spreadsheet.last_row).each do |number|
        hash = formatted_hash(spreadsheet.row(number))
        hash[:row_number] = number
        row_collection.push self.new(hash)
        raise 'Invalid Row in Excel' unless row_collection.valid?
      end
    end

    # class << self
    #
    #   extend ActiveModel::Callbacks
    #
    #   define_model_callbacks :validate_multiple_rows, only: [:after]
    #   after_validate_multiple_rows :after_validate_multiple_rows_callback
    #
    #   def validate_multiple_rows(rows)
    #     run_callbacks :validate_multiple_rows do
    #
    #     end
    #   end
    #
    #   def after_validate_multiple_rows_callback
    #     puts 'AFTERR'
    #   end
    #
    # end

  end

end