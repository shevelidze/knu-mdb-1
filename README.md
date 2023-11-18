# knu-mdb-1

## Getting started

To start `psql` run:
```
./start-db.sh
```
This will spawn a docker container with PostgreSQL server and will open its shell.
The repository root directory is mounted to the `/app` of the shell docker container. Thus, in order to init the db you can run the command below in the `psql` shell:
```
\i /app/init.sql
```

## Database schema

![Database schema](https://github.com/shevelidze/knu-mdb-1/blob/main/schema.png?raw=true)

[dbdiagram.io](https://dbdiagram.io/) code:
```
Table users {
  id serial [pk]
  email text [not null, unique]
  first_name text [not null]
  last_name text [not null]
  middle_name text
  date_of_birth date [not null]
  role user_role [not null]
  residential_address_id int [not null, ref: > addresses.id]
  registration_address_id int [not null, ref: > addresses.id]
  facility_id int [ref: > facilities.id]
  language_id int [not null, ref: > languages.id]
  created_at timestamp [not null, default: 'now()']
  updated_at timestamp
  updated_by int [ref: > users.id]
}

Table languages {
  id serial [pk]
  name text [not null, unique]
}

Table addresses {
  id serial [pk]
  country_id int [not null, ref: > countries.id]
  city text [not null]
  street text [not null]
  unit text [not null]
}

Table countries {
  id serial [pk]
  name text [not null, unique]
}

Table accounts {
  id serial [pk]
  user_id int [not null, ref: > users.id]
  type account_type [not null]
  currency currency [not null]
  created_at timestamp [not null, default: 'now()']
}

Table transfers {
  id serial [pk]
  status transfer_status [not null]
  from_account_id int [not null, ref: > accounts.id]
  to_account_id int [not null, ref: > accounts.id]
  created_at timestamp [not null, default: 'now()']
  exchange_rate real
  amount real [not null]
  comment text
  deposit_id int [ref: > deposits.id]
  load_id int [ref: > loans.id]
}

Table deposits {
  id serial [pk]
  user_id int [not null, ref: > users.id]
  type deposit_type [not null]
  created_at timestamp [not null, default: 'now()']
  ends_at timestamp [not null]
  terminared_at timestamp
  terminated_by int [ref: > users.id]
  termination_reason text
  interest real [not null]
}

Table loans {
  id serial [pk]
  user_id int [not null, ref: > users.id]
  type loan_type [not null]
  rate real [not null]
  amount real [not null]
  repayed_amount real [not null]
  created_at timestamp [not null, default: 'now()']
  account_id int [ref: > accounts.id]
}

Table seessions {
  id serial [pk]
  user_id int
  type session_type [not null]
  terminated_at timestamp
}

Table payment_cards {
  id serial [pk]
  account_id int [not null, ref: > accounts.id]
  type payment_card_type [not null]
  number text [not null]
  cvc text [not null]
  expiration_month number [not null]
  expiration_year number [not null]
}

Table exchange_rates {
  id serial [pk]
  from_currency currency [not null]
  to_currency currency [not null]
  rate real [not null]
  created_at timestamp [not null, default: 'not()']
}

Table facilities {
  id serial [pk]
  address_id int [not null, ref: > addresses.id]
  number int [not null]
}

Table atms {
  id serial [pk]
  address_id int [not null, ref: > addresses.id]
  deactivated_at timestamp
}

Table mobile_application_builds {
  id serial [pk]
  version text [not null]
  platform mobile_platform [not null]
  created_at timestamp [not null, default: 'not()']
}

Table mobile_application_ratings {
  build_id int [not null, ref: > mobile_application_builds.id]
  rating int [not null]
  user_id int [ref: > users.id]
}

Table administrator_ratings {
  adiministrator_user_id int [not null, ref: > users.id]
  rating int [not null]
  user_id int [ref: > users.id]
}
```