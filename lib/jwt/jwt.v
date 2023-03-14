module jwt

import encoding.base64
import json
import x.json2
import time

// encode is a generic function that creates a Json Web Token (JWT) and returns it
// `claims` the payload of the JTW (can be struct you want)
// `algorithm` the algorithm used in order to create the signature
// `secretOrKey` the secret used for creating the signature
pub fn encode<T>(claims T, algorithm Algorithm, secretOrKey string, exp int) ?string {
	// encode header to JSON and then to base64
	header := new_header(algorithm)
	header_b64 := base64.url_encode(json.encode(header).bytes())

	// encode claims
	mut claims_final := json2.raw_decode(json.encode(claims))?.as_map()

	if exp != 0 {
		claims_final['exp'] = time.now().unix_time() + exp
	}

	claims_b64 := base64.url_encode(claims_final.str().bytes())

	// concatenate header & claimns and sign them
	contents := '${header_b64}.$claims_b64'

	// sign with AlgorithmType
	signature := algorithm.sign(contents, secretOrKey)?

	return '${contents}.$signature'
}

// verify is a function that verifies a given token and returns the decoded claims
// `token` the JWT to be verified
// `algorithm` must be the same algorithm which was used when creating the JWT
// `secretOrKey` the secret which was used for creating the signature
pub fn verify<T>(token string, algorithm Algorithm, secretOrKey string) ?T {
	return algorithm.verify(token, secretOrKey)?.parse_claims<T>()
}
