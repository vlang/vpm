module jwt

import crypto.hmac
import crypto.sha256
import encoding.base64

// HS256 implementation of the HS256 signing algorithm for JWTs
pub struct HS256 {
pub:
	name string = 'HS256'
}

// sign creates the signed JWT
// `contents` actual data of the JWT (Header & Claims)
// `secretOrKey` the secret or private for creating the signature
pub fn (algorithm HS256) sign(content string, secret string) ?string {
	signature := base64.url_encode(hmac.new(secret.bytes(), content.bytes(), sha256.sum,
		sha256.block_size))
	return signature
}

// verify decodes and validates a given token
// `token` the token to be decoded
// `secretOrKey` the secret or private which was used for creating the signature
pub fn (algorithm HS256) verify(token_raw string, secret string) ?Token {
	token := parse_token(token_raw)?

	// sign destructed header & claims
	parts := token_raw.split('.')
	header := parts[0]
	claims := parts[1]
	signed := algorithm.sign('${header}.$claims', secret)?

	// check if token signature is valid by checking the created signature against the given signature from the given token
	if signed != token.signature {
		return error('Invalid token')
	}

	// validate the expiration
	if token.is_expired() {
		return error('Token already expired')
	}

	return token
}
