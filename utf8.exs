# binary number
# IO.puts 0b101

# print decimal number as binary
# IO.puts Integer.to_string(12, 2)
# or
# IO.puts inspect(12, base: :binary)

# IO.puts byte_size("愛")
# IO.puts bit_size("愛")

# IO.puts ?h
# IO.puts inspect(?h, base: :binary)

# IO.puts inspect(?Ш, base: :binary)
# IO.puts inspect(?愛, base: :binary)

# BINARIES

# IO.puts <<>> == ""

# packing bytes into a binary (string)
# IO.puts << 104 :: size(8), 101 :: size(8), 108 :: size(8), 108 :: size(8), 111 :: size(8) >>

# IO.puts << 104, 101, "ll", 0b1101111 >>

# there are many size expression
# a = 4.234
# IO.inspect << a :: size(64)-float-little >>

# concatenate two binaries:
# a = << 0b00100000, 0b11100110 >>
# b = << 0b10000100, 0b10011011, 0b00100000 >>
# IO.inspect << a :: bitstring, b :: bitstring >>


# BINARY PATTERN-MATCHING

# << first_byte :: size(8),  second_byte :: size(8) >> = "Щ"
# IO.puts first_byte
# IO.puts second_byte

# If you don't want to match the whole binary
# << first_byte :: size(8),  _rest :: bitstring >> = "Щ"
# IO.puts first_byte

# Get bits out of a byte
# <<  first_three :: size(3), rest :: size(5) >>  = << 0b10100001 >>
# IO.inspect(first_three, base: :binary)
# IO.inspect(rest, base: :binary)

# defmodule Ascii do
#   def is_ascii_char?(<< 0b0 :: size(1) , _rest :: size(7) >>), do: true
#   def is_ascii_char?(_), do: false
# end

# IO.inspect Ascii.is_ascii_char?("a")
# IO.inspect Ascii.is_ascii_char?(<< 0b10100001 >>)


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

defmodule UTF8 do

  def valid?(bytes) do
  end

  def extract_utf(bytes) do
  end
end
