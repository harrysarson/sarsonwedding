import * as D from 'io-ts/Decoder';
import {pipe} from 'fp-ts/function';
import {fold} from 'fp-ts/Either';

const my_crypto: Crypto = (() => {
	if (typeof window === 'undefined') {
		return require('crypto').webcrypto;
	} else {
		return window.crypto;
	}
})();

export const WANTED_HASH2 = '437f1fcfc1347fab43f0ac82d6403e7e121fd96ad6016a48a754257154d1afd8';

export const Info = D.type({
	pages: D.array(D.type({name: D.string, text: D.string})),
	rsvpUrl: D.string,
});

export type Info = D.TypeOf<typeof Info>;

function getParams(salt: Uint8Array): Pbkdf2Params {
	return {
		name: 'PBKDF2',
		salt: salt,
		iterations: 100000,
		hash: 'SHA-256',
	};
}

export function getKey(keyMaterial: CryptoKey, salt: Uint8Array): Promise<CryptoKey> {
	const params = getParams(salt);
	return my_crypto.subtle.deriveKey(params, keyMaterial, {name: 'AES-GCM', length: 256}, true, [
		'encrypt',
		'decrypt',
	]);
}

export function getKeyMaterial(password: string): Promise<CryptoKey> {
	return my_crypto.subtle.importKey(
		'raw',
		new TextEncoder().encode(password),
		{name: 'PBKDF2'},
		false,
		['deriveBits', 'deriveKey']
	);
}

function json_parse_unsafe(s: string): unknown {
	return JSON.parse(s);
}

export function json_parse<T>(s: string, d: D.Decoder<unknown, T>): T {
	return pipe(
		d.decode(json_parse_unsafe(s)),
		fold(
			// failure handler
			(errors) => {
				throw new Error(D.draw(errors));
			},
			// success handler
			(a) => a
		)
	);
}
