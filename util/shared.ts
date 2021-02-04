const my_crypto: Crypto = (() => {
	if (typeof window === 'undefined') {
		return require('crypto').webcrypto;
	} else {
		return window.crypto;
	}
})();

export const WANTED_HASH2 = '437f1fcfc1347fab43f0ac82d6403e7e121fd96ad6016a48a754257154d1afd8';

export type Info = {
	pages: Array<{name: string; text: string}>;
	rsvpUrl: string;
};

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
