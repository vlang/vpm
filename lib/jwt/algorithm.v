module jwt

// Algorithm is the interface every JWT Signature algorithm has to implement
// you can also implement your own signing algorithm -> just implement this interface
pub interface Algorithm {
	// the name of the algorithm used for creating the signature (is contained inside the JWT Header (Property: `alg`))
	name string

	// sign creates the signed JWT
	// `contents` actual data of the JWT (Header & Claims)
	// `secretOrKey` the secret or private for creating the signature
	sign(contents string, secretOrKey string) ?string

	// verify decodes and validates a given token
	// `token` the token to be decoded
	// `secretOrKey` the secret or private which was used for creating the signature
	verify(token string, secretOrKey string) ?Token
}

// AlgorithmType contains all signature algorithms included in this library
pub enum AlgorithmType {
	hs256
}

// new_algorithm creates a new algorithm
// `algorithmType` the type of signature hashing the algorithm will be using
pub fn new_algorithm(algorithmType AlgorithmType) Algorithm {
	match algorithmType {
		.hs256 {
			return HS256{}
		}
	}
}