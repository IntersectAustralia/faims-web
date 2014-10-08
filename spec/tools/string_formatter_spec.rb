require 'spec_helper'

describe StringFormatter do

  describe 'parse string format' do

    it 'should parse no statements' do
      StringFormatter.new('Hello world').pre_compute.evaluate(['world']).should == 'Hello world'
    end

    it 'should parse no statements with variables' do
      StringFormatter.new('Hello $1').pre_compute.evaluate(['world']).should == 'Hello world'
    end

    it 'should parse single statements' do
      StringFormatter.new('Hello {{ if "world" then "world" }}').pre_compute.evaluate(['world']).should == 'Hello world'
    end

    it 'should parse single statements with variables' do
      StringFormatter.new('Hello {{ if $1 then $1 }}').pre_compute.evaluate(['world']).should == 'Hello world'
    end

    it 'should parse multiple statements' do
      StringFormatter.new('{{ if "Hello" then "Hello" }} {{ if $1 then $1 }}').pre_compute.evaluate(['world']).should == 'Hello world'
    end

    it 'should parse multiple statements with variables' do
      StringFormatter.new('{{ if $2 then $2 }} {{ if $1 then $1 }}').pre_compute.evaluate(%w(world Hello)).should == 'Hello world'
    end

  end

  describe 'parse program' do

    it 'should parse if statement' do
      $argument_mapper = ArgumentMap.new([1, 'test'])
      Statement::Parser.new(Statement::Lexer.new('if equal($1,1) then $2')).program.value.should == 'test'
      Statement::Parser.new(Statement::Lexer.new('if equal($2,"test") then $2')).program.value.should == 'test'
      Statement::Parser.new(Statement::Lexer.new('if equal($1,2) then $2')).program.value.should == nil
    end

    it 'should parse if else statement' do
      $argument_mapper = ArgumentMap.new([1, 'test', 'foobar'])
      Statement::Parser.new(Statement::Lexer.new('if equal($1,0) then $2 else $3')).program.value.should == 'foobar'
    end

    it 'should parse if elsif statement' do
      $argument_mapper = ArgumentMap.new([1, 'test', 'foobar'])
      Statement::Parser.new(Statement::Lexer.new('if equal($1,0) then $1 elsif $1 then $2 else $3')).program.value.should == 'test'
    end

    it 'should parse if elsif else statement' do
      $argument_mapper = ArgumentMap.new([1, 'test', 'foobar'])
      Statement::Parser.new(Statement::Lexer.new('if equal($1,0) then $1 elsif not($1) then "what?" elsif $1 then $2 else $3')).program.value.should == 'test'
    end

    it 'should parse and expression' do
      $argument_mapper = ArgumentMap.new([1, 'test'])
      Statement::Parser.new(Statement::Lexer.new('and(equal($1,1),equal($2,"test"))')).multi_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('and(equal($1,0),equal($2,"test"))')).multi_expression.value.should be_false
    end

    it 'should parse or expression' do
      $argument_mapper = ArgumentMap.new([1, 'test'])
      Statement::Parser.new(Statement::Lexer.new('or(equal($1,1),equal($2,"test"))')).multi_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('or(equal($1,0),equal($2,"test"))')).multi_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('or(equal($1,0),equal($2,"test2"))')).multi_expression.value.should be_false
    end

    it 'should parse and or expression' do
      $argument_mapper = ArgumentMap.new([1, 'test'])
      Statement::Parser.new(Statement::Lexer.new('and(equal($1,1), or(equal($1,0),equal($2,"test")))')).multi_expression.value.should be_true
    end

    it 'should parse equal expression' do
      $argument_mapper = ArgumentMap.new([1, 'test'])
      Statement::Parser.new(Statement::Lexer.new('equal($1,1)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('equal($1,2)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('equal($2,"test")')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('equal($2,"foobar")')).single_expression.value.should be_false
    end

    it 'should parse greaterThan expression' do
      $argument_mapper = ArgumentMap.new([1, '2'])
      Statement::Parser.new(Statement::Lexer.new('greaterThan($1,0)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('greaterThan($1,1)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('greaterThan($2,1)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('greaterThan($2,2)')).single_expression.value.should be_false
    end

    it 'should parse greaterThanEqual expression' do
      $argument_mapper = ArgumentMap.new([1, '2'])
      Statement::Parser.new(Statement::Lexer.new('greaterThanEqual($1,1)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('greaterThanEqual($1,2)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('greaterThanEqual($2,2)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('greaterThanEqual($2,3)')).single_expression.value.should be_false
    end

    it 'should parse lessThan expression' do
      $argument_mapper = ArgumentMap.new([1, '2'])
      Statement::Parser.new(Statement::Lexer.new('lessThan($1,2)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('lessThan($1,1)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('lessThan($2,3)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('lessThan($2,2)')).single_expression.value.should be_false
    end

    it 'should parse lessThanEqual expression' do
      $argument_mapper = ArgumentMap.new([1, '2'])
      Statement::Parser.new(Statement::Lexer.new('lessThanEqual($1,1)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('lessThanEqual($1,0)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('lessThanEqual($2,2)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('lessThanEqual($2,1)')).single_expression.value.should be_false
    end

    it 'should parse in expression' do
      Statement::Parser.new(Statement::Lexer.new('in("test1", ["test1", "test2", "test3"])')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('in("test4", ["test1", "test2", "test3"])')).single_expression.value.should be_false
    end

    it 'should parse between expression' do
      $argument_mapper = ArgumentMap.new([1, '5', 3, 0, 10])
      Statement::Parser.new(Statement::Lexer.new('between($1, 1, 5)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('between($2, 1, 5)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('between($3, 1, 5)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('between($4, 1, 5)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('between($5, 1, 5)')).single_expression.value.should be_false
    end

    it 'should parse literal expression' do
      $argument_mapper = ArgumentMap.new([1, '2', nil])
      Statement::Parser.new(Statement::Lexer.new('$1')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('$2')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('$3')).single_expression.value.should be_false
    end

    it 'should parse not expression' do
      $argument_mapper = ArgumentMap.new([1, '2', nil])
      Statement::Parser.new(Statement::Lexer.new('not($1)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not($2)')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not($3)')).single_expression.value.should be_true
      Statement::Parser.new(Statement::Lexer.new('not(equal($1,1))')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not(greaterThan($1,0))')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not(greaterThanEqual($1,1))')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not(lessThan($1,2))')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not(lessThanEqual($1,1))')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not(in("test1", ["test1", "test2", "test3"]))')).single_expression.value.should be_false
      Statement::Parser.new(Statement::Lexer.new('not(between($1, 1, 5))')).single_expression.value.should be_false
    end

    it 'should parse int literal' do
      Statement::Parser.new(Statement::Lexer.new('1.01')).literal.value.should == 1.01
      Statement::Parser.new(Statement::Lexer.new('-1.01')).literal.value.should == -1.01
    end

    it 'should parse number literal' do
      Statement::Parser.new(Statement::Lexer.new('1')).literal.value.should == 1
      Statement::Parser.new(Statement::Lexer.new('-1')).literal.value.should == -1
    end

    it 'should parse string literal' do
      Statement::Parser.new(Statement::Lexer.new('"This is a test"')).literal.value.should == 'This is a test'
      Statement::Parser.new(Statement::Lexer.new("'This is a test'")).literal.value.should == 'This is a test'
    end

    it 'should parse variable literal' do
      $argument_mapper = ArgumentMap.new(['This is a test'])
      Statement::Parser.new(Statement::Lexer.new('$1')).literal.value.should == 'This is a test'
    end

  end

end