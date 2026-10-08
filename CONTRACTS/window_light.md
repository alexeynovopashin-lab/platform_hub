# Договор: свет в окнах зала

**Хозяин:** Light Plan (хозяин солнечной модели, 07.10 — см. `DECISIONS.md`). **Пользователи:** BroniOS (окно брони, админка), сайт студии. **Статус:** сделано шагом Light Plan 31в (08.10): JS в `main` Light-Plan, Swift в ветке `wt/31c` (в `main` натива не слито). BroniOS: взять копию файла, прогнать сверку.

**Вход:** широта и долгота студии; момент времени; пояс зала (имя, например `Asia/Tomsk`); азимут окон зала (градусы от севера по часовой, куда смотрят окна); `hasWindows`.
**Выход:** `прямой` (`direct`) · `рассветный` (`sunrise`) · `закатный` (`sunset`) · `рассеянный` (`diffuse`) · `нет окон` (`none`) · `нет данных` (`unknown`, с причиной `reason`). Пороги — константы (угол 85°, высота 2° и 6°), выбрал Light Plan, обоснование и таблица чувствительности в справке. Утренний золотой час — «рассветный», вечерний — «закатный» (Алексей 08.10, A-008; Q-030).
**Не учитывается в первой версии:** погода, размер окна, преграды (дом напротив). Подпись честная: «по солнцу, без погоды».
**Форма поставки:** Swift (Light Plan) + самодостаточный JS-файл без DOM для BroniOS и сайта + числа сверки + справка. Пути:
- JS-правило (его копирует BroniOS): `light_plan:Light_Plan/tools/window_light.js`, живой адрес https://alexeynovopashin-lab.github.io/Light-Plan/tools/window_light.js; коммит `7d559ca` в `main` Light-Plan.
- Сверка своей копии: `node tools/window_light_check.js <window_light.json> [копия]` (`light_plan:Light_Plan/tools/window_light_check.js`); код 0 — копия считает как приложение.
- Числа сверки: `light_plan:native/Fixtures/window_light.json` (9608 ответов), репозиторий LightPlan, ветка `wt/31c` (после слияния — `main`).
- Справка: `light_plan:Light_Plan/docs/window_light_reference.md`.
- Swift: `light_plan:native/Packages/LightPlanDomain/Sources/LightPlanDomain/Rules/WindowLight.swift`.
**Причины «нет данных» (`reason`):** `no_windows_flag`, `no_azimuth`, `no_coordinates`, `no_zone`, `bad_zone`, `bad_moment`, `moment_out_of_range` (принимаются моменты с 1970-01-01 до 2100-01-01 UTC). `hasWindows: false` даёт «нет окон» и без остальных полей.
**Что поменялось 08.10 (доработка 31в):** вид `golden` заменён парой `sunrise` / `sunset`; поле `half` осталось (`morning` / `evening`). Копии, написанные по первой версии файла, надо обновить.
**Нужно от BroniOS:** данные зала — Q-024.
