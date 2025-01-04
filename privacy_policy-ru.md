
# Политика конфиденциальности

Исходные коды приложения открыты и доступны в репозитории для ознакомления и анализа
по адресу "https://github.com/maxrys/js-blocker".

Приложение является связкой из трёх частей:
- главное приложение;
- расширение браузера Safari "JS Blocker Extension";
- расширение браузера Safari "JS Blocker Rules".

Пользователь сам определяет на каких доменах (сайтах) будут работать
расширения "JS Blocker Extension" и "JS Blocker Rules".

Приложение не работает с файловой системой – не записывает и не читает никакие данные.
Приложение использует стандартный механизм _Core Data_ для хранения "списка разрешённых доменов"
в локальной файловой системе. Данный список формируется по требованию пользователя для
функционирования приложения.

Приложение не подключает внешние файлы JavaScript.
Расширение "JS Blocker Extension" подключает локальный файл "script.js",
который является прозрачным для анализа и необходим для функционирования приложения.
Основной назначение "script.js" – это выключение JavaScript на выбранном
домене (по умолчанию) или его включение по требованию пользователя.

Главное приложение, расширения "JS Blocker Extension" / "JS Blocker Rules", файл "script.js":
- не регистрируют нажатия пользователя;
- не имеют доступа к буферу обмена;
- не добавляют события к DOM-элементам;
- не отправляют и не принимают данные по внешней сети;
- не собирают и не хранят какие-либо персональные данные;
- не передают какие-либо данные третьей стороне.

Приложение работает в изолированной среде ОС (песочнице) и не способно повлиять
на что-либо, кроме работы JavaScript в браузере Safari.