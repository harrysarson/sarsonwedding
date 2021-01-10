import './main.scss';
import 'regenerator-runtime/runtime';
import { getInfo, tryCache, tryPassword } from './get-info';

// import marked from 'marked';

async function checkAndLoadApp(password: string) {
	const key = await tryPassword(password);
	if (key === null) {
		const $tryAgain = document.querySelector('#try-again');
		if ($tryAgain instanceof HTMLElement) {
			$tryAgain.dataset.hide = "true";
			if (password !== '') {
				setTimeout(() => ($tryAgain.dataset.hide = "false"), 10);
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
	const $pages = document.querySelectorAll('.pages');
	$pages.forEach($page => {
		$page.textContent = "";
		info.pages.forEach((page, i) => {
			const $a = document.createElement('a');
			$a.id = `page-${i}`;
			$a.innerText = page.name;
			const $h = document.createElement('h1');
			$h.append($a);
			const $div = document.createElement('div');
			$div.append($h);
			$div.insertAdjacentHTML('beforeend', (page.text));
			$page.append($div)
		});
	});
	const $footers = document.querySelectorAll('.footer');
	$footers.forEach($footer => {
		$footer.textContent = "";
		info.pages.forEach((page, i) => {
			const $a = document.createElement('a');
			$a.href = `#page-${i}`;
			$a.innerText = page.name;
			const $div = document.createElement('div');
			$div.append($a);
			$footer.append($div)
		});
	});
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
		throw new Error("Missing essential loging html elmements!");
	}

}

main();
