require 'ostruct'
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
  # simplecov not installed
end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'sort_by_field'))

describe SortByField do

  it "should sort an array by a field on the elements" do
    e1 = OpenStruct.new(:val => 1)
    e2 = OpenStruct.new(:val => 2)
    e3 = OpenStruct.new(:val => 3)
    e4 = OpenStruct.new(:val => 4)
    [e3, e1, e4, e2].sort_by_field(:val).should == [e1, e2, e3, e4]
    [e3, e1, e4, e2].sort_by_field('val').should == [e1, e2, e3, e4]
  end

  it "should cache field value per object and not call them multiple times" do
    e1 = mock(:e1)
    e2 = mock(:e2)
    e3 = mock(:e3)
    e4 = mock(:e4)
    val1 = mock(:val1)
    val2 = mock(:val2)
    val3 = mock(:val3)
    val4 = mock(:val4)
    e1.should_receive(:val).and_return(val1)
    e2.should_receive(:val).and_return(val2)
    e3.should_receive(:val).and_return(val3)
    e4.should_receive(:val).and_return(val4)
    val1.should_receive(:value).and_return(1)
    val2.should_receive(:value).and_return(2)
    val3.should_receive(:value).and_return(3)
    val4.should_receive(:value).and_return(4)
    [e3, e1, e4, e2].sort_by_field('val.value').should == [e1, e2, e3, e4]
  end

  it "should be able to specify field on fields with either an array or a string" do
    e1 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'))
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'))
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'c'))
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'd'))
    [e2, e1, e4, e3].sort_by_field([:val, :name]).should == [e1, e2, e3, e4]
    [e2, e1, e4, e3].sort_by_field('val.name').should == [e1, e2, e3, e4]
  end

  it "should be able to specify multiple fields as tie breakers" do
    e1 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'), :tie => 1)
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'), :tie => 2)
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'), :tie => 1)
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'), :tie => 2)
    [e2, e1, e4, e3].sort_by_field([:val, :name], 'tie').should == [e1, e2, e3, e4]
  end

  it "should handle nils and sort them first" do
    e1 = OpenStruct.new(:val => nil)
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'))
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'c'))
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'd'))
    [e2, e1, e4, e3].sort_by_field([:val, :name]).should == [e1, e2, e3, e4]
    [e2, nil, e4, e3].sort_by_field([:val, :name]).should == [nil, e2, e3, e4]
  end

  it "should handle nils and sort them last" do
    e1 = OpenStruct.new(:val => nil)
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'))
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'c'))
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'd'))
    [e2, nil, e4, e3].sort_by_field([:val, :name], :nil_last => true).should == [e2, e3, e4, nil]
  end

  it "should sort string case insensitive by default" do
    e1 = OpenStruct.new(:name => 'a')
    e2 = OpenStruct.new(:name => 'B')
    e3 = OpenStruct.new(:name => 'c')
    e4 = OpenStruct.new(:name => 'D')
    [e2, e1, e4, e3].sort_by_field(:name).should == [e1, e2, e3, e4]
  end

  it "should be able to sort string case sensitive" do
    e1 = OpenStruct.new(:name => 'a')
    e2 = OpenStruct.new(:name => 'B')
    e3 = OpenStruct.new(:name => 'c')
    e4 = OpenStruct.new(:name => 'D')
    [e2, e3, e4, e1].sort_by_field(:name, :case_sensitive => true).should == [e2, e4, e1, e3]
  end

  it "should be able to sort in descending order" do
    e1 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'))
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'))
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'c'))
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'd'))
    [e2, e1, e4, e3].sort_by_field([:val, 'name desc']).should == [e4, e3, e2, e1]
    [e2, e1, e4, e3].sort_by_field('val.name DESC').should == [e4, e3, e2, e1]

    e1 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'), :tie => 1)
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'), :tie => 2)
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'), :tie => 1)
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'), :tie => 2)
    [e1, e2, e3, e4].sort_by_field([:val, :name], 'tie desc').should == [e2, e1, e4, e3]
  end

  it "should be able to sort in ascending order" do
    e1 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'))
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'))
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'c'))
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'd'))
    [e2, e1, e4, e3].sort_by_field([:val, 'name ASC']).should == [e1, e2, e3, e4]
    [e2, e1, e4, e3].sort_by_field('val.name ascending').should == [e1, e2, e3, e4]

    e1 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'), :tie => 1)
    e2 = OpenStruct.new(:val => OpenStruct.new(:name => 'a'), :tie => 2)
    e3 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'), :tie => 1)
    e4 = OpenStruct.new(:val => OpenStruct.new(:name => 'b'), :tie => 2)
    [e4, e3, e2, e1].sort_by_field([:val, :name], 'tie asc').should == [e1, e2, e3, e4]
  end

  it "should be able to sort by multiple orders with multiple chained relationships" do
    type1 = OpenStruct.new(:sticky => "true", :name => ".fileType", :weight => 0, :group => OpenStruct.new(:weight => 50))
    type2 = OpenStruct.new(:sticky => "false", :name => ".thumbMaxWidth", :weight => 0, :group => OpenStruct.new(:weight => 50))
    type3 = OpenStruct.new(:sticky => "true", :name => "Param Name", :weight => 5, :group => OpenStruct.new(:weight => 45))
    type4 = OpenStruct.new(:sticky => "false", :name => "Onclick", :weight => 10, :group => OpenStruct.new(:weight => 40))

    e1 = OpenStruct.new(:ex_type => type1)
    e2 = OpenStruct.new(:ex_type => type2)
    e3 = OpenStruct.new(:ex_type => type3)
    e4 = OpenStruct.new(:ex_type => type4)

    [e4,e2,e3,e1].sort_by_field("ex_type.sticky desc", "ex_type.group.weight", "ex_type.weight desc", "ex_type.name").should == [e3, e1, e4, e2]
    [e4,e2,e3,e1].sort_by_field("ex_type.sticky desc", [:ex_type, :group, :weight], "ex_type.weight desc", [:ex_type, :name]).should == [e3, e1, e4, e2]
  end
end
