# The genius of UTF8:
#
# 0xxxxxxx
# 110xxxxx 10xxxxxx
# 1110xxxx 10xxxxxx 10xxxxxx
# 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
#
# * Backward compatibility
# * Single bytes (0xxxxxxx), leading bytes (11xxxxxx), and continuation bytes (10xxxxxx) do not share values
# * The number of high-order 1s in the leading byte of a multi-byte sequence indicates the number of bytes in the sequence.

Code.load_file("utf8.exs")
ExUnit.start

defmodule UTF8Test do
  use ExUnit.Case, async: true

  test "empty string is valid UTF8" do
    bytes = []
    assert UTF8.valid?(bytes)
    assert UTF8.extract_utf(bytes) == ""
  end

  test "validate ASCII/UTF8" do
    bytes = [
      #   0xxxxxxx
        0b00100000,                        # space
        0b01010101,                        # U
        0b01010011,                        # S
        0b01000001,                        # A
        0b00100000                        # space
    ]
    assert UTF8.valid?(bytes)
  end

  test "validate ASCII and two-byte UTF" do
    bytes = [
      #   0xxxxxxx
      #   110xxxxx    10xxxxxx
        0b11010000, 0b10111111,            # п
        0b11010001, 0b10000000,            # р
        0b11010000, 0b10111000,            # и
        0b11010000, 0b10110010,            # в
        0b11010000, 0b10110101,            # е
        0b11010001, 0b10000010,            # т
        0b00100000,                        # space
        0b01010101,                        # U
        0b01010011,                        # S
        0b01000001                         # A
    ]
    assert UTF8.valid?(bytes)
  end

  test "validate 1-3 byte codepoints" do
    bytes = [
      #   0xxxxxxx
      #   110xxxxx    10xxxxxx
      #   1110xxxx    10xxxxxx    10xxxxxx
        0b11010000, 0b10111111,            # п
        0b11010001, 0b10000000,            # р
        0b11010000, 0b10111000,            # и
        0b11010000, 0b10110010,            # в
        0b11010000, 0b10110101,            # е
        0b11010001, 0b10000010,            # т
        0b00100000,                        # space
        0b01010101,                        # U
        0b01010011,                        # S
        0b01000001,                        # A
        0b00100000,                        # space
        0b11100110, 0b10000100, 0b10011011 # 愛
    ]
    assert UTF8.valid?(bytes)
  end

  test "validate 1-4 byte codepoints" do
    bytes = [
      #   0xxxxxxx
      #   110xxxxx    10xxxxxx
      #   1110xxxx    10xxxxxx    10xxxxxx
      #   11110xxx    10xxxxxx    10xxxxxx    10xxxxxx
        0b11010000, 0b10111111,                        # п
        0b11010001, 0b10000000,                        # р
        0b11010000, 0b10111000,                        # и
        0b11010000, 0b10110010,                        # в
        0b11010000, 0b10110101,                        # е
        0b11010001, 0b10000010,                        # т
        0b00100000,                                    # space
        0b01010101,                                    # U
        0b01010011,                                    # S
        0b01000001,                                    # A
        0b00100000,                                    # space
        0b11100110, 0b10000100, 0b10011011,            # 愛
        0b00100000,                                    # space
        0b11110000, 0b10011111, 0b10010010, 0b10101001 # 💩

    ]
    assert UTF8.valid?(bytes)
  end

  test "some invalid bitstring is not UTF8" do
    bytes = [0b10110010, 0b10111010, 0b10110010, 0b10110011]
    assert ! UTF8.valid?(bytes)
  end

  test "extract ASCII/UTF8" do
    bytes = [
      #   0xxxxxxx
        0b00100000,                        # space
        0b01010101,                        # U
        0b01010011,                        # S
        0b01000001,                        # A
        0b00100000                         # space
    ]
    assert UTF8.extract_utf(bytes) == " USA "
  end

  test "extract UTF8" do
    bytes = [
      #   0xxxxxxx
      #   110xxxxx    10xxxxxx
      #   1110xxxx    10xxxxxx    10xxxxxx
      #   11110xxx    10xxxxxx    10xxxxxx    10xxxxxx
        0b11010000, 0b10111111,                        # п
        0b11010001, 0b10000000,                        # р
        0b11010000, 0b10111000,                        # и
        0b11010000, 0b10110010,                        # в
        0b11010000, 0b10110101,                        # е
        0b11010001, 0b10000010,                        # т
        0b00100000,                                    # space
        0b01010101,                                    # U
        0b01010011,                                    # S
        0b01000001,                                    # A
        0b00100000,                                    # space
        0b11100110, 0b10000100, 0b10011011,            # 愛
        0b00100000,                                    # space
        0b11110000, 0b10011111, 0b10010010, 0b10101001 # 💩
    ]
    assert UTF8.extract_utf(bytes) == "привет USA 愛 💩"
  end

  test "try to find unicode codepoints among garbage" do
    bytes = [
      0b10000000,                                    # this is a continuation byte in UTF8, it cannot start a codepoint
      0b11010000, 0b10111111,                        # п
      0b11010001, 0b10000000,                        # р
      0b11010000, 0b10111000,                        # и
      0b10000000,                                    # this is a continuation byte in UTF8, it cannot start a codepoint
      0b11010000, 0b10110010,                        # в
      0b11010000,                                    # first byte of "е"
           0b11011111,                               # this byte starts a UTF8 codepoint, it cannot be here
                  0b10110101,                        # second byte of "е"
      0b11010001, 0b10000010,                        # т
      0b00100000,                                    # space
      0b01010101,                                    # U
      0b01010011,                                    # S
      0b01000001,                                    # A
      0b00100000,                                    # space
      0b11100110, 0b10000100, 0b10011011,            # 愛
      0b00100000,                                    # space
      0b11110000, 0b10011111, 0b10010010, 0b10101001 # 💩
    ]
    assert ! UTF8.valid?(bytes)
    assert UTF8.extract_utf(bytes) == "привет USA 愛 💩"
  end
end
