module utils

// If empty return default.
// Currently works only with int and string types.
pub fn default<T>(might_be_empty T, default_value T) T {
	$if T is int {
		return if might_be_empty != 0 { might_be_empty } else { default_value }
	}

	$if T is string {
		return if might_be_empty != '' { might_be_empty } else { default_value }
	}

	return default_value
}
