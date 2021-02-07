import {promises as fs} from 'fs';
// @ts-ignore
import {webcrypto} from 'crypto';
import {TextEncoder} from 'util';

import {getKey, getKeyMaterial, WANTED_HASH2} from './shared';
import secret from './secret';
import assert from 'assert';

const crypto: Crypto = webcrypto;

function buf2hex(buffer: ArrayBuffer): string {
	return Array.prototype.map
		.call(new Uint8Array(buffer), (x) => ('00' + x.toString(16)).slice(-2))
		.join('');
}

async function sha256sum(message: string): Promise<string> {
	const encoder = new TextEncoder();
	const data = encoder.encode(message);
	const hash = await crypto.subtle.digest('SHA-256', data);
	return buf2hex(hash);
}

const plainText = JSON.stringify({
	...secret,
	pages: secret.pages,
});

function my_btoa(str: string): string {
	const buffer = Buffer.from(str.toString(), 'binary');
	return buffer.toString('base64');
}

function encodeBytesAsBase64(bytes: ArrayBuffer): string {
	return my_btoa(String.fromCharCode(...new Uint8Array(bytes)));
}

async function main() {
	const salt = crypto.getRandomValues(new Uint8Array(16));
	const iv = crypto.getRandomValues(new Uint8Array(12));

	const cypherText = await (async () => {
		const hash = process.argv[2];
		assert.strictEqual(await sha256sum(hash), WANTED_HASH2);
		let keyMaterial = await getKeyMaterial(hash);
		let key = await getKey(keyMaterial, salt);
		const encoded = new TextEncoder().encode(plainText);

		return await crypto.subtle.encrypt(
			{
				name: 'AES-GCM',
				iv,
			},
			key,
			encoded
		);
	})();

	fs.writeFile(
		'encrypted.ts',
		`

export const salt = Uint8Array.from([
    ${[...salt].join(', ')}
]);

export const iv = Uint8Array.from([
    ${[...iv].join(', ')}
]);

export const cypherText = [
    ${(encodeBytesAsBase64(cypherText).match(/.{1,80}/g) ?? [])
			.map((s) => `'${s}'`)
			.join(',\n    ')}
].join('');

`
	);
}

main();
