def evaluate_binary(binary_string):
  index = len(binary_string) - 1
  value = 0
  for c in binary_string:
    value += 2 ** index if c == '1' else 0
    index -= 1
  return value
