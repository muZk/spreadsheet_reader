require 'spec_helper'

describe SpreadsheetReader::FileUtils do

  it 'Should read a string filename' do
    name = SpreadsheetReader::FileUtils.original_filename('users.xlsx')
    expect(name).to eq('users.xlsx')
  end

  it 'Should read a File filename' do
    file = File.open(File.join TEST_DIR, 'users.xlsx')
    name = SpreadsheetReader::FileUtils.original_filename(file)
    expect(name).to eq('users.xlsx')
  end

end