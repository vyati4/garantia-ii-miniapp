# Гарантия ИИ — Telegram Mini App (тест-сборка)

МВП претензионной работы отдела гарантии ГК «Железно».
Автономный PWA на demo-данных: заявки, подрядчики, акты, фиксация дефекта,
генерация претензий/актов с правовым обоснованием (214-ФЗ, ГК РФ, СП/ГОСТ, договор).

## Что это
- Статический фронт (HTML/CSS/JS), без бэкенда — работает на встроенных demo-данных.
- Подключён Telegram WebApp SDK: запускается как Mini App внутри бота, тема синкается с клиентом.
- Данные тянутся через `fetch('/api/...')` с фолбэком на demo (когда появится бэк — поедет на реальные данные).
- PWA: `manifest.json` + `service-worker.js` → «Add to Home Screen» на iPhone без App Store.

## Хостинг
- **Тест-сборка:** GitHub Pages (этот репозиторий) — мгновенный HTTPS для просмотра коллегами и привязки к боту.
- **Прод (следующий этап):** TimeWeb VDS + Cloudflare на `app.virtu-os.ru`, бот `WarrantyAssistantBot`, FastAPI-бэк (VIRTÙ Control).

## Привязка к Telegram-боту (BotFather)
1. `@BotFather` → `/mybots` → выбрать бота.
2. **Bot Settings → Menu Button → Configure menu button** → вставить URL GitHub Pages, текст «📋 Открыть Гарантию ИИ».
3. (опц.) **Configure Mini App** → тот же URL.

Стек по карте консолидации: GitHub (код) · TimeWeb+Cloudflare (прод) · Telegram (интерфейс).
