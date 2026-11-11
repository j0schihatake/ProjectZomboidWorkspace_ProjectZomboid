# Окружение этой машины: GPU, X11, песочница DSH

Эти правила — про окружение, а не про мод. Они действуют для этой рабочей папки
(`/home/j0schi/SteamLibrary/steamapps/common/ProjectZomboid`).

## Песочница

- Сессия работает в пресете **Auto-approve → `workspace-write`**. Команды выполняются
  через bwrap с минимальным `/dev` и приватным `/tmp`.
- Поэтому **в обычной песочнице всегда отсутствуют** `/dev/dri`, `/dev/nvidia*`,
  `/tmp/.X11-unix`. Это нормальное состояние, **а не поломка GPU**.
- `nvidia-smi` и `glxinfo` в обычной песочнице падают (`could not communicate`,
  `GLX BadValue`) — тоже нормально.

**Никогда не делай вывод «GPU сломан» и не ставь цель в `blocked` на основании
проверки `/dev/dri`, `nvidia-smi` или `glxinfo`, выполненной без эскалации.**
Такая проверка ничего не говорит о хосте.

## Дисплей

- Рабочий дисплей — **`:1`** (X11). `DISPLAY=:0` не существует; не проверяй его.
- `xdotool` работает и из песочницы (X11 через abstract socket), а GL/GPU — нет.

## Запуск игры

- Игра запускается **только с эскалацией**: вызывай `bash` с
  `sandbox_permissions: "danger-full-access"` **и** `justification`, иначе получишь
  `invalid escalation: justification is only valid together with sandbox_permissions`.
  Человек подтверждает такой запрос один раз на вызов.
- Команда: `cd /home/j0schi/Zomboid/PersonalKnox-dev && ./tools/launch_dev.sh --detach`
  (или `--profile full --restart --build --detach --no-debug --nosteam`).
- Если игра запущена **без эскалации**, она зависает на `Creating display` — это
  ожидаемо; повтори с `danger-full-access`, а не считай окружение сломанным.
- Загрузка мира B42 может занимать **больше 5 минут** (см. комментарий в
  `tools/launch_game.sh`). Ждать до ~10 минут, читая `console.txt`; не убивать
  процесс раньше и не считать «зависанием».
- Проверять результат — по `/home/j0schi/Zomboid-dev/PersonalKnox/console.txt`
  (`summary passed=…`), а не по скриншотам.

## Запреты

- **Не менять скрипты запуска игры** (`tools/launch_dev.sh`, `tools/launch_game.sh`,
  `tools/launch_test.sh`, `dev_launch.py`) без прямой просьбы человека.
- Не создавать устройства через `mknod` в `/dev` — device cgroup всё равно не пустит.

## Если что-то действительно не работает

Проверять GPU имеет смысл только внутри команды с `danger-full-access`
(`nvidia-smi`, `ls /dev/dri`). Если и там пусто — писать человеку, а не ставить
`blocked` по данным из обычной песочницы.

## Если игра виснет до игрового сценария

Признаки:

- висит окно **«ZombieBuddy Java Mod Approval»** (или любое другое окно
  подтверждения/ошибки) и сценарий не начинается;
- в `console.txt` нет `summary passed=…`;
- игра не доходит до мира и тестов.

В этом случае считай, что **скрипт запуска игры был изменён** (или запуск идёт не с
теми флагами). Не «лечи» это правкой скрипта на месте.

Порядок действий:

1. Проверить, правились ли launch-скрипты:

   ```bash
   git -C ~/Zomboid/PersonalKnox-dev status --short tools/
   git -C ~/Zomboid/PersonalKnox-dev diff -- \
     tools/launch_dev.sh tools/dev_launch.py tools/launch_game.sh tools/launch_test.sh
   ```

2. Если правки есть — откатить их к последнему коммиту:

   ```bash
   git -C ~/Zomboid/PersonalKnox-dev restore -- \
     tools/launch_dev.sh tools/dev_launch.py tools/launch_game.sh tools/launch_test.sh
   ```

3. Если зависание осталось — найти последний коммит, в котором запуск доходил до
   сценария, и вернуть скрипты к нему:

   ```bash
   git -C ~/Zomboid/PersonalKnox-dev log --oneline -- tools/launch_dev.sh tools/dev_launch.py
   git -C ~/Zomboid/PersonalKnox-dev checkout <commit> -- \
     tools/launch_dev.sh tools/dev_launch.py
   ```

4. Запускать с флагом **`--trust-local-builds`** — он даёт постоянное доверие двум
   локальным корням проекта и убирает окно подтверждения JAR:

   ```bash
   cd ~/Zomboid/PersonalKnox-dev && ./tools/launch_dev.sh --trust-local-builds --detach
   ```

5. Только после возврата рабочего скрипта и флага `--trust-local-builds` снова
   пробовать сценарий. Окно подтверждения JAR и другие пред-сценарные окна —
   сигнал проблемы запуска, а не повод менять код мода.
