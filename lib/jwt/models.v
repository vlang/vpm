module jwt

import json
import x.json2
import time
import encoding.base64

// JWTHeader represents the JWT Header contents
// it can be created using the `new_header` function
pub struct JWTHeader {
pub:
	alg string
	typ string = 'JWT'
}

// new_header creates a new object of the JWTHeader struct
fn new_header(algorithm Algorithm) JWTHeader {
	return JWTHeader{
		alg: algorithm.name.str().to_upper()
	}
}

// Token holds all information of a JWT
// it is created using the `parse_token` function
struct Token {
pub:
	header     JWTHeader
	claims     string
	signature  string
	expiration int
}

// parse_claims is a generic function that parses the claims of token
// into a real struct
pub fn (t Token) parse_claims[T]() !T {
	return json.decode(T, t.claims)
}

// is_expired gives information about whether the token is expired or still valid
pub fn (t Token) is_expired() bool {
	// if not setted
	if t.expiration == -1 {
		return false
	}

	return time.unix(t.expiration) < time.now()
}

// parse_token takes a JWT string and creates a Token object
// if the given token ius invalid, an error will be thrown
pub fn parse_token(token_raw string) ?Token {
	// split token
	parts := token_raw.split('.')

	// split token into different parts and create token struct
	if parts.len != 3 {
		return error('Invalid token')
	}

	// get header and add "==" if necessary in order to make the base64 string decodable
	header_raw := if parts[0].len % 4 == 0 { parts[0] } else { parts[0] + '==' }

	// get claims and add "==" if necessary in order to make the base64 string decodable
	claims_raw := if parts[1].len % 4 == 0 { parts[1] } else { parts[1] + '==' }

	// decode header & claims base64 string
	decoded_header := base64.decode_str(header_raw)
	decoded_claims := base64.decode_str(claims_raw)

	// create a raw json object from the claims in order to check for the expiration
	claims := json2.raw_decode(decoded_claims)?.as_map()

	mut expiration_given := true

	// check if the expiration timestamp was set
	expiration_unix := claims['exp'] or {
		expiration_given = false
		json2.Null{}
	}

	token := Token{
		header: json.decode(JWTHeader, decoded_header)?
		claims: decoded_claims
		signature: parts[2]
		// set expiration if given, otherwise use -1 for unset
		expiration: if expiration_given { expiration_unix.int() } else { -1 }
	}

	return token
}
