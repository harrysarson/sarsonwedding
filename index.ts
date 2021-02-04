import './main.scss';
import 'regenerator-runtime/runtime';
import {getInfo, tryCache, tryPassword} from './get-info';
import {Elm} from './src/Main';
import invite from './images/invite.jpg';

import portrait0 from './images/sarsons-to-be/portrait/0.jpeg';
import portrait1 from './images/sarsons-to-be/portrait/1.jpeg';
import portrait2 from './images/sarsons-to-be/portrait/2.jpeg';
import portrait3 from './images/sarsons-to-be/portrait/3.jpeg';
import portrait4 from './images/sarsons-to-be/portrait/4.jpeg';
import portrait5 from './images/sarsons-to-be/portrait/5.jpeg';
import portrait6 from './images/sarsons-to-be/portrait/6.jpeg';
import portrait7 from './images/sarsons-to-be/portrait/7.jpeg';
import portrait8 from './images/sarsons-to-be/portrait/8.jpeg';
import portrait9 from './images/sarsons-to-be/portrait/9.jpeg';
import portrait10 from './images/sarsons-to-be/portrait/10.jpeg';
import portrait11 from './images/sarsons-to-be/portrait/11.jpeg';
import portrait12 from './images/sarsons-to-be/portrait/12.jpeg';
import portrait13 from './images/sarsons-to-be/portrait/13.jpeg';
import portrait14 from './images/sarsons-to-be/portrait/14.jpeg';
import portrait15 from './images/sarsons-to-be/portrait/15.jpeg';
import portrait16 from './images/sarsons-to-be/portrait/16.jpeg';

import landscape0 from './images/sarsons-to-be/landscape/0.jpeg';
import landscape1 from './images/sarsons-to-be/landscape/1.jpeg';
import landscape2 from './images/sarsons-to-be/landscape/2.jpeg';
import landscape3 from './images/sarsons-to-be/landscape/3.jpeg';
import landscape4 from './images/sarsons-to-be/landscape/4.jpeg';
import landscape5 from './images/sarsons-to-be/landscape/5.jpeg';
import landscape6 from './images/sarsons-to-be/landscape/6.jpeg';
import landscape7 from './images/sarsons-to-be/landscape/7.jpeg';
import landscape8 from './images/sarsons-to-be/landscape/8.jpeg';
import landscape9 from './images/sarsons-to-be/landscape/9.jpeg';
import landscape10 from './images/sarsons-to-be/landscape/10.jpeg';
import landscape11 from './images/sarsons-to-be/landscape/11.jpeg';

// import marked from 'marked';

async function checkAndLoadApp(password: string) {
	const key = await tryPassword(password);
	if (key === null) {
		const $tryAgain = document.querySelector('#try-again');
		if ($tryAgain instanceof HTMLElement) {
			$tryAgain.dataset.hide = 'true';
			if (password !== '') {
				setTimeout(() => ($tryAgain.dataset.hide = 'false'), 10);
			}
		}
	} else {
		loadApp(key);
	}
}

async function loadApp(key: CryptoKey) {
	document.querySelector('#login')?.setAttribute('hidden', '');
	document.querySelector('#app')?.removeAttribute('hidden');
	const info = await getInfo(key);
	const pages: {[name: string]: {text: string}} = {};
	for (const {name, text} of info.pages) {
		pages[name] = {text};
	}
	Elm.Main.init({
		flags: {
			pages,
			rsvpUrl: info.rsvpUrl,
			images: {
				invite,
				sarsonsToBe: {
					portrait: [
						portrait0,
						portrait1,
						portrait2,
						portrait3,
						portrait4,
						portrait5,
						portrait6,
						portrait7,
						portrait8,
						portrait9,
						portrait10,
						portrait11,
						portrait12,
						portrait13,
						portrait14,
						portrait15,
						portrait16,
					],
					landscape: [
						landscape0,
						landscape1,
						landscape2,
						landscape3,
						landscape4,
						landscape5,
						landscape6,
						landscape7,
						landscape8,
						landscape9,
						landscape10,
						landscape11,
					],
				},
			},
		},
	});
	// const $pages = document.querySelectorAll('.pages');
	// $pages.forEach($page => {
	// 	$page.textContent = "";
	// 	info.pages.forEach((page, i) => {
	// 		const $a = document.createElement('a');
	// 		$a.id = `page-${i}`;
	// 		$a.innerText = page.name;
	// 		const $h = document.createElement('h1');
	// 		$h.append($a);
	// 		const $div = document.createElement('div');
	// 		$div.append($h);
	// 		$div.insertAdjacentHTML('beforeend', (page.text));
	// 		$page.append($div)
	// 	});
	// });
	// const $footers = document.querySelectorAll('.footer');
	// $footers.forEach($footer => {
	// 	$footer.textContent = "";
	// 	info.pages.forEach((page, i) => {
	// 		const $a = document.createElement('a');
	// 		$a.href = `#page-${i}`;
	// 		$a.innerText = page.name;
	// 		const $div = document.createElement('div');
	// 		$div.append($a);
	// 		$footer.append($div)
	// 	});
	// });
}

async function init() {
	const key = await tryCache();
	if (key !== null) {
		loadApp(key);
	}
}

async function main() {
	await init();
	const $go = document.querySelector('#go');
	const $password = document.querySelector('#password');

	if ($go instanceof HTMLElement && $password instanceof HTMLInputElement) {
		$go.addEventListener('click', (e) => {
			let password = $password.value;
			checkAndLoadApp(password);
			$password.focus();
			$password.select();
		});

		$password.addEventListener('change', (e) => {
			let password = $password.value;
			checkAndLoadApp(password);
		});
	} else {
		throw new Error('Missing essential loging html elmements!');
	}
}

main();
