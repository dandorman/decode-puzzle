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

module Decoder
  def decode input
    Translator.new(input).translate
  end

  module_function :decode

  class Translator
    def initialize input
      @input = input.to_s
    end

    def translate
      translations.map(&:output)
    end

    protected

    def translations
      @output ||= [].tap do |output|
        index = 1
        while index <= input.length
          mapping = mapping_for_input_up_to index
          break unless mapping.valid?

          mappings_for_rest_of_input = self.class.new(input[index..-1]).translations

          mappings = combine_mappings mapping, mappings_for_rest_of_input
          mappings.each do |mapping|
            translation = Translation.new(mapping)
            output << translation if translation.valid_for? input
          end

          index += 1
        end
      end
    end

    private

    attr_reader :input

    def mapping_for_input_up_to index
      Mapping.from input[0...index].to_i
    end

    def combine_mappings first, rest
      Array(rest).inject([first]) { |mappings, mapping|
        mappings << [first] + mapping
      }
    end
  end

  class Translation
    def initialize mappings
      @mappings = Array(mappings)
    end

    def to_ary
      mappings.dup
    end

    def valid_for? string
      mappings.map(&:number_string).join == string
    end

    def output
      mappings.map(&:letter).join
    end

    private

    attr_reader :input, :mappings
  end

  class Mapping
    def self.from number
      new number
    end

    attr_reader :number

    def initialize number
      @number = number
    end

    def number_string
      number.to_s
    end

    def letter
      @letter ||= (?a.ord + number - 1).chr
    end

    def valid?
      (1..26) === number
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

  it "includes 'apple' in its results for '11616125'" do
    expect(subject.decode('11616125')).to include 'apple'
  end
end
