# Практическая работа "Автоматизация"

В рамках данной практической работы - будет установлен web-сервер apache2 и настроен для отдачи, простой web страницы по протоколу http.

## Выгрузка формул Saltstack

Для выгрузки формул и шаблонов установки необходимо склонировать репозиторий и переместить файлы в директорию `/srv/salt/`:

```bash
git clone https://github.com/polyfrog/summer-school-auto-2023.git
```

## Установка salt-ssh

```bash
apt install salt-ssh
```

## Настройка salt master

В файл `/etc/salt/master` добавить:

```yaml
file_roots:
  base:
    - /srv/salt
pillar_roots:
  base:
    - /srv/salt/pillar
```

## Настройка подключения к управляемым хостам

Для настройки подключения к управляемым хостам по SSH - необходимо добавить в файл `/etc/salt/roster` запись следующего вида:

```yaml
<hostname>:
  host: <ip_adress>
  user: <sudouser>
  passwd: '<pass>'
  sudo: true
```

*В качестве hostname для управляемых хостов далее будет использоваться имя вида* `<username-web01>`

Для проверки подключения к управляемым хостам можно использовать команду:

```bash
salt-ssh '<username>-web01' -i test.ping
```

## Создание главного файла сопоставления стейтов и миньонов

В файл `/srv/salt/top.sls` добавить:

```yaml
base:
  '<username>-web01':
    - apache2
```

## Создание файла с переменными для стейта apache2

создать файл `pillar/apache.sls` с содержимым:

```yaml
domain: example.com
```

## Ограничение scope переменной, серверами, в названии которых, есть web

создать файл `pillar/top.sls` с содержимым:

```yaml
base:
  '*-web*':
    - apache
```

## Проверка доступности переменной

```bash
salt-ssh '*' pillar.items
```

## Запуск установки

```bash
salt-ssh '*' state.apply apache2
```
