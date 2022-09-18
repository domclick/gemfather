# Gemfather

![Gemfather image](/docs/gemfather.png?raw=true)

### Гем для генерации API-гемов

Установка

`gem install gemfather`

После установки гем добавляет в путь `$PATH` исполняемый скрипт `gemfather`, который позволит запускать `gemfather` из командной строки   

`gemfather GEM_NAME` создает в текущем каталоге папку GEM_NAME c базовой структурой для гема API

Описание нового проекта и документация по его конфигурированию и работе также будет сгененрирована в файле `GEM_NAME/README.md`

Пример:
```
./gemfather domclick_new_api

      create  domclick_new_api
      create  domclick_new_api/domclick_new_api.gemspec
      create  domclick_new_api/Dockerfile.test
      create  domclick_new_api/Gemfile
      create  domclick_new_api/Makefile
      create  domclick_new_api/README.md
      create  domclick_new_api/Rakefile
      create  domclick_new_api/bin/console
      create  domclick_new_api/bin/dc
      create  domclick_new_api/bin/generate
      create  domclick_new_api/lib/domclick_new_api.rb
      create  domclick_new_api/lib/domclick_new_api/client.rb
      create  domclick_new_api/lib/domclick_new_api/railtie.rb
      create  domclick_new_api/lib/domclick_new_api/version.rb
      create  domclick_new_api/spec/spec_helper.rb
      create  domclick_new_api/log
       chmod  domclick_new_api/bin/dc
       chmod  domclick_new_api/bin/generate
       chmod  domclick_new_api/bin/console
         run  bundle binstubs rspec-core from "./domclick_new_api"
         run  bin/rspec from "./domclick_new_api"
```

Внутри каталога есть исполняемый скрипт generate, который генерирует в проекте скаффолд для ручки сервиса

Генерация скаффолда (api, model, specs) происходит следующим образом:
`bin/generate namespace:action:post` 

Пример: `bin/generate deals:create:post`

Будет добавлена следующая структура каталогов и файлов
```
      create  ./lib/domclick_api/api
      create  ./lib/domclick_api/api/deals.rb
      create  ./lib/domclick_api/model/deals/create
      create  ./lib/domclick_api/model/deals/create/request.rb
      create  ./lib/domclick_api/model/deals/create/response.rb
      create  ./spec/api
      create  ./spec/api/deals_spec.rb
      create  ./spec/model/deals/create
      create  ./spec/model/deals/create/request_spec.rb
      create  ./spec/model/deals/create/response_spec.rb
```
Таким образом, будет создана ручка, вызывающая путь `/create`, модели `request` и `response`, а также тесты для этой ручки

## Пагинация

Опционально, если добавить параметр `--paginate` - то ручка будет поддерживать пагинацию. Для конфигурации пагинации используется DSL:

```ruby
paginate :find_offers,
         with: :limit_offset,
         on_request: lambda { |req, limit: nil, offset: nil, sort: nil|
           req.params[:limit] = limit if limit.present?
           req.params[:offset] = offset if offset.present?
           req.params[:sort] = sort if sort.present?
         },
         data_key: :offers,
         limit: :limit.to_proc,
         offset: :offset.to_proc,
         total: :total.to_proc
```

```ruby
paginate :find_offers,
         with: :page,
         on_request: lambda { |req, page: nil, per_page: nil, sort: nil|
           req.params[:page] = page if page.present?
           req.params[:per_page] = per_page if per_page.present?
           req.params[:sort] = sort if sort.present?
         },
         data_key: :offers,
         per_page: :per_page.to_proc,
         total: :total.to_proc
```

Таким образом, метод `find_offers` будет возвращать объект relation, реализующий `Enumerable`.
Данные при этом не будут загружены до тех пор, пока доступ к ним не понадобится (например, метод `#to_a`).

## Опции DSL

`with` - стратегия пагинации, стандартно поддерживаются `:page` и `:limit_offset`.
`on_request` - коллбэк вызываемый при инициализации запроса. Позволяет нужным образом передать параметры (например, в теле или в хедерах).
`data_key` - ключ, по которому можно получить массив данных из ответа.
Может быть пустым, если данные лежат в корне, или массивом, если данные находятся в многоуровневой структуре (например, `[:data, :offers]`).
`total` - коллбэк, по которому можно получить из ответа общее количество элементов на всех страницах (не обязательная опция).

Опции, индивидуальные для стратегий пагинации:

### Стратегия :page

`per_page` - коллбэк, по которому можно получить из ответа количество элементов на одной странице (не обязательная опция).

### Стратегия :limit_offset

`limit` - коллбэк, по которому можно получить из ответа количество элементов на одной странице (не обязательная опция).
`offset` - коллбэк, по которому можно получить из ответа текущее смещение (не обязательная опция).

## Использование метода с пагинацией

```ruby
# Получение 100 записей, упорядоченных по id, начиная с 50-го элемента
client.find_offers(company_id: 1).limit(100).offset(50).order(id: 'desc').to_a

# Получение всех записей начиная с 50-го элемента
client.find_offers(company_id: 1).limit(100).offset(50).all_remaining.to_a

# Получение 10 записей на второй странице
client.find_offers(company_id: 1).page(2).per_page(10).to_a

# Получение всех записей начиная со второй страницы
client.find_offers(company_id: 1).page(2).all_remaining.to_a

# Получение первого элемента со второй страницы
client.find_offers(company_id: 1).page(2).first

# Получение полного ответа со второй страницы
client.find_offers(company_id: 1).page(2).response

# Получение общего количество элементов на всех страницах в сумме
client.find_offers(company_id: 1).page(2).total

# Получение общего количество элементов на всех страницах в сумме (сначала загрузит все страницы)
client.find_offers(company_id: 1).page(2).total!
```
