require 'filegdb'

TEST_FILE_NAME = 'testfile.gdb'

def data_directory
  File.join(File.dirname(__FILE__), 'data')
end

def table_definition
  File.read(File.join(data_directory, 'table_definition.xml'))
end

def create_database
  FileGDB::Geodatabase.create(TEST_FILE_NAME)
end

def open_database
  FileGDB::Geodatabase.open(TEST_FILE_NAME)
end

def delete_database
  FileGDB::Geodatabase.delete(TEST_FILE_NAME)
end

describe "FileGDB" do
  before(:all) do
    delete_database rescue nil
  end

  after(:each) do
    delete_database rescue nil
  end

  after(:all) do
    delete_database rescue nil
  end

  it 'creates a new gdb' do
    db = create_database
    db.should_not be_nil
    db.close
  end

  it 'opens an existing gdb' do
    db = create_database
    db.close
    db = open_database
    db.should_not be_nil
    db.close
  end

  it 'creates a new table' do
    db = create_database
    table = db.create_table('', table_definition)
    table.should_not be_nil
    db.close
  end

  context 'Row' do
    before(:each) do
      delete_database rescue nil
      @db = create_database
      @table = @db.create_table('', table_definition)
    end

    after(:each) do
      @db.close if @db
      delete_database
    end

    it 'creates a row object' do
      row = @table.create_row_object
      row.should_not be_nil
    end

    it 'sets a string attribute on a row' do
      row = @table.create_row_object
      lambda { row.set_string('string_field', 'a string value') }.should_not raise_error
    end

    it 'throws an error when setting a field that does not exist' do
      row = @table.create_row_object
      lambda { row.set_string('string_field_that_doesnt_exist', 'a string value') }.should raise_error
    end

    it 'retrieves a string field' do
      row = @table.create_row_object
      row.set_string('string_field', 'a string value')
      row.get_string('string_field').should eq('a string value')
    end

    it 'throws an error when retrieving a string field that does not exist' do
      row = @table.create_row_object
      row.set_string('string_field', 'a string value')
      lambda { row.get_string('string_field_that_doesnt_exist') }.should raise_error
    end

    it 'creates a point shape buffer using #new' do
      FileGDB::PointShapeBuffer.new.should_not be_nil
    end

    it 'can setup a geometry' do
      shape = FileGDB::PointShapeBuffer.new
      lambda { shape.setup(1) }.should_not raise_error
    end

    it 'throws an exception when setting up a point shape incorrectly' do
      shape = FileGDB::PointShapeBuffer.new
      lambda { shape.setup(2) }.should raise_error
    end

    it 'fetches the point object after setting it up' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(1)
      shape.get_point.should be_instance_of(FileGDB::Point)
    end

    it 'sets the geometry of a point' do
      row = @table.create_row_object
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(1)
      point = shape.get_point
      point.x = -82.23233;
      point.y = 27.457347347;
      lambda { row.set_geometry(shape) }.should_not raise_error
    end

    it 'throws an exception when setting up the geometry incorrectly' do
      row = @table.create_row_object
      lambda { row.set_geometry(nil) }.should raise_error
    end

    it 'gets the z value' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(9)
      shape.z.should eq(0.0)
    end

    it 'sets the z value' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(9)
      shape.z = 10.0
      shape.z.should eq(10.0)
    end

    it 'gets the m value' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(11)
      shape.m.should eq(0.0)
    end

    it 'sets the m value' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(11)
      shape.m = 10.0
      shape.m.should eq(10.0)
    end

    it 'gets the id value' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(11)
      lambda { shape.id }.should raise_error
    end

    it 'sets the id value' do
      shape = FileGDB::PointShapeBuffer.new
      shape.setup(11)
      lambda { shape.id = 1 }.should raise_error
    end
  end
end
