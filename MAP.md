# Project Zomboid — карта проекта (единый workspace)

Рабочая папка DSH-агента: `/home/j0schi/SteamLibrary/steamapps/common/ProjectZomboid`

## Где что лежит

```
ProjectZomboid/
  projectzomboid/            игра (10 ГБ) — не трогаем
  work/
    PersonalKnox-dev/        ОСНОВНОЙ репозиторий модов (git, GitHub)
    PersonalWorldGen-dev/    второй репозиторий (git, GitHub)
    pz-cache/                кэш dev-запуска (--cache-dir), пишется игрой
    deliverables/            артефакты, bare-репозитории (можно чистить)
  AGENTS.md                  правила для агента (защищён)
  HANDOFF.md                 состояние работ для передачи смены
```

## Откуда игра грузит мод

1. Лаунчер `work/PersonalKnox-dev/tools/dev_launch.py` создаёт кэш (`--cache-dir`,
   теперь `work/pz-cache`) и кладёт туда `mods/default.txt` + симлинки
   `mods/_pkdev_<id>` → корни модов.
2. Игра запускается с `-cachedir=<кэш>`; симлинки ведут в **work-копии**,
   поэтому игра читает JAR/Lua/скрипты прямо из репозитория.
3. `~/Zomboid` (userdata) используется только для настроек и сохранений
   (`--userdata /home/j0schi/Zomboid`), мод оттуда не грузится, если в кэше
   есть dev-версия (приоритет source выше userdata/mods).

## Куда собирается JAR

- `work/PersonalKnox-dev/tools/build.py` → `42/media/java/client/PersonalKnox.jar`
  (внутри того же worktree).
- Java-классы и ресурсы: `build/classes/` (временное, можно чистить).
- Lua-скрипты: `common/media/lua/client/PersonalKnox/...` — **не копируются**,
  игра читает их из репозитория через симлинк кэша.
- Ники/имена/профессии: SQLite. Схема и seed:
  `src/main/resources/personal/knox/db/{schema,seed}.sql`; рабочая БД:
  `<save>/PersonalKnox.db`, запасной путь `~/Zomboid/Lua/PersonalKnox.db`.

## Правила

- Работать только в `work/*`, исходные копии в `~/Zomboid` не нужны.
- Запуск игры — с `--source work/PersonalKnox-dev --cache-dir work/pz-cache --build`.
- `~/Zomboid-dev` и старые `~/Zomboid/PersonalKnox-*` — архив, не использовать.
