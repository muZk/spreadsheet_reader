class UserSpreadsheet < SpreadsheetReader::Row

  attr_accessor :username, :email, :gender

  validates_presence_of :username, :email

  def self.columns
    { :username => 0, :email => 1, :gender => 2 }
  end

end