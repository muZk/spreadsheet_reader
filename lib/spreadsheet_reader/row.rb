require 'spreadsheet_reader/row/version'
require 'spreadsheet_reader/row/file_utils'
require 'spreadsheet_reader/row/row_collection'
require 'active_model'
require 'active_record'
require 'roo'

module SpreadsheetReader

  class Row

    include ActiveModel::Model

    class MethodNotImplementedError < StandardError; end
    class InvalidTypeError < StandardError; end

    attr_accessor :row_number

    # Copy a ActiveModel::Model errors
    def copy_errors(model)
      model.errors.each do |key, value|
        self.errors[key] = value
      end
    end

    # Defines the starting row of the excel where the class should start reading the data.
    #
    # == Returns:
    # A integer representing the starting row of the data.
    #
    def self.starting_row
      2
    end

    # Defines the columns of the excel that the class will read. This method must return
    # a Array of strings/symbols (representing columns names) or a Hash (which map column names to columns indexes).
    #
    # Array Example
    #   def self.columns
    #     [:username, :email, :gender]
    #   end
    #
    # Hash Example
    #   def self.columns
    #     { :username => 0, :email => 1, :gender => 2 }
    #   end
    #
    # == Returns:
    # An Array or a Hash defining the columns of the excel.
    #
    def self.columns
      fail(
          MethodNotImplementedError,
          'Please implement this method in your class.'
      )
    end

    # Returns the Hash representation of a given array using self.format method
    # (which internally uses self.columns). The keys of this Hash are defined
    # in the self.columns method and the values of each key depends on the
    # order of the columns.
    #
    # For example, given the following self.columns definition
    #   def self.columns
    #     [:username, :email, :gender]
    #   end
    # Or
    #   def self.columns
    #     { :username => 0, :email => 1, :gender => 2 }
    #   end
    # Row.formatted([username email@test.cl male]) will return
    # { username: 'username', email: 'email@test.cl', gender: 'male' }
    #
    # == Parameters:
    # array::
    #   Array of values which represents an excel column.
    #
    # == Returns:
    # Hash representation of the given array which maps columns names to the array values.

    def self.formatted_hash(array)

      if format.keys.count > 0
        parsed_row = {}
        format.each_pair { |key, col| parsed_row[key] = array[col] }
        return parsed_row
      end

      return nil
    end

    # Generalizes the constructor of ActiveModel::Model to make it work
    # with an array argument.
    # When an array argument is passed, it calls formatted_hash method
    # to generate a Hash and then pass it to the ActiveModel::Model constructor
    #
    # == Parameters:
    # arr_or_hash::
    #   Array or Hash of values which represents an excel column.

    def initialize(arr_or_hash = {})
      if arr_or_hash.is_a?(Array)
        super(self.class.formatted_hash(arr_or_hash))
      else
        super(arr_or_hash)
      end
    end

    # This method is called when all rows of row_collection are valid. The main
    # idea of this method is to run validations that have to do with
    # the set of rows of the excel. For example, you can check here if a
    # excel column is unique. It have to raise an exception if there was
    # an error with a certain row.
    #
    # Example:
    #
    # def self.validate_multiple_rows(row_collection)
    #   username_list = []
    #   row_collection.rows.each do |row|
    #     if username_list.include?(row.username)
    #       row_collection.invalid_row = row
    #       row.errors[:username] = 'is unique'
    #       raise 'Validation Error'
    #     else
    #       username_list << row.username
    #     end
    #   end
    # end
    #
    # == Parameters:
    # row_collection::
    #   SpreadsheetReader::RowCollection instance
    def self.validate_multiple_rows(row_collection)

    end

    # This method is called after the self.validate_multiple_rows method
    # only if it have not raised an exception. The idea of this method
    # is to persist the row's data. If there was an error with a certain
    # row, you have to Rollback the valid transactions, set the
    # invalid error to the row_collection and set the row errors to the
    # row object.
    #
    # Example:
    # def self.after_multiple_rows_validation(row_collection)
    #   User.transaction do
    #     row_collection.rows.each do |row|
    #       user = User.new(row.as_json)
    #       unless user.save
    #         row.copy_errors(user) # use copy error to pass the model errors to the row.
    #         row_collection.invalid_row = row
    #         rollback # use the rollback helper to rollback the transaction.
    #       end
    #     end
    #   end
    # end
    #
    # == Parameters:
    # row_collection::
    #   SpreadsheetReader::RowCollection instance
    def self.after_multiple_rows_validation(row_collection)

    end

    def self.open_spreadsheet(spreadsheet_file)
      name = FileUtils.original_filename(spreadsheet_file)
      case File.extname name
        when '.xls' then Roo::Excel.new(spreadsheet_file.path, nil, :ignore)
        when '.xlsx' then Roo::Excelx.new(spreadsheet_file.path, nil, :ignore)
        else false
      end
    end

    # Read and validates the given #spreadsheet_file. First calls
    # #validate_rows method which run #ActiveModel::Model.valid? on each row.
    # Then calls #validate_multiple_rows and finally ends with #after_multiple_rows_validation
    #
    # == Parameters:
    # spreadsheet_file::
    #   File instance
    # == Returns:
    # row_collection::
    #   SpreadsheetReader::RowCollection instance
    def self.read_spreadsheet(spreadsheet_file)

      if columns.empty?
        raise NotImplementedError
      end

      spreadsheet = open_spreadsheet(spreadsheet_file)
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

    # Transform an array [a0, a1, a2, ...] to a Hash { a0 => 0, a1 => 1, etc }
    # which is the format required by the #formatted_hash method.
    def self.array_to_hash(arr)
      Hash[[*arr.map { |e| e.to_sym }.map.with_index]]
    end

    private

    # Calls row.valid? on every row of the spreadsheet. Raises an exception
    # when row_collection.valid? returns false. It happens when
    # the current row is an invalid ActiveModel::Model.
    def self.validate_rows(spreadsheet, row_collection)
      (starting_row..spreadsheet.last_row).each do |number|
        hash = formatted_hash(spreadsheet.row(number))
        hash[:row_number] = number
        row_collection.push self.new(hash)
        raise 'Invalid Row in Excel' unless row_collection.valid?
      end
    end

    # Returns the Hash representation of the defined columns
    def self.format

      if columns.is_a?(Array) or columns.is_a?(Hash)
        return columns.is_a?(Array) ? array_to_hash(columns) : columns
      end

      fail(
          InvalidTypeError,
          'Please check that the self.columns implementation returns a instance of Hash or Array.'
      )

    end

    # Helper for rollbacks inside #after_multiple_row_validations
    def self.rollback
      raise ActiveRecord::Rollback
    end

  end

end