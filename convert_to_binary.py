def convert_to_binary(decimal_number):
  binary_rep = ""
  quotient = decimal_number / 2
  remainder = decimal_number % 2
  while (quotient != 0):
    if remainder == 0:
      binary_rep = "0" + binary_rep
    else:
      binary_rep = "1" + binary_rep
    remainder = quotient % 2
    quotient = quotient / 2
  if remainder == 0:
    binary_rep = "0" + binary_rep
  else:
    binary_rep = "1" + binary_rep
  return binary_rep

