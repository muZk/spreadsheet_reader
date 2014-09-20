require 'spec_helper'
require_relative 'models/user_spreadsheet'
require_relative 'models/user_invalid_spreadsheet'

def test_file(filename, ext)
  File.open(File.join TEST_DIR, "#{filename}.#{ext}")
end

describe SpreadsheetReader::Row do

  it 'Row#columns' do
    expect { SpreadsheetReader::Row.columns }.to raise_error
  end

  it 'Row#format' do
    expect { SpreadsheetReader::Row.format }.to raise_error
  end

  it 'Row#formatted_hash' do
    expect { SpreadsheetReader::Row.formatted_hash(%w(username email@test.com male)) }.to raise_error
  end

  it 'Row#valid? should work as desired' do
    expect(SpreadsheetReader::Row.new.valid?).to eq(true)
  end

  it 'Row#open_spreadsheet' do
    file = test_file 'users', :xlsx
    row = SpreadsheetReader::Row.open_spreadsheet file
    expect(row).not_to eq(false)
  end

  it 'Row#read_spreadsheet' do
    file = test_file 'users', :xlsx
    expect { SpreadsheetReader::Row.read_spreadsheet(file) }.to raise_error
  end

  it '#formatted_hash should work in a derived class which overrides "columns" method' do
    formatted_hash = UserSpreadsheet.formatted_hash %w(username email@test.com male)
    expect(formatted_hash).to eq({ username: 'username', email: 'email@test.com', gender: 'male' })

    formatted_hash = UserSpreadsheet.formatted_hash %w(username male email@test.com)
    expect(formatted_hash).not_to eq({ username: 'username', email: 'email@test.com', gender: 'male' })
  end

  it '#new from derived class' do
    user_spreadsheet = UserSpreadsheet.new(%w(username email@test.com male))
    expect(user_spreadsheet.username).to eq('username')
    expect(user_spreadsheet.email).to eq('email@test.com')
    expect(user_spreadsheet.gender).to eq('male')

    user_spreadsheet = UserSpreadsheet.new({ email: 'email@test.com', gender: 'male', username: 'username' })
    expect(user_spreadsheet.username).to eq('username')
    expect(user_spreadsheet.email).to eq('email@test.com')
    expect(user_spreadsheet.gender).to eq('male')
  end

  it '#valid? should work as desired (derived class)' do
    valid_user_spreadsheet = UserSpreadsheet.new({ email: 'email@test.com', gender: 'male', username: 'username' })
    expect(valid_user_spreadsheet.valid?).to eq(true)

    invalid_user_spreadsheet = UserSpreadsheet.new({ gender: 'male', username: 'username' })
    expect(invalid_user_spreadsheet.valid?).to eq(false)
  end

  it '#read_spreadsheet should be invalid because a row is not valid' do
    file = test_file 'users_invalid', :xlsx
    row_collection = UserSpreadsheet.read_spreadsheet(file)
    expect(row_collection.valid?).to eq(false)
    expect(row_collection.invalid_row.row_number).to eq(7)
    expect(row_collection.errors.full_messages).to eq(["Email can't be blank"])
  end

  it '#read_spreadsheet should be invalid because #validate_multiple_rows raises an exception' do
    file = test_file 'users_invalid', :xlsx
    row_collection = UserInvalidSpreadsheet.read_spreadsheet(file)
    expect(row_collection.valid?).to eq(false)
    expect(row_collection.invalid_row.row_number).to eq(5)
    expect(row_collection.errors.full_messages).to eq(['Username is unique'])
  end

end