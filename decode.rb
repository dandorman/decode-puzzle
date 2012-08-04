# Numbers are assigned to each letter of the alphabet, where a=1, b=2, ..., 
# z=26. A word can then be encoded based on those numbers, so for example 
# "apple" is encoded as "11616125". However, "11616125" can also be decoded to 
# many other strings, such as "kfafay" (11 6 1 6 1 25) and "aafple" (1 1 6 16 12 
# 5).
#
# Letters are never encoded with a leading 0. So '105' only has a single valid 
# decoding, (10 5) = 'je'. You could not decode it (1 05) = 'ae'.
#
# Write a function that takes a string as input, such as "11616125", and returns 
# an array of all possible decodings of that string. Here are some examples of 
# input and correct output:
#
#     decode('105') returns array('je')
#     decode('2175') returns array('bage', 'bqe', 'uge')
#     decode('2222') returns array('bbbb','bbv','bvb','vbb','vv')
#     decode('0000') returns array()

class Mapping
  def self.from digits, options = {}
    new digits, options.fetch(:to)
  end

  attr_reader :digits, :char

  def initialize digits, char
    @digits = digits
    @char = char.to_s
  end

  def digit_string
    digits.to_s
  end
end

class Translation
  def initialize input, mappings
    @input = input.to_s
    @mappings = Array(mappings)
  end

  def to_ary
    mappings.dup
  end

  def valid?
    mappings.map(&:digit_string).join == input
  end

  def output
    mappings.map(&:char).join
  end

  private

  attr_reader :input, :mappings
end

class Decoder
  def decode input
    helper(input.to_s).select(&:valid?).map(&:output)
  end

  private

  def helper input
    [].tap do |output|
      last_char_index = 1
      while last_char_index <= input.length
        first_digits = input[0...last_char_index].to_i
        break unless valid_number? first_digits

        first_chars = charify first_digits
        mapping = Mapping.from first_digits, to: first_chars

        suffixes = helper input[last_char_index..-1]
        add_output input, output, mapping, suffixes

        last_char_index += 1
      end
    end
  end

  def valid_number? number
    (1..26) === number
  end

  def charify number
    ('a'.ord + number - 1).chr
  end

  def add_output input, output, mapping, suffixes
    if suffixes.empty?
      output << Translation.new(input, mapping)
    else
      suffixes.each do |suffix|
        output << Translation.new(input, [mapping] + suffix)
      end
    end
  end
end

require 'rspec'

describe Decoder do
  it "returns [] for ''" do
    expect(subject.decode('')).to eq []
  end

  it "returns ['a'] for '1'" do
    expect(subject.decode('1')).to eq ['a']
  end

  it "returns ['aa', 'k'] for '11'" do
    expect(subject.decode('11')).to eq ['aa', 'k']
  end

  it "returns ['je'] for '105'" do
    expect(subject.decode('105')).to eq ['je']
  end

  it "returns ['bage', 'bqe', 'uge'] for '2175'" do
    expect(subject.decode('2175')).to eq ['bage', 'bqe', 'uge']
  end

  it "returns ['bbbb', 'bbv', 'bvb', 'vbb', 'vv'] for '2175'" do
    expect(subject.decode('2222')).to eq ['bbbb', 'bbv', 'bvb', 'vbb', 'vv']
  end

  it "returns [] for '0000'" do
    expect(subject.decode('0000')).to eq []
  end
end
