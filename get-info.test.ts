import test from 'ava';
import {salt} from './encrypted';
import {getInfo} from './get-info';
import {getKey, getKeyMaterial} from './util/shared';

test('getInfo', async (t) => {
	const hash1 = process.env.PASSWORD_HASH;
	t.notDeepEqual(hash1, undefined);
	const keyMaterial = await getKeyMaterial(hash1!);
	const key = await getKey(keyMaterial, salt);
	await t.notThrowsAsync(() => getInfo(key));
});
