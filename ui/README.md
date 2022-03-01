# vpm.vlang.io

![Главная rgd.chat](https://user-images.githubusercontent.com/26527529/131203635-b1aff017-673b-4c33-a783-aa3dc9d82859.jpg)

## Разработка

После клонирования проекта и установки зависимостей с помощью `pnpm i`, запустите сервер разработки:

> Мы используем _[pnpm](https://github.com/pnpm/pnpm)_ для разработки

```bash
pnpm dev

# или можно одновременно еще открыть вкладку в браузере
pnpm dev -- --open
```

## Сборка прода

```bash
pnpm build
```

Итоговый бандл лежит в папке `.svelte-kit/...` далее следует название адаптера платформы на которую идёт деплой (она определится [автоматически](https://github.com/sveltejs/kit/tree/master/packages/adapter-auto)) прим. `cloudflare`, `vercel` или `netlify`.

> Вы можете предварительно просмотреть собранное приложение с помощью `pnpm preview`.

> Прикол с Cloudflare'ом, чтобы собрать нужно использовать команду `npm i -g pnpm && pnpm i && pnpm build`
