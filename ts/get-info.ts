import {salt, iv, cypherText} from './encrypted';
import {getKey, getKeyMaterial, Info, json_parse, my_atob, my_crypto, WANTED_HASH2} from './shared';

function buf2hex(buffer: ArrayBuffer): string {
	return Array.prototype.map
		.call(new Uint8Array(buffer), (x) => ('00' + x.toString(16)).slice(-2))
		.join('');
}

async function sha256sum(message: string): Promise<string> {
	const encoder = new TextEncoder();
	const data = encoder.encode(message);
	const hash = await my_crypto.subtle.digest('SHA-256', data);
	return buf2hex(hash);
}

export const tryPassword = async (password: string) => {
	const hash1 = await sha256sum(password);
	if ((await sha256sum(hash1)) !== WANTED_HASH2) {
		return null;
	}
	localStorage.setItem('credentials', hash1);
	const keyMaterial = await getKeyMaterial(hash1);
	return await getKey(keyMaterial, salt);
};

export const tryCache = async () => {
	const hash1 = localStorage.getItem('credentials');
	if (hash1 === null || (await sha256sum(hash1)) !== WANTED_HASH2) {
		return null;
	}
	const keyMaterial = await getKeyMaterial(hash1);
	return await getKey(keyMaterial, salt);
};

export const getInfo = async (key: CryptoKey): Promise<Info> => {
	const decrypted = await my_crypto.subtle.decrypt(
		{
			name: 'AES-GCM',
			iv,
		},
		key,
		decodeBytesFromBase64(cypherText)
	);
	return json_parse(new TextDecoder().decode(decrypted), Info);
};

function decodeBytesFromBase64(encoded: string): ArrayBuffer {
	return Uint8Array.from(my_atob(encoded), (c) => c.charCodeAt(0));
}
