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

require 'rspec'

def decode input
  helper = -> input do
    [].tap do |output|
      raise 'leading zero' if input[0] == '0'

      last_char_index = 1
      while last_char_index <= input.length
        begin
          first_digits = input[0...last_char_index].to_i
          break unless (1..26) === first_digits

          first_chars = ('a'.ord + first_digits - 1).chr
          suffixes = helper.call(input[last_char_index..-1])
          if suffixes.empty?
            output << first_chars
          else
            suffixes.each do |suffix|
              output << "%s%s" % [first_chars, suffix]
            end
          end
        rescue
          # do nothing
        ensure
          last_char_index += 1
        end
      end
    end
  end

  helper[input.to_s]
rescue
  []
end

describe 'decode' do
  it "returns [] for ''" do
    expect(decode('')).to eq []
  end

  it "returns ['a'] for '1'" do
    expect(decode('1')).to eq ['a']
  end

  it "returns ['aa', 'k'] for '11'" do
    expect(decode('11')).to eq ['aa', 'k']
  end

  it "returns ['je'] for '105'" do
    expect(decode('105')).to eq ['je']
  end

  it "returns ['bage', 'bqe', 'uge'] for '2175'" do
    expect(decode('2175')).to eq ['bage', 'bqe', 'uge']
  end

  it "returns ['bbbb', 'bbv', 'bvb', 'vbb', 'vv'] for '2175'" do
    expect(decode('2222')).to eq ['bbbb', 'bbv', 'bvb', 'vbb', 'vv']
  end

  it "returns [] for '0000'" do
    expect(decode('0000')).to eq []
  end
end
