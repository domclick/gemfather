# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2023-10-12
### Added
- Расширен фукционал gemfather для отправки метрик через `ActiveSupport::Notifications` гему `domclick/bigbrother`
Добавлена опция `config.enable_instrumentation` для отправки метрик через `ActiveSupport::Notification`. включается на уровне руби клиента.
Сам гем `domclick/bigbrother` пока не опубликован. Но в целом он представляет собой отправку инструментируемых через Faraday событий в `Prometheus` посредством гема `yabeda`.

- Облегчена зависимость к `development` `bunler`'у.
Dev-зависимости указаны только в `Gemfile`, удалены из `.gemspec`, чтобы избежать дублей

- Версия `dry-configurable` ограничена т.к. новый синтаксик после `0.14` не поддерживается.

## [2.2.1] - 2023-01-25
### Fixed
- Исправлена работа опции `data_key` с вложенными структурами в пагинации.


## [2.2.0] - 2023-01-09
### Added
- Добавлена возможность задавать настройки сертификата для подключения.
Полное отключение флагом `ssl_verify` и возможность указать файл с сертификатами `ca_file`. Настройка пробрасывается в `Faraday`


## [2.1.1] - 2022-10-25
### Fixed
- Доработка метода `parse_time` для `nullable` дат
Возвращаем `nil` если приходит `nil` вместо даты в `parse_time`


## [2.1.0] - 2022-09-18
### Added
Первичная публикация гема

[2.2.1]: https://github.com/domclick/gemfather/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/domclick/gemfather/compare/2.1.1...2.2.0
[2.1.1]: https://github.com/domclick/gemfather/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/domclick/gemfather/releases/tag/2.1.0