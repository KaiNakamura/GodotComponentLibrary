class_name StringFormatter extends Object

static func big_int_to_string(value: int) -> String:
	# Handle large numbers with suffixes
	if value >= 1e18:
		return String.num_scientific(value)
	elif value >= 1e15:
		return str(snapped(value / 1e15, 0.1)) + "Q"  # Quadrillion
	elif value >= 1e12:
		return str(snapped(value / 1e12, 0.1)) + "T"  # Trillion
	elif value >= 1e9:
		return str(snapped(value / 1e9, 0.1)) + "B"   # Billion
	elif value >= 1e6:
		return str(snapped(value / 1e6, 0.1)) + "M"   # Million
	elif value >= 1e3:
		return str(snapped(value / 1e3, 0.1)) + "k"   # Thousand
	
	# For values between 1 and 999, show no decimal places
	return str(value)

static func big_float_to_string(value: float) -> String:
	# Handle large numbers with suffixes
	if value >= 1e18:
		return String.num_scientific(value)
	elif value >= 1e15:
		return str(snapped(value / 1e15, 0.1)) + "Q"  # Quadrillion
	elif value >= 1e12:
		return str(snapped(value / 1e12, 0.1)) + "T"  # Trillion
	elif value >= 1e9:
		return str(snapped(value / 1e9, 0.1)) + "B"   # Billion
	elif value >= 1e6:
		return str(snapped(value / 1e6, 0.1)) + "M"   # Million
	elif value >= 1e3:
		return str(snapped(value / 1e3, 0.1)) + "k"   # Thousand
	
	# For values less than 1, show up to two decimal places
	if value < 1:
		var rounded_value = snapped(value, 0.01)
		var value_str = str(rounded_value)
		if value_str.find(".") != -1:
			value_str = value_str.rstrip("0").rstrip(".")
		return value_str
	
	# For values between 1 and 999, show no decimal places
	return str(int(value))
